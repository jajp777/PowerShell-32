Function Get-AzureRmVmsAllSubscriptions {

# Get-AzureRmVmsAllSubscriptions
# Get-AzureRmVmsAllSubscriptions | Select-Object Name,ResourceGroupName,Tags,Location
# Get-AzureRmVmsAllSubscriptions | Out-GridView
# (Get-AzureRmVmsAllSubscriptions).count
# Get-AzureRmVmsAllSubscriptions | Group-Object ResourceGroupName | Sort-Object Count

# Get all subscriptions    
$subscriptions = Get-AzureRmSubscription

# Extract only the subscription IDs
$subscriptionIds = @($subscriptions | Select-Object -ExpandProperty SubscriptionId)

# Create an array called $vms
$vms = @()

# Use a foreach to loop through each subscription
foreach($subscriptionId in $subscriptionIds) {
    [void](Set-AzureRmContext -SubscriptionID $subscriptionId)
    $currentVMs = Get-AzureRmVM | select-object *
    $vms += $currentVMs
}

# Output returned objects
$vms
 
}