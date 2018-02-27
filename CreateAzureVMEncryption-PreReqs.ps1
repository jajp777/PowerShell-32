# Login to AzureRM
Login-AzureRmAccount

# Set variables
$location = <location>
$rgName = <Key vault resource group>
$aadAppDisplayName = <name of Azure AD app>
$aadAppHomePage = <http:// app home page>
$aadAppURI = $aadAppHomePage
$aadClientSecret = <secret>
$aadSecureClientSecret = ConvertTo-SecureString -String $aadClientSecret -AsPlainText -Force
$keyVaultName = <key vault name>
$keyEncryptionKeyName = <KEK key vault name>

# Create an Azure AD application
$azureAdApplication = New-AzureRmADApplication -DisplayName $aadAppDisplayName -HomePage $aadAppHomePage -IdentifierUris $aadAppURI -Password $aadSecureClientSecret

# Create a service principal for the Azure AD application
$servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId

# Create a Key Vault
$keyVault = New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $rgName -Location $location

# Add access for the Azure AD application on the Key Vault
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $servicePrincipal.ApplicationId -PermissionsToKeys wrapkey,backup,get,list -PermissionsToSecrets set,get,list -ResourceGroupName $rgName

# Add access for the Azure platform to access the Key Vault                                
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -EnabledForDiskEncryption

# Add Key Encryption Key (KEK) to the Key Vault
$kek = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name $keyEncryptionKeyName -Destination "Software"