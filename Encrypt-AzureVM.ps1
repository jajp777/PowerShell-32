# Login to AzureRM
Login-AzureRmAccount

# Set variables
$location = <location>
$VmRgName = <VM resource group>
$vmName = <VM to encrypt>
$rgName = <Key vault resource group>
$aadClientSecret = <secret>
$aadSecureClientSecret = ConvertTo-SecureString -String $aadClientSecret -AsPlainText -Force
$keyVaultName = <key vault name>
$keyEncryptionKeyName = <KEK key vault name>
$aadAzureAdObjectID = <object ID>

# Get the Azure AD application
$azureAdApplication = Get-AzureRmADApplication -ObjectId $aadAzureAdObjectID

# Get Key Vault
$keyVault = Get-AzureRmKeyVault -VaultName $keyVaultName

# Get Key Encryption Key (KEK)
$kek = Get-AzureKeyVaultKey -VaultName $keyVaultName -Name $keyEncryptionKeyName

# Get the virtual machine to be encrypted
$vm = Get-AzureRmVM -ResourceGroupName $VmRgName -Name $vmName

# Enable disk encryption on the VM for all disks
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $VmRgName -VMName $vm.name -AadClientID $servicePrincipal.ApplicationId -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $keyVault.VaultUri -DiskEncryptionKeyVaultId $keyVault.ResourceId -KeyEncryptionKeyUrl $kek.Key.Kid -KeyEncryptionKeyVaultId $keyVault.ResourceId -VolumeType All -Force

# Get the status of the encryption on the VM disks
Get-AzureRmVMDiskEncryptionStatus -ResourceGroupName $VmRgName -VMName $vm.Name

# Perform a VM backup 
# Perform a VM restore