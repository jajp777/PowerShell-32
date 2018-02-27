 Function Connect-AzureAD {
   param(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credentials
        )
    Write-Host "Connecting to Azure AD" -fore Cyan
    Try
    {
        Connect-MsolService -credential $Credentials -ErrorAction Stop
    }
    Catch
    {
       Write-Host "Unable to connect to the MSOL Service:- Run script again making sure to use the correct username and password" -BackgroundColor "Red" -ForegroundColor "Black"
        EXIT
    }
}
# Connect-AzureAD -Credentials(Get-Credential)