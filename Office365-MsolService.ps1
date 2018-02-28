# Get a list of Service Plans
Get-MsolAccountSku | Select -ExpandProperty ServiceStatus

# Microsoft Forms - Disabling User Licensing via PowerShell.
# https://technet.microsoft.com/en-us/library/mt671130.aspx?f=255&MSPPError=-2147217396
# https://blogs.technet.microsoft.com/office_online_support_blog/2017/08/04/microsoft-forms-disabling-user-licensing-via-powershell/

# Get tentant information
Get-MsolAccountSku

# Office 365 (Open the Windows Azure Active Directory Module)
$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential

# Set default domain in Office 365  
set-msoldomain -name dalemorson.com -IsDefault  

# Change user UPN  
Set-MsolUserPrincipalName -UserPrincipalName dale@dale.onmicrosoft.com -NewUserPrincipalName dale@dalemorson.com  

# View a User Object in Office 365 for the ImmutableID: 
Get-MsolUser -UserPrincipalName first.lastname@domain.com | Select-Object UserprincipalName,ImmutableID 