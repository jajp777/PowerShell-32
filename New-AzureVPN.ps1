# Author: Dale Morson
# Email: dale.morson@nttdata.com
# Date: 14/05/17

#region RESUABLE CONSTANTS

# Constants for reusable menu system

$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes','Description.'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No','Description.'
$exit = New-Object System.Management.Automation.Host.ChoiceDescription '&Exit','Description.'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit)

#endregion

#region INSTALL OR FORCE UPDATES OF AZURERM MODULE

Clear-Host # Begin region by clearing the last screen

Write-Host ''
Write-Host '---------------'
Write-Host 'AzureRM module.' # section title
Write-Host '---------------'
Write-Host ''
$message = 'Force a check and install of AzureRM Modules?'
$result = $host.ui.PromptForChoice($title, $message, $options, 1)

switch ($result) {
    0{
    
        # Check user is currently elevated. A warning will appear if not.
        
        If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] 'Administrator'))
        {
            Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator."
            Write-Host 'Press any key to continue...'
            [void][System.Console]::ReadKey($true)
            Exit
        }

        Write-Host ''
        Write-Host 'Installing the latest AzureRM Modules.'
        Write-Host ''
        Install-Module AzureRM -Force 
        Write-Host 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)  
        Clear-Host    
    }1{
        Write-Host ''
        Write-Warning 'You skipped checking for and installing the latest AzureRM modules.'
        Write-Host ''
        Write-Host 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)
        Clear-Host
    }2{
        Write-Host 'Cancelled, exiting the script...'
        Write-Host ''
        Exit
    }
}

Clear-Host

#endregion

#region LOGIN TO CUSTOMER AZURE ACCOUNT

Clear-Host

Write-Host '------------------------'
Write-Host 'Customers Azure account.'
Write-Host '------------------------'
Write-Host ''
Write-Host 'A new window will appear prompting for credentials.'

Login-AzureRmAccount

Write-Host 'Press any key to continue...'
[void][System.Console]::ReadKey($true)

Clear-Host

#endregion

#region CUSTOMER CHARACTERS

# Future versions, prompt whether user wants to use the prefix option (ask for prefix, root and suffix) or enter a new name for each object.

Clear-Host

Write-Host '---------------------------'
Write-Host 'Resource naming convention.'
Write-Host '---------------------------'
Write-Host ''
Write-Host 'For any new objects created a naming convention will be used.'
Write-Host '- Enter three characters for the Prefix.'
Write-Host '- Enter three characters for the Root.'
Write-Host '- The Suffix will be the abbreviated letters of the object created, i.e. Virtual Network will be VN.'
Write-Host ''
Write-warning "Don't worry, characters will be changed to uppercase."
Write-Host ''

[string]$prefixPrompt = 'Enter three characters for the Prefix part of the naming convention:' 

Do {  

    Write-Host $prefixPrompt
    
    $prefix = Read-Host 
    
    [string]$prefixPrompt = 'Your entry was not valid, please try again:'} 
    
While ($prefix.length -gt 3)

$prefix = $prefix.ToUpper()

[string]$rootPrompt = 'Enter three characters for the Root part of the naming convention:'

Do {  

    Write-Host $rootPrompt
    
    $root = Read-Host 
    
    [string]$rootPrompt = 'Your entry was not valid, please try again:'} 
    
While ($root.length -gt 3)

$root = $root.ToUpper()

Write-Host ''
Write-Host "$prefix will be used for the Prefix." 
Write-Host "$root will be used for the Root." 
Write-Host ''

Write-Host 'Press any key to continue...'
[void][System.Console]::ReadKey($true)

Clear-Host

#endregion

#region RESOURCE GROUP

Clear-Host

Write-Host '----------------'
Write-Host 'Resource Groups.'
Write-Host '----------------'
Write-Host ''

$message = 'Create a new Resource Group?'
$result = $host.ui.PromptForChoice($title, $message, $options, 1)

switch ($result) {
    0{
        Write-Host ''
        Write-Host 'Select a Resource Group Location'
        $array = @(Get-AzureRmLocation | select-object -ExpandProperty DisplayName) 
        $menu = @{}
        for ($i=1;$i -le $array.count; $i++) 
        { Write-Host "$i. $($array[$i-1])"
        $menu.Add($i,($array[$i-1])) }
        Write-Host ''
        [int]$ans = Read-Host 'Select a location'
        $selection = $menu.Item($ans) ; $Location = $selection
        Write-Host ''
        Write-Host "You have chosen $location"
        $RG = $Prefix + $root + 'RG'
        Write-Host ''
        Write-Host "Creating a new Resource Group $RG in $Location"
        New-AzureRmResourceGroup -Name $RG -Location $Location
        Write-Host ''
        $NewRG = Get-AzureRmResourceGroup -name $RG -Location $Location
            if(-not $NewRG){
                Write-Host "The Resource Group $RG was not created successfully"
                break
            }
                else
            {
                Write-Host "The Resource Group $RG was created successfully"
                Write-Host '' 
                Write-Host 'Press any key to continue...'
                [void][System.Console]::ReadKey($true)

                Clear-Host
            }
       
    }1{
            Write-Host ''
            
            $array = @(Get-AzureRmResourceGroup | select-object -ExpandProperty ResourceGroupName) # Place existing Resource Groups into an array
            $menu = @{} # Create a new blank array
            for ($i=1;$i -le $array.count; $i++) 
            { Write-Host "$i. $($array[$i-1])"
            $menu.Add($i,($array[$i-1])) }
            Write-Host ''
            [int]$ans = Read-Host 'Select a Resource Group'
            $selection = $menu.Item($ans) ; $RG = $selection
            $Location = Get-AzureRmResourceGroup -name $RG | Select-Object -ExpandProperty Location
            Write-Host ''
            Write-Host "The Resource Group $RG has been selected"
            Write-Host '' 
            Write-Host 'Press any key to continue...'
            [void][System.Console]::ReadKey($true)

            Clear-Host

    }2{
        Write-Host 'Cancelled, exiting the script...'
        Write-Host ''
        Exit
    }
}

Clear-Host

#endregion

#region VIRTUAL NETWORK

Clear-Host

Write-Host '----------------------------'
Write-Host 'Virtual Network and Subnets.'
Write-Host '----------------------------'
Write-Host ''
Write-Host ''

$message = 'Create a new Virtual Network and Subnets?'
$result = $host.ui.PromptForChoice($title, $message, $options, 1)

switch ($result) {
    0{
        Write-Host ''
        Write-Host 'Create new Virtual Network and Subnets.'

        Write-Host ''
        $VNetName  = $Prefix + $root + 'VN'
        Write-Host "Virtual Network name: $vNetName" 
        Write-Host ''
      
        $SubName = $Prefix + $root + 'VNSN'
        Write-Host "Virtual Network Subnet name: $SubName"
        Write-Host ''

        write-Warning 'Virtual Network Gateway Subnet Name will be GatewaySubnet. This CANNOT be changed.'
        write-Warning 'DO NOT assign Virtual Machines to the Gateway Subnet.'
        Write-Host ''

        Write-Host 'Enter Address Space'
        $VNetPrefix = read-host 'Format: 192.168.10.0/24'
        Write-Host ''

        Write-Host 'Enter Virtual Network Subnet'
        $SubPrefix = read-host 'Format: 192.168.10.0/25'
        Write-Host ''

        Write-Host 'Enter Virtual Network Gateway Subnet'
        $GWSubPrefix = read-host 'Format: 192.168.10.128/29'

        Write-Host ''
        Write-Host 'Attempting to create the new Virtual Network, Virtual Network Subnet and Virtual Network Gateway Subnet.' 
        $sub = New-AzureRmVirtualNetworkSubnetConfig -Name $SubName -AddressPrefix $SubPrefix
        $gwsub = New-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix $GWSubPrefix

        $vnet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG -Location $Location -AddressPrefix $VNetPrefix -Subnet $sub, $gwsub 

        $NewSN = Get-AzureRmVirtualNetwork -ResourceGroupName $RG -name $VNetName
                    if(-not $NewSN){
                        Write-Host "The Virtual Network $VNetName was not created successfully"
                        Write-Host 'Press any key to continue...'
                        [void][System.Console]::ReadKey($true)
                    }
                        else
                    {
                        Write-Host ''
                        Write-Host "The Virtual Network $VNetName was created successfully"
                        Write-Host '' 
                        Write-Host 'Press any key to continue...'
                        [void][System.Console]::ReadKey($true)

                        Clear-Host
                    }
    }1{
         Write-Host '' 
         Write-Host 'Select an existing Virtual Network.'
         $array = @(Get-AzureRmVirtualNetwork -ResourceGroupName $RG | select-object -ExpandProperty Name) 
         $menu = @{}
         for ($i=1;$i -le $array.count; $i++) 
         { Write-Host "$i. $($array[$i-1])"
         $menu.Add($i,($array[$i-1])) }
         Write-Host ''
         [int]$ans = Read-Host 'Select a Virtual Network.'
         Write-Host '' 
         $selection = $menu.Item($ans) ; $vnet = $selection
         $newSN = Get-AzureRmVirtualNetwork -ResourceGroupName $RG -Name $vnet
         Write-Host "The Virtual Network $vnet has been selected."
         Write-Host '' 
         Write-Host 'Press any key to continue...'
         [void][System.Console]::ReadKey($true)
        }
    2{
        Write-Host 'Cancelled, exiting the script...'
        Write-Host ''
        Exit
    }
}

Clear-Host

#endregion

#region VIRTUAL NETWORK GATEWAY

Clear-Host

Write-Host '------------------------'
Write-Host 'Virtual Network Gateway.'
Write-Host '------------------------'
Write-Host ''
Write-Host ''

$message = 'Create a new Virtual Network Gateway?'
$result = $host.ui.PromptForChoice($title, $message, $options, 1)

switch ($result) {
  0{
    $GW = $Prefix + $root + 'VNG'
    $GWIPName = $Prefix + $root + 'VNGIP'
    Write-Host ''
    Write-Host "Virtual Network Gateway Public IP name: $GWIPName"
    Write-Host ''
    Write-Host 'Creating a new public IP address.'
    Write-Host ''
    #$subnet = Get-AzureRmVirtualNetwork -ResourceGroupName $RG -name $newSN | Get-AzureRmVirtualNetworkSubnetConfig -name GatewaySubnet | select-object -ExpandProperty AddressPrefix
    $subnet = Get-AzureRmVirtualNetworkSubnetConfig -name GatewaySubnet -VirtualNetwork $newSN
    $pip = New-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $RG -Location $Location -AllocationMethod Dynamic
    $ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPName -Subnet $subnet -PublicIpAddress $pip
    Write-Host ''
    Write-Host 'Creating the Virtual Network Gateway.'
    Write-Warning 'THIS CAN TAKE UP TO 45 MINUTES. GO GRAB A COFFEE OR TEA!'
    Write-Host ''
    New-AzureRmVirtualNetworkGateway -Name $GW -ResourceGroupName $RG -Location $Location -IpConfigurations $ipconf -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard
    $NewVNG = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $RG -name $GW
    if(-not $NewVNG){
      Write-Host -ForegroundColor red "The Virtual Network Gateway $GW was not created successfully"
      Write-Host 'Press any key to continue...'
      [void][System.Console]::ReadKey($true)

      Clear-Host
    }
    else
    {
      Write-Host "The Virtual Network Gateway $GW was created successfully"
      Write-Host '' 
      Write-Host 'Press any key to continue...'
      [void][System.Console]::ReadKey($true)
      Clear-Host
    }
  }1{
    Write-Host '' 
    $array = @(Get-AzureRmVirtualNetworkGateway -ResourceGroupName $RG | select-object -ExpandProperty Name) 
    $menu = @{}
    for ($i=1;$i -le $array.count; $i++) # Start i at 1, while i is less than the total array count, add 1 and loop
    { Write-Host "$i. $($array[$i-1])" # Write to session the current number in i and the array object in the array index of i - 1
    $menu.Add($i,($array[$i-1])) } # Add the array object to the menu array
    Write-Host ''
    [int]$ans = Read-Host 'Enter selection' # Prompt user to enter an integer and store as $ans
    $selection = $menu.Item($ans) ; $GW = $selection # selection is the array object in menu where index is 
    $GW = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $RG -Name $GW | select-object -ExpandProperty Name
    Write-Host "The Virtual Network Gateway $GW has been selected."
    Write-Host '' 
    Write-Host 'Press any key to continue...'
    [void][System.Console]::ReadKey($true)
    Clear-Host
  
  }2{
    Write-Host 'Cancelled, exiting the script...'
    Write-Host ''
    Exit
    } 
}

#endregion

#region LOCAL NETWORK GATEWAY

Clear-Host

Write-Host '----------------------'
Write-Host 'Local Network Gateway.'
Write-Host '----------------------'
Write-Host ''
Write-Host ''

$LNGName = $Prefix + $root + 'LNG'
Write-Host "Local Network Gateway name: $LNGName"
Write-Host ''
$SharedKey = Read-host 'Enter the pre-shared key'
Write-Host ''
$GatewayIP = Read-host 'Enter the Gateway IP (x.x.x.x)'
# Example format 213.246.159.16
Write-Host ''
$GatewayAddressPrefix = Read-host 'Enter the Gateway Address Prefix (x.x.x.x/xx)'
# Example format 80.86.34.128/25
Write-Host ''
$LNGConName = $Prefix + $root + 'LNGCN'
Write-Host "Local Network Gateway Connection name: $LNGConName"
Write-Host ''
Write-Host 'Attempting to Create the Local Network Gateway.'
Write-Host ''

New-AzureRmLocalNetworkGateway -Name $LNGName -ResourceGroupName $RG -Location $Location -GatewayIpAddress $GatewayIP -AddressPrefix $GatewayAddressPrefix

$NewLNG = Get-AzureRmLocalNetworkGateway -ResourceGroupName $RG -name $LNGName | select-object -ExpandProperty Name
    if(-not $NewLNG){
        Write-Host -ForegroundColor red "The Local Network Gateway $LNGName was not created successfully"
        Write-Host 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)

        Clear-Host
    }
        else
    {
        Write-Host "The Local Network Gateway $LNGName was created successfully"
        Write-Host '' 
        Write-Host 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)

        Clear-Host

    }

#endregion

#region VIRTUAL NETWORK GATEWAY CONNECTION

Clear-Host

Write-Host '-----------------------------------'
Write-Host 'Virtual Network Gateway Connection.'
Write-Host '-----------------------------------'
Write-Host ''
Write-Host ''

$gateway = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $RG -Name $GW
$local = Get-AzureRmLocalNetworkGateway -ResourceGroupName $RG -Name $LNGName

Write-Host 'Attempting to create the new Virtual Network Gateway Connection.'
New-AzureRmVirtualNetworkGatewayConnection -Name $LNGConName -ResourceGroupName $RG -Location $Location -VirtualNetworkGateway1 $gateway -LocalNetworkGateway2 $local -ConnectionType IPsec -RoutingWeight 10 -SharedKey $SharedKey

$NewLNGC = Get-AzureRmVirtualNetworkGatewayConnection -ResourceGroupName $RG -name $LNGConName | select-object -ExpandProperty Name
    if(-not $NewLNGC){
        Write-Host -ForegroundColor red "The Local Network Gateway Connection $LNGConName was not created successfully"
        Write-Host 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)

        Clear-Host
    }
        else
    {
        Write-Host "The Local Network Gateway Connection $LNGConName was created successfully"
        Write-Host '' 
        Write-Host 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)

        Clear-Host

    }


#endregion

#region SUMMARY

Clear-Host

Write-Host '-------------'
Write-Host 'Summary Page.'
Write-Host '-------------'
Write-Host ''
Write-Host 'For a list of the settings provided during this session, check the transcript file:'
Write-Host "$logFile\Azure-CreateNewVPN.txt"
Write-Host ''
#$peerIP = Get-AzureRmPublicIpAddress -name UCGPRFVNGIP -ResourceGroupName UCGPRFRG | select-object -ExpandProperty IpAddress
#Write-Host 'Azure peer address: ' $peerIP
Write-Host ''
Write-Host 'Pre-shared key: ' $SharedKey
Write-Host ''
Write-Host 'For IKE and IPSEC settings:'
Write-Host 'https://azure.microsoft.com/en-gb/documentation/articles/vpn-gateway-about-vpn-devices/'
Write-Host ''
Write-Host 'For a VPN FAQ:'
Write-Host 'https://azure.microsoft.com/en-gb/documentation/articles/vpn-gateway-vpn-faq/'
Write-Host '' 
Write-Host 'Press any key to exit the script...'
[void][System.Console]::ReadKey($true)
#endregion