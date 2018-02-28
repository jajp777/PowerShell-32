# Activate Server 2016 / Windows 10 Images
# https://blogs.msdn.microsoft.com/mast/2017/06/14/troubleshooting-windows-activation-failures-on-azure-vms/
iex "$env:windir\system32\cscript.exe $env:windir\system32\slmgr.vbs /skms kms.core.windows.net:1688"
1..12 | % { iex "$env:windir\system32\cscript.exe $env:windir\system32\slmgr.vbs /ato" ; start-sleep 5 }
 
# Login to AzureRM Account  
Login-AzureRmAccount  
Add-AzureRmAccount
  
# Start, Start, Restart  
Stop-AzureRmVM -ResourceGroupName rg -Name vm  
Start-AzureRmVM -ResourceGroupName rg -Name vm 
Restart-AzureRmVM -ResourceGroupNamerg rg -Name vm 
  
# Find the IP and FQDN of a VM and then RDP to it
$PublicAddress= (Get-AzureRmPublicIpAddress -ResourceGroupName rgg)[0]  
$IP = $PublicAddress.IpAddress  
$FQDN = $PublicAddress.DnsSettings.Fqdn   
Start-Process -FilePath mstsc.exe -ArgumentList "/v:$FQDN"  
Start-Process -FilePath mstsc.exe -ArgumentList "/v:$IP" 
 
#Get a list of private IPs  
Get-AzureRmResourceGroup | Get-AzureRmNetworkInterface | ForEach 
{ $Interface = $_.Name; $IPs = $_ | Get-AzureRmNetworkInterfaceIpConfig | Select PrivateIPAddress; Write-Host $Interface $IPs.PrivateIPAddress } 
 
# Get a list of Azure locations  
Get-AzureRmLocation| Where { $_.Displayname-match 'location' } | Format-Table  
 
# Get list of VMs in RG  
Get-AzureRmVM -ResourceGroupName rg | select -ExpandProperty name  
 
# Get list of VM public IPs  
Get-AzureRmPublicIpAddress -ResourceGroupName rg | select Name,IpAddress| ft -AutoSize

# AzureRM Maintenance Notifications
https://docs.microsoft.com/en-us/azure/virtual-machines/windows/maintenance-notifications
Get-AzureRmVM -ResourceGroupName rgName -Name vmName –Status
Get-AzureRmVM -ResourceGroupName rgName –Status
# Using information from the function in the previous section, the following starts maintenance on a VM if IsCustomerInitiatedMaintenanceAllowed is set to true.
Restart-AzureRmVM -PerformMaintenance -name $vm.Name -ResourceGroupName $rg.ResourceGroupName

# Check all VMs for maintenance notifications
Select-AzureRmSubscription -Subscription "Subscription"
$rgList= Get-AzureRmResourceGroup 
for ($rgIdx=0; $rgIdx -lt $rgList.Length ; $rgIdx++)
{
    $rg = $rgList[$rgIdx]        
$vmList = Get-AzureRMVM -ResourceGroupName $rg.ResourceGroupName 
    for ($vmIdx=0; $vmIdx -lt $vmList.Length ; $vmIdx++)
    {
        $vm = $vmList[$vmIdx]
        $vmDetails = Get-AzureRMVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Status
            if ($vmDetails.MaintenanceRedeployStatus )
        {
            Write-Output "VM: $($vmDetails.Name)  IsCustomerInitiatedMaintenanceAllowed: $($vmDetails.MaintenanceRedeployStatus.IsCustomerInitiatedMaintenanceAllowed) $($vmDetails.MaintenanceRedeployStatus.LastOperationMessage)"               
        }
        }
}   