# Check Global Catalog replication
dcdiag /s:servername /V | find "%"
# There's no replication of global catalog between forests in a two way trust

# Import module. Requires RSAT.
Import-Module activedirectory

# Extract AD users from a specific OU (SearchBase)
Get-Aduser -properties * -SearchBase "OU=OUName,OU=OUName,DC=domain,DC=local" -Filter * | ft Name,SamAccountName,extensionAttribute1

# Extract AD users from a specific OU (SearchBase) and extract to CSV
Get-Aduser -properties * -SearchBase "OU=OUName,OU=OUName,DC=domain,DC=local" -Filter * | select Name,SamAccountName,extensionAttribute1 | export-csv c:\users\<username>\desktop\disabled.csv -NoTypeInformation

# Clear multiple AD users targetAddress
foreach ($user in $users)
{
# Remove comment below as required
# Get-Aduser -properties * -identity $user | set-aduser -Clear targetAddress -whatif
# Get-Aduser -properties * -identity $user | set-aduser -Clear targetAddress
# Get-Aduser -properties * -identity $user | ft Name,SamAccountName,targetAddress
}

# Extract all AD users based on particular properties 
Get-ADUser -filter * -property department,company,title,lastlogon,manager,DisplayName | select-object DisplayName, GivenName, surname,Enabled,SamAccountName, title, department, company, Manager, @{n='LastLogon';e={[DateTime]::FromFileTime($_.LastLogon)}} | export-csv c:\users\<username>\desktop\export.csv -notypeinformation 
 
# Get the Forest functional level 
(Get-ADForest).ForestMode 
  
# Get the Domain functional level 
import-module activedirectory 
(Get-ADDomain).DomainMode 
  
# Get the domain distinguished name 
Import-Module activedirectory 
$domdn = Get-ADDomain | select -ExpandProperty DistinguishedName 
$domdn 
$dcOU = Get-ADDomain | select -ExpandProperty DomainControllersContainer 
$dcOU 
  
# Find all Windows Server 2012 Servers on a domain 
Get-ADComputer -LDAPFilter "(&(objectcategory=computer)(OperatingSystem=*2012*))" 
  
# Get all AD objects by OS 
Import-Module activedirectory 
# get-adcomputer -filter {OperatingSystem -like "*XP*"}m 
$server = Get-ADComputer -Filter {OperatingSystem -like "*XP*"} ` 
-Properties Name, DNSHostName, OperatingSystem, ` 
OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, ` 
whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, ` 
DistinguishedName | 
Select-Object Name, DNSHostName, OperatingSystem, ` 
OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, ` 
whenCreated, whenChanged, ` 
@{name='LastLogonTimestampDT';` 
Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, ` 
@{name='Owner';` 
Expression={$_.nTSecurityDescriptor.Owner}}, ` 
DistinguishedName 
# ($server | Measure-Object).Count 
$server | Out-GridView 
  
# Get properties of all users, build on this as required for particular user such as piping to a ForEach 
Get-Aduser -filter * -properties * 
  
# Get Schema version details 
$RootDSE= ([ADSI]"").distinguishedName 
# Forest Schema (rangeUpper) 
([ADSI]"LDAP://CN=ms-Exch-Schema-Version-Pt,CN=Schema,CN=Configuration,$RootDSE").rangeUpper 
# Forest Version 
([ADSI]"LDAP://cn=<ExhangeOrg>,cn=Microsoft Exchange,cn=Services,cn=Configuration,$RootDSE").objectVersion 
# Domain Version 
([ADSI]"LDAP://CN=Microsoft Exchange System Objects,$RootDSE").objectVersion 
  
# Count the amount of members in an AD group 
(Get-ADGroupMember -Identity "GROUPNAME").count 
  
# Get a list of enabled users in a specific OU and output to a CSV. User select-object to output the data and -NoTypeInformation to remove unnecessary outputs. 
Get-ADUser -Filter {(Enabled -eq $true)} -SearchBase "ou=OU NAME,ou=OU NAME,dc=DOMAIN,dc=local" | select-object Name, GivenName, Surname, UserPrincipalName | Export-Csv $env:USERPROFILE\desktop\EnabledUsers.csv  -NoTypeInformation 
  
# Get all computer accounts 
$computerAccounts = ([ADSISearcher]"(&(objectcategory=computer)(name=*))").FindAll() 
​ 
# Get the FSMO Roles for domain 
Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator 
  
# Get FSMO roles for forest 
Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster 
  
# Details of an OU 
Get-ADUser -Filter * -SearchBase "OU=OUName,OU=OUName,DC=domain,DC=local" | Select-Object -Property SamAccountName | Sort-Object -Property SamAccountName | export-CSV C:\users.csv 
  
# Is the system 32bit or 64bit? 
if ([System.IntPtr]::Size -eq 4) { "32-bit" } else { "64-bit" } 
  
# AD user objects by time span 
# http://windowsitpro.com/systems-management/use-get-aduser-find-inactive-ad-users 
search-adaccount -accountinactive -usersonly -timespan "195" 
 
# Export GPOs   
Get-GPOReport -All -Domain ad.domain.local -Server server1 -ReportType HTML -Path C:\report.html   
   
# Get disabled computer accounts   
Search-ADAccount -AccountDisabled -ComputersOnly | Out-File C:\DisabledComputerAccounts.txt   
   
# Get disabled user accounts   
Search-ADAccount -AccountDisabled -UsersOnly | Out-File C:\DisabledUserAccounts.txt   
   
# Get domain admins   
get-adgroupmember -identity "domain admins" | ft name,samaccountname | Out-File C:\DomainAdmins   
   
# Get empty groups   
Get-ADGroup -Filter * -Properties Members | where { $_.Members.Count -eq 0 } | Out-File C:\emptygroups.txt   
   
# Get empty OUs   
Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Where { -not(Get-ADObject -Filter 'Name -like " *"' -SearchBase $_.DistinguishedName -SearchScope OneLevel -ResultSetSize 1 -ErrorAction SilentlyContinue)} | select DistinguishedName | Out-File c:\emptyOU.txt   
   
# Get inactive computers   
Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan "90"| Out-File c:\InactiveComputerAccounts.txt   
   
# Get inactive users   
Search-ADAccount -AccountInactive -UsersOnly -TimeSpan "90"| Out-File c:\InactiveUserAccounts.txt   
   
# Never expiring passwords   
Search-ADAccount -PasswordNeverExpires | Out-File C:\UserNonExpiringPassword   
 
# Get home directories of users   
get-content "C:\Scripts\List Home Directorys\users.txt" | foreach {   
get-aduser -identity $_ -properties * | fl samaccountname,homedirectory   
}   
   
# Finding groups of logged on  user   
try    
{     
  $groups = ([Security.Principal.WindowsIdentity]::GetCurrent()).Groups |    
  ForEach-Object {   
    $_.Translate([Security.Principal.NTAccount])   
  } | Sort-Object   
}    
catch    
{    
  Write-Warning 'Groups could not be retrieved.'    
}   
$groups   
 
# RSOP 
import-module grouppolicy 
Get-ADUser -filter 'surname -like "morson"'  
Get-ADDomain | select-object NetBiosName  
Get-GPResultantSetOfPolicy -user domain\user -computer server -ReportType Html -Path C:\rsop.html 
 
# Get all GPOs and output as individual HTML files   
Get-GPO -All | % {$_.GenerateReport('html') | Out-File "$($_.DisplayName).htm"}   
Get-Gpo -All | ForEach-Object { Get-GPOReport -Name $_.displayname -ReportType HTML -Path (join-path -Path "c:\temp\gporeports\" -ChildPath "$($_.displayname).HTML")}   
 
# Get list of users in a group 
Get-AdGroupMember –identity 'group name' | select –ExpandProperty name  
 
# Is Account Locked Out and Unlock 
Search-ADAccount -LockedOut -UsersOnly | Where {$_.SAMAccountName -eq 'user'} 
# Unlock account 
Unlock-ADAccount -Identity user
 
# Amend Attributes for Active Directory User Objects in Bulk from a List of Email Addresses 
Import-Module activedirectory 
$csv = Import-CSV "C:\users\username\desktop\filename.csv" 
foreach($user in $csv){ 
$userMail = $user.mail 
$userSAM = Get-ADUser -Filter {mail -eq $userMail} -Properties SamAccountName 
foreach ($userID in $userSAM){ 
Add-Content -Path "C:\users\username\desktop\SamAccountName.txt" -Value $userID.SamAccountName  
} 
} 
 
$users = get-content "C:\users\username\desktop\SamAccountName.txt" 
foreach ($user in $users) { 
write-host "Updating $user..." 
Get-ADUser -Filter {SamAccountName -eq $user} -Properties * | select -expandproperty SamAccountName | Set-ADUser -Department "Department" -Company "Company" 
} 
 
# Check when a user object attribute change 
import-module activedirectory 
Get-AdUser <username> 
repadmin /showobjmeta mhrapvdom01 "CNPATH" 
 
# Enable Kerberos logging on local laptop 
Create new regkey called LogLevel as a REG_DWORD with value 1 
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA\Kerberos\Parameters 
Use ALTools.exe to then monitor for next bad password and check against the Kerberos event 
 
# groups im a member of 
(Get-ADUser user -Properties MemberOf | Select-Object MemberOf).MemberOf 
 
#Quick check for user 
get-user -Identity "*Sierra*" | fl 
 
# Check which accounts have local admin privileges to a server 
$Recurse = $true 
$GroupName = 'Administrators' 
Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
$ct = [System.DirectoryServices.AccountManagement.ContextType]::Machine 
$group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($ct,$GroupName) 
$LocalAdmin = $group.GetMembers($Recurse) | select @{N='Domain'; E={$_.Context.Name}}, samaccountName, @{N='ObjectType'; E={$_.StructuralObjectClass}} -Unique 
$LocalAdmin = $LocalAdmin | Where-Object {$_.ObjectType -eq "user"} 
$LocalAdmin 
 
# Password status of users   
Import-Module ActiveDirectory   
$FileName="Reports\PasswordStatus"+(Get-Date -Format ddMMyy)+".csv"   
Get-ADUser -filter * -properties sAMAccountName, Name, CanonicalName, Description, whenCreated, PasswordNeverExpires, PasswordLastSet, PasswordExpired, LogonCount, LastLogonDate, LockedOut, CannotChangePassword, PasswordNotRequired, AccountExpirationDate, LastBadPasswordAttempt, UserAccountControl | select sAMAccountName, Name, CanonicalName, Description, whenCreated, PasswordNeverExpires, PasswordLastSet, PasswordExpired, LogonCount, LastLogonDate, LockedOut, CannotChangePassword, PasswordNotRequired, AccountExpirationDate, LastBadPasswordAttempt, @{n="PasswordExpires";e={if ($_.PasswordNeverExpires -eq $false){$_.PasswordLastSet+(Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge}}}, @{n="AccountDisabled";e={($_.UserAccountControl -band 2) -ne 0}} | Export-CSV $FileName -NoTypeInformation   
  
# List all domain controllers    
Import-module activedirectory   
Get-ADDomainController -Filter * | Select-Object Name,Site,IPv4Address,OperatingSystem,Forest |ft –AutoSize   
   
# Set AD Computer object description and move - good for decommission of computer objects from a list   
$date = get-date -format "dd/MM/yyyy"   
$ref = read-host "Please enter RFC Number"   
Get-Content "c:\scripts\computer decom\computers.txt" | % {   
Set-AdComputer -identity $_ -description "Decommissioned $date - $ref"   
Get-AdComputer -identity $_ | Move-AdObject -targetpath 'OU=To Be Deleted,DC=ad,DC=domain,DC=local'   
}   
 
# Get the DistinguishedName of an AD user   
Get-Aduser -Identity user | select -ExpandProperty DistinguishedName   
 
# Check DC health   
dcdiag /q and repadmin /replsum   