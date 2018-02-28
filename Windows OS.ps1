# Get locked out location using Id 4740
$Events = Get-WinEvent -ComputerName DC01 -FilterHashtable @{Logname='Security';Id=4740}
$Events[0].Properties

# Get logins
Get-LoginInstance.ps1 -StartDate (Get-Date).AddDays(-7) -Verbose | Select Username,LoginTime,SessionType,LoginIpAddress

# Get Security event log for last 24 hours for a specific EventID
Get-EventLog -ComputerName hostname -LogName Security -After (Get-Date).AddDays(-1) | ? {$_.EventID -eq "531"}   
  
# Search the security logs for a string
Get-WinEvent -ComputerName hostname -FilterHashtable @{logname='security';data='dalemorson'}   

# Restart-Computer
http://www.powershellmagazine.com/2012/11/27/better-restart-computer-cmdlet-in-powershell-3-0/

# Is the system 32bit or 64bit? 
if ([System.IntPtr]::Size -eq 4) { "32-bit" } else { "64-bit" } 
 
# Detect GPT / MBR paritions 
gwmi -query "Select * from Win32_DiskPartition WHERE Index = 0" | Select-Object DiskIndex, @{Name="GPT";Expression={$_.Type.StartsWith("GPT")}} 
 
# Get a list of installed applications from a remote computer 
Get-WmiObject -computername SERVERNAME win32_product | Sort-Object name | ft name,version,vendor 
  
# Last boot up time - PowerShell v1 - 2 
Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} 
  
# Last boot up time - PowerShell v3+ 
Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime 
  
# Get details of the last clean shutdown of a remote server 
Get-WinEvent -LogName System -maxevent 3 -FilterXPath '*[System[(EventID=1074)]]' -ComputerName SERVERNAME | format-table machinename, userid, timecreated -autosize 
 
# Get details of a particular installed hotfix 
Get-Hotfix -id kb#  -computername SERVERNAME 
 
# Get IP settings of a remote server 
Get-WMIobject -computername SERVERNAME win32_networkadapterconfiguration | where {$_.IPEnabled -eq "True"}| Select-Object pscomputername,ipaddress,defaultipgateway,ipsubnet,dnsserversearchorder,winsprimaryserver | format-Table -Auto 
 
# Install Telnet client   
Add-WindowsFeature telnet-client   
 
# Who's logged in? 
Get-WinEvent @{ LogName = "Security"; Id = 4624 } | group { $_.properties[5].Value }   
 
# List apps at startup 
Get-CimInstance -ClassName Win32_StartupCommand | Select-Object -Property Name, Location, User, Command, Description | select -ExpandProperty Description   
 
# Free space on mount point  
Param($ServerName)  
$freespaceprct = @{ expression={ [float] $_.freespace / $_.capacity * 100} ; label='Freespace %';format="{0:N1}";width=12;alignment='right'}  
$sizeMB = @{ expression={ [float] $_.capacity / 1024 /1024}; label='Size (MB)';format="{0:N1}";width=10;alignment='right'}  
$FreespaceMB = @{ expression={ [float] $_.freespace / 1024 /1024}; label='Freespace (MB)';format="{0:N1}";width=15;alignment='right'}  
$deviceid = @{ expression={ $_.Name }; label='Drive/MountPoint' }  
$Volumes = Get-WmiObject -namespace "root/cimv2" -computername $ServerName -query "SELECT Name, Capacity, FreeSpace FROM Win32_Volume WHERE DriveType = 2 OR DriveType = 3"  
$Volumes | sort-object -property freespace | ft $deviceid, $sizeMB, $FreespaceMB, $freespaceprct -autosize  

# Reset local administrator password and add new users
https://www.isunshare.com/windows-server/add-a-user-to-local-administrator-group.html
https://social.technet.microsoft.com/Forums/windows/en-US/70fd1483-fdd1-49a5-8a74-d8eb22c5965d/how-i-reset-windows-server-2012-administrator-password-without-installation-cds?forum=winserver8gen

# Lookup KMS Hosts
nslookup -type=srv _vlmcs._tcp

# ping with specific MTU size
ping google.com -f -l 1472 

<# Reason greater than 1472 MTU is fragmented when 1500 is the default 	The reason for this is that by default, the standard IP MTU of 1500. Along with the default size, you have to account for 8 bytes being used for the ICMP header and another 20 bytes for the IP. 
This comes out to: 1500 - 8 - 20 = 1472 
As such, 1472 bytes is the largest payload you can set where you have do fragment turned off. #>

<# Testing a Proxy Server. Do a "what’s my IP" in Google from a client device to confirm which proxy it is going through. #>
 
# NTP   
w32tm /stripchart /computer:time.nist.gov   
w32tm /stripchart /computer:80.86.38.193
w32tm /query /peers   

# OS Install date
Systeminfo | find "Original Install Date"

<# KMS Port
Communication with KMS is via anonymous RPC. 1688 is the default TCP port used by the clients to connect to the KMS host. Make sure this port is open between your KMS clients and the KMS host. The port can be changed and can be configured on the KMS host. The KMS clients receive this port designation from the KMS host during their communication. If you change the port on a KMS client, it will be overwritten when that client contacts the host. #>

# Get list of KMS Servers
nslookup -type=srv _vlmcs._tcp >%temp%\kms.txt

# Activate against a KMS Server
c:\windows\system32\slmgr.vbs -skms kms1.kms.sjsu.edu
slmgr.vbs -ato

# Unable to RDP to Windows Server with "You can't connect remotely to the machine" in Azure
# Telnet to port 3389 is open
Rename the folder MachineKeys to MachineKeys.old
Restart RDS Service 

# Add a line to the HOSTS file
echo "1.1.1.1 wsus otherhostname" >> c:\windows\system32\drivers\etc\hosts

# Amend Automatic Updates registry settings 
$RegKey ="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" 
Set-ItemProperty -Path $RegKey -Name WUServer -Value "http://WSUS:80" 
Set-ItemProperty -Path $RegKey -Name WUStatusServer -Value "http://WSUS:80" 
$RegKeyAu ="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" 
Set-ItemProperty -Path $RegKeyAu -Name UseWUServer -Value "1" -Type DWord 
Set-ItemProperty -Path $RegKeyAu -Name AlwaysAutoRebootAtScheduledTime -Value "0" -Type DWord 
Set-ItemProperty -Path $RegKeyAu -Name NoAutoUpdate -Value "0" -Type DWord 
Set-ItemProperty -Path $RegKeyAu -Name AUOptions -Value "3" -Type DWord 
Set-ItemProperty -Path $RegKeyAu -Name ScheduledInstallDay -Value "0" -Type DWord 
Set-ItemProperty -Path $RegKeyAu -Name ScheduledInstallTime -Value "17" -Type DWord 

# Check if specific patch is installed across multiple servers
$hotfix = KB######
$computer = server
if (Get-HotFix -ComputerName $computer| ? {$_.HotfixID -eq $hotfix}) {
Write-Host -ForegroundColor GREEN "TRUE"
} else {
Write-Host -ForegroundColor RED   "FALSE"
}

# WinRM Enabled?
Get-Service -name "*winrm*" | select -ExpandProperty Status

# Server 2003 uptime
systeminfo | find "System Up Time"

# Update installed on
Get-HotFix | ? {$_.installedon -gt "08/26/2017 12:00:00AM"} | select -ExpandProperty HotFixID

# PoshWSUS Module
Install-Module PoshWSUS

# PSWindowsUpdate Module
Get-Module -ListAvailable
Import-Module PsWindowsUpdate
# Examples
# https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc

# WSUS Error Codes
https://msdn.microsoft.com/en-us/library/windows/desktop/hh968413(v=vs.85).aspx

# Clear local Windows Cached Credentials
cmdkey.exe /list > "%TEMP%\List.txt"
findstr.exe Target "%TEMP%\List.txt" > "%TEMP%\tokensonly.txt"
FOR /F "tokens=1,2 delims= " %%G IN (%TEMP%\tokensonly.txt) DO cmdkey.exe /delete:%%H
del "%TEMP%\List.txt" /s /f /q
del "%TEMP%\tokensonly.txt" /s /f /q