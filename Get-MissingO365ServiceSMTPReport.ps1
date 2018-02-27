# -----------------------------------------------------------------------------  
# Script: Get-MissingO365ServiceSMTPReport.ps1  
# Author: David Smith (www.texmx.net) 
# Date: 08/19/15  
# Keywords:  
# comments:  
#  
# Run (Report Only): .\Get-MissingO365ServiceSMTPReport.ps1 MHRA D:\Temp\FileName.csv
# Run (Report & Fix): .\Get-MissingO365ServiceSMTPReport.ps1 MHRA D:\Temp\FileName.csv -Repair
#
# -----------------------------------------------------------------------------  
 
import-module activedirectory

[CmdLetBinding()] 
param( 
    [Parameter(Mandatory=$True)] 
    [String]$TenantID, 
 
    [Parameter(Mandatory=$False)] 
    [String]$ReportFile = '.\MissingO365ServiceSMTP.csv', 
 
    [Parameter(Mandatory=$false)] 
    [Switch]$Repair 
) 
 
$mailboxes = Get-Mailbox -resultsize Unlimited | ? { !($_.emailaddresses -like ("*"+$TenantID+".mail.onmicrosoft.com*")) } 
"UPN,EmailAddressPolicyEnabled,PrimarySMTP,EmailAddresses" | Out-File $ReportFile 
Foreach ($mbx in $mailboxes) { 
    $mbxstats = $mbx.UserPrincipalName+","+$mbx.EmailAddressPolicyEnabled+","+$mbx.PrimarySmtpAddress+","+($mbx.EmailAddresses | ?{$_.prefix -like 'smtp'}) 
    $mbxstats | Out-File $ReportFile -Append 
} 
 
if ($Repair) { 
#    if (-not(Get-Module -Name ActiveDirectory)) {Import-Module ActiveDirectory} 
#    foreach ($user in $mailboxes) { 
#        Write-Host "Adding missing onmicrosoft.com SMTP address to User: "$user.SamAccountName
#        Get-ADUser -Identity $user.SamAccountName | Set-ADUser -Add @{ProxyAddresses=("smtp:"+$user.Alias+"@"+$TenantID+".mail.onmicrosoft.com")} 
#    } 
}
