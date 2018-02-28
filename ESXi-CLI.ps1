# You can check if lockdown mode is enabled using the CLI by running: 
vim-cmd -U dcui vimsvc/auth/lockdown_is_enabled 

# To enable lockdown mode: 
vim-cmd -U dcui vimsvc/auth/lockdown_mode_enter 

# And to disable lockdown mode: 
vim-cmd -U dcui vimsvc/auth/lockdown_mode_exit 
 
# specify which vmkernel port to use for outgoing ICMP traffic 
vmkping -I vmkX x.x.x.x 
 
# Check if ESXi host is running out of iNodes 
stat -f / 

# Clear iNodes  
# http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2037798 
/etc/init.d/sfcbd-watchdog stop 
cd /var/run/sfcb 
rm [0-2]* 
rm [3-6]* 
rm [7-9]* 
rm [a-c]* 
rm [d-f]* 
/etc/init.d/sfcbd-watchdog start 
 
# Restart management agents on an ESXi host  
# http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1003490 
/etc/init.d/hostd restart 
/etc/init.d/vpxa restart 
 
# ESXTOP 
# http://www.yellow-bricks.com/esxtop/ 
# Open console session or ssh to ESX(i) and type: 
esxtop 

# By default the screen will be refreshed every 5 seconds, change this by typing: 
s 2 

# Visual ESXTOP
# https://labs.vmware.com/flings/visualesxtop 
 
# Lists all vm's running on hypervisor and provides vmid 
vim-cmd vmsvc/getallvms 
 
# Powers off vmid referenced from getallvms command 
vim-cmd vmsvc/power.off vmid 
 
# Powers off vmid referenced from getallvms command 
vim-cmd vmsvc/power.on vmid 
 
# Reboots vmid referenced from getallvms command 
vim-cmd vmsvc/power.reboot vmid 
 
# Deletes the vmdk and vmx files from disk 
vim-cmd vmsvc/destroy vmid 
 
# Puts hypervisor into maintenance mode 
vim-cmd hostsvc/maintenance_mode_enter 
 
# Takes hypervisor out of maintenance mode 
vim-cmd hostsvc/maintenance_mode_exit 
 
# Registers vm in hypervisor inventory 
vim-cmd solo/registervm /vmfs/vol/datastore/dir/vm.vmx 
 
# Unregisters vm with hypervisor 
vim-cmd vmsvc/unregister vmid 
 
# Starts vmware tools installation for VM 
vim-cmd vmsvc/tools.install vmid 
 
# Provides information about hypervisor networking 
vim-cmd hostsvc/net/info 
 
# Shows daemons running on hypervisor. Can also be used for configuration. 
chkconfig -l 
 
# Same as linux top for vmware 
esxtop 
 
# List of vmkernel errors 
vmkerrcode -l 
 
# Lists a LOT of information about the esx host 
esxcfg-info 
 
# Lists information about NIC's. Can also be used for configuration. 
esxcfg-nics -l 
 
# Lists information about virtual switching. Can also be used for configuration. 
esxcfg-vswitch -l 
 
# Provides console screen to ssh session 
dcui 
 
# Vmware interactive shell 
vsish 
 
# Read System Event Log of server  
decodeSel /var/log/ipmi_sel.raw 