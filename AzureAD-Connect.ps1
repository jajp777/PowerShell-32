# Import the ADSync module	 
Import-Module ADSync 
 
# Get the Sync Scheduler details	 
Get-ADSyncScheduler 
 
# Force Syncs
# https://docs.microsoft.com/en-us/azure/active-directory/connect/active-directory-aadconnectsync-feature-scheduler
Start-ADSyncSyncCycle -PolicyType delta
Start-ADSyncSyncCycle -PolicyType intial