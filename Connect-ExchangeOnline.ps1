Function Connect-ExchangeOnline{
    param(
         [Parameter(Mandatory=$true)]
         [System.Management.Automation.PSCredential]
         [System.Management.Automation.Credential()]
         $O365Creds
         )
     Write-Host "Connecting to Exchange Online" -fore Cyan
     # Check existing connection
     Try
     {
         If ((Get-PSSession | Where {$_.ComputerName -like "*outlook.office365.com*"}) -eq $Null) {
             $ExchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365Creds -Authentication Basic -AllowRedirection
             Import-PSSession $ExchangeOnlineSession
         }
     }
     Catch
     {
        Write-Host "Unable to connect to Exchange Online:- Run script again making sure to use the correct username and password" -BackgroundColor "Red" -ForegroundColor "Black"
         EXIT
     }
 }
# Connect-ExchangeOnline -O365Creds(Get-Credential)