# Lockdown Mode 
http://buildvirtual.net/a-look-at-esxi-5-lockdown-mode/ 

# To enable Lockdown Mode using PowerCLI you can run the following 
(get-vmhost esxi1.vmlab.loc | get-view).EnterLockdownMode() | get-vmhost | select Name,@{N="LockDown";E={$_.Extensiondata.Config.adminDisabled}} | ft -auto Name LockDown 

# To disable lockdown mode you can run
(get-vmhost esxi1.vmlab.loc | get-view).ExitLockdownMode() 
  
# Connect to a vCenter server 
Connect-VIServer -Server VCENTER -User DOMAIN\USER -Password PASSWORD 
  
# Get a list of all virtual machines and ESX host 
Get-VM | Select Name,VMHost | FT - AutoSize 
  
# Get the network settings for all host network adapters 
Get-VMHostNetworkAdapter | select VMhost, Name, IP, SubnetMask, Mac, PortGroupName, vMotionEnabled, mtu, FullDuplex, BitRatePerSec 
  
# Get a list of all virtual machine names and IP addresses 
Get-VM | Select Name, @{N="IP Address";E={@($_.guest.IPAddress[0])}} 
  
# Get a list of virtual machines that have E1000 vNICs 
Get-vm | ?{Get-networkadapter $_ | where-object {$_.type -like "*e1000*" }} 
  
# Get a list of all VMs with RDMs 
Get-VM | Get-HardDisk -DiskType RawPhysical,RawVirtual | Select Parent,Name,DiskType,ScsiCanonicalName,DeviceName 
  
# Count the total amount of ESXi hosts 
(Get-VMHost).count 
  
# Get CPU, RAM, PowerState and Name 
Get-VM | ft -autosize 
  
# Get Hard Disk Information 
# http://www.vnugglets.com/2013/12/get-vm-disks-and-rdms-via-powercli.html 
Get-VMDiskAndRDM -vmName myVM01 -ShowVMDKDatastorePath | ft -a 
  
# Get all VMs with RDMs 
Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select Parent,Name,DiskType,ScsiCanonicalName,DeviceName | fl 
 
# Working with log files (SCSI example) 
(Get-Log -VMHost (Get-VMHost 192.168.0.235) vmkernel).Entries 
(Get-Log -VMHost (Get-VMHost 192.168.0.235) vmkernel).Entries | Where {$_ -like 'scsi*'} 
# http://www.virten.net/vmware/esxi-scsi-sense-code-decoder/?host=0&device=2&plugin=0&sensekey=5&asc=24&ascq=0 
  
# Performance stats 
Get-Folder | Where-Object {$_.name -eq "NGN"} | Get-VM | Where {$_.PowerState -eq "PoweredOn"} | ` 
Select Name, Host, NumCpu, MemoryMB, @{N="Cpu.UsageMhz.Average";E={[Math]::Round((($_ |Get-Stat -Stat ` 
cpu.usagemhz.average -Start (Get-Date).AddHours(-24)-IntervalMins 5 -MaxSamples (12) ` 
|Measure-Object Value -Average).Average),2)}}, @{N="Mem.Usage.Average";E={[Math]::Round((($_ |` 
Get-Stat -Stat mem.usage.average -Start (Get-Date).AddHours(-24)-IntervalMins 5 -MaxSamples (12) |` 
Measure-Object Value -Average).Average),2)}} | Export-Csv c:\users\dmorson\desktop\stats.csv 
  
# Rescan all HBA adapters using PowerCLI 
# https://www.vmadmin.co.uk/resources/48-vspherepowercli/255-powerclirescanallhbas 
Get-Cluster | Get-VMHost | Get-VMHostStorage -RescanAllHBA 
get-cluster -name "MY CLUSTER" | get-vmhost | Get-VMHostStorage -RescanAllHBA 
  
# Get the serial for each host 
connect-viserver "VC01"; 
$table = @(); 
$servers = get-vmhost | sort name; 
foreach ($server in $servers) { 
    $row = "" | select name, serial; 
    $row.name = $server.name; 
    $esxcli = get-esxcli -vmhost $server.name; 
    $row.serial = $esxcli.hardware.platform.get().serialnumber; 
    $table = $table + $row; 
} 
$table | export-csv c:\temp\serial.csv 
  
# Count all virtual nics 
(get-vm | get-networkadapter).count 