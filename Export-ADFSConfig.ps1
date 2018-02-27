$fileLocation = "C:\Scripts\Export-ADFSConfig\"
$date = (Get-Date -format dd-MM-yyyy)
New-Item -path $fileLocation -name "Backup $(Get-Date -format dd-MM-yyyy)" -ItemType directory -ErrorAction SilentlyContinue
$fileLocation = $fileLocation + "Backup $(Get-Date -format dd-MM-yyyy)\"
$width = 1000

Import-Module ADFS

Get-AdfsAdditionalAuthenticationRule | Out-File -FilePath $($fileLocation + "Get-AdfsAdditionalAuthenticationRule" + ".txt") -Width $width
Get-AdfsAttributeStore | Out-File -FilePath $($fileLocation + "Get-AdfsAttributeStore" + ".txt") -Width $width
Get-AdfsAuthenticationProvider | Out-File -FilePath $($fileLocation + "Get-AdfsAuthenticationProvider" + ".txt") -Width $width
Get-AdfsAuthenticationProviderWebContent | Out-File -FilePath $($fileLocation + "Get-AdfsAuthenticationProviderWebContent" + ".txt") -Width $width
Get-AdfsCertificate | Out-File -FilePath $($fileLocation + "Get-AdfsCertificate" + ".txt") -Width $width
Get-AdfsClaimDescription | Out-File -FilePath $($fileLocation + "Get-AdfsClaimDescription" + ".txt") -Width $width
Get-AdfsClaimsProviderTrust | Out-File -FilePath $($fileLocation + "Get-AdfsClaimsProviderTrust" + ".txt") -Width $width
Get-AdfsClient | Out-File -FilePath $($fileLocation + "Get-AdfsClient" + ".txt") -Width $width
Get-AdfsDeviceRegistration | Out-File -FilePath $($fileLocation + "Get-AdfsDeviceRegistration" + ".txt") -Width $width
Get-AdfsDeviceRegistrationUpnSuffix | Out-File -FilePath $($fileLocation + "Get-AdfsDeviceRegistrationUpnSuffix" + ".txt") -Width $width
Get-AdfsEndpoint | Out-File -FilePath $($fileLocation + "Get-AdfsEndpoint" + ".txt") -Width $width
Get-AdfsGlobalAuthenticationPolicy | Out-File -FilePath $($fileLocation + "Get-AdfsGlobalAuthenticationPolicy" + ".txt") -Width $width
Get-AdfsGlobalWebContent | Out-File -FilePath $($fileLocation + "Get-AdfsGlobalWebContent" + ".txt") -Width $width
Get-AdfsNonClaimsAwareRelyingPartyTrust | Out-File -FilePath $($fileLocation + "Get-AdfsNonClaimsAwareRelyingPartyTrust" + ".txt") -Width $width
Get-AdfsProperties | Out-File -FilePath $($fileLocation + "Get-AdfsProperties" + ".txt") -Width $width
Get-AdfsRegistrationHosts | Out-File -FilePath $($fileLocation + "Get-AdfsRegistrationHosts" + ".txt") -Width $width
Get-AdfsRelyingPartyTrust | Out-File -FilePath $($fileLocation + "Get-AdfsRelyingPartyTrust" + ".txt") -Width $width
Get-AdfsRelyingPartyWebContent | Out-File -FilePath $($fileLocation + "Get-AdfsRelyingPartyWebContent" + ".txt") -Width $width
Get-AdfsSslCertificate | Out-File -FilePath $($fileLocation + "Get-AdfsSslCertificate" + ".txt") -Width $width
Get-AdfsSyncProperties | Out-File -FilePath $($fileLocation + "Get-AdfsSyncProperties" + ".txt") -Width $width
Get-AdfsWebApplicationProxyRelyingPartyTrust | Out-File -FilePath $($fileLocation + "Get-AdfsWebApplicationProxyRelyingPartyTrust" + ".txt") -Width $width
Get-AdfsWebConfig | Out-File -FilePath $($fileLocation + "Get-AdfsWebConfig" + ".txt") -Width $width
Get-AdfsWebTheme | Out-File -FilePath $($fileLocation + "Get-AdfsWebTheme" + ".txt") -Width $width

netsh http show sslcert | Out-File -FilePath $($fileLocation + "netsh-http-show-sslcert" + ".txt") -Width $width

Send-MailMessage -To "recipient1","recipient2" -From "sender@domain.com" -SmtpServer servername -Subject "ADFS Configuration has been exported successfully for $date" -body "Export saved to C drive on SERVER:`n$filelocation"