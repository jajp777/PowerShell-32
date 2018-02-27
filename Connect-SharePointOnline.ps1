Function Connect-SharePointOnline{
    param(
         [Parameter(Mandatory=$true)]
         [System.Management.Automation.PSCredential]
         [System.Management.Automation.Credential()]
         $Credentials,
         [Parameter(Mandatory=$true)]
         [string]$OrganisationName
         )
     Write-Host "Connecting to SharePoint Online" -fore Cyan
     # Check existing connection
     Try
     {
         Connect-SPOService -Url https://$OrganisationName-admin.sharepoint.com -Credential $Credentials
     }
     Catch
     {
            Write-Host "Unable to connect to SharePoint Online:- Run script again making sure to use the correct username and password" -BackgroundColor "Red" -ForegroundColor "Black"
         EXIT
     }
 }
 # Connect-SharePointOnline -Credentials(Get-Credential) -OrganisationName tenantname