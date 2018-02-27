# Output a list of CSVs for each license and list each user with that particular license.

$VerbosePreference = 'Continue'
write-host "Connecting to Office 365..."
Import-Module MSOnline
Connect-MsolService -Credential(Get-Credential
)

# Get a list of all licences that exist within the tenant
$licensetype = Get-MsolAccountSku | Where {$_.ConsumedUnits -ge 1}

Write-Verbose "License types are:" 
$lts = $licensetype| select -expandproperty accountskuid | Format-Table -Autosize | Out-String
Write-Verbose $lts

Write-Verbose "Getting all users (may take a while) ..."
$allusers = Get-MsolUser -all 
Write-Verbose ("There are " + $allusers.count + " users in total")

# Loop through all licence types found in the tenant
foreach ($license in $licensetype) 
{ 
 # Build and write the Header for the CSV file
    $LicenseTypeReport = "Office365_" + ($license.accountskuid -replace ":","_") + "_" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".csv"
    Write-Verbose ("New file: "+ $LicenseTypeReport)

 $headerstring = "DisplayName;UserPrincipalName;JobTitle;Office;AccountSku"
 
 foreach ($row in $($license.ServiceStatus)) 
 {
  $headerstring = ($headerstring + ";" + $row.ServicePlan.servicename)
 }
 
 Out-File -FilePath $LicenseTypeReport -InputObject $headerstring -Encoding UTF8 -append
 
 write-Verbose ("Gathering users with the following subscription: " + $license.accountskuid)

 # Gather users for this particular AccountSku
 $users = $allusers | where {$_.isLicensed -eq "True" -and $_.licenses.accountskuid -contains $license.accountskuid}

 # Loop through all users and write them to the CSV file
 foreach ($user in $users) {
  
        $thislicense = $user.licenses | Where-Object {$_.accountskuid -eq $license.accountskuid}
        $datastring = (($user.displayname -replace ","," ") + ";" + $user.userprincipalname + ";" + $user.Title + ";" + $user.Office + ";" + $license.SkuPartNumber)
  
  foreach ($row in $($thislicense.servicestatus)) {   
   # Build data string
   $datastring = ($datastring + ";" + $($row.provisioningstatus))
  }  
  Out-File -FilePath $LicenseTypeReport -InputObject $datastring -Encoding UTF8 -append
 }
} 

write-Verbose ("Script Completed.")