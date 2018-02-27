 Function Connect-ExchangeOnPrem {
    param(
         [Parameter(Mandatory=$true)]
         [System.Management.Automation.PSCredential]
         [System.Management.Automation.Credential()]
         $Credentials
         )
     $DomainPath = Get-ADDomain | Select DistinguishedName
     $DomainPath = $DomainPath.DistinguishedName
     [String]$DomainPath = "CN=Configuration,$DomainPath"
     Write-Host "Connecting to Exchange On-Premise" -fore Cyan
     $GetExchangeServers = Get-ADObject -LDAPFilter "(objectClass=msExchExchangeServer)" -SearchBase $DomainPath | Select-Object Name
     Foreach($GetExchangeServer in $GetExchangeServers)
     {
         $ExchName = $GetExchangeServer.Name
         $OnPremExchangeURL = â€œhttp://$ExchName.mca.gsi.gov.uk/PowerShell/â€
         $Section = Get-PSsession | Select Availability, ConfigurationName
         If (($Section.Availability -ne 'Available') -And ($Section.ConfigurationName -ne 'Microsoft.Exchange'))
         {
             Try
             {
             $OnPremSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $OnPremExchangeURL -Authentication Kerberos -Credential $Credentials -ErrorAction SilentlyContinue
             Import-PSSession -Session $OnPremSession -ErrorAction SilentlyContinue
             }
             Catch
             {
             }
         }
     }
 }
 # Connect-ExchangeOnPrem -Credentials(Get-Credential)