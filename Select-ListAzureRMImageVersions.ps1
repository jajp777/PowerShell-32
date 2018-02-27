Login-AzureRmAccount

$locName="westeurope"

$input = Get-AzureRMVMImagePublisher -Location $locName | Select PublisherName
$menu = @{}  
for ($i=1;$i-le $input.count; $i++)  
{ Write-Host "$i. $($input[$i-1].PublisherName)"  
$menu.Add($i,($input[$i-1].PublisherName)) }  
[int]$ans= Read-Host 'Select a publisher name'  
$selection = $menu.Item($ans) 
$pubName = $selection

$input = Get-AzureRMVMImageOffer -Location $locName -Publisher $pubName | Select Offer
$menu = @{}  
for ($i=1;$i-le $input.count; $i++)  
{ Write-Host "$i. $($input[$i-1].Offer)"  
$menu.Add($i,($input[$i-1].Offer)) }  
[int]$ans= Read-Host 'Select an image offer'  
$selection = $menu.Item($ans) 
$offerName=$selection

$input = Get-AzureRMVMImageSku -Location $locName -Publisher $pubName -Offer $offerName | Select Skus 
$menu = @{}  
for ($i=1;$i-le $input.count; $i++)  
{ Write-Host "$i. $($input[$i-1].Skus)"  
$menu.Add($i,($input[$i-1].Skus)) }  
[int]$ans= Read-Host 'Select an image sku'  
$selection = $menu.Item($ans) 
$sku = $selection

$input = Get-AzureRmVMImage -Location $locName -PublisherName $pubName -Offer $offerName -Skus $sku
$menu = @{}  
for ($i=1;$i-le $input.count; $i++)  
{ Write-Host "$i. $($input[$i-1].Version)"  
$menu.Add($i,($input[$i-1].Version)) }  
[int]$ans= Read-Host 'Select an image version'  
$selection = $menu.Item($ans) 
$version = $selection

write-host $locName
write-host $pubName
write-host $offername
write-host $sku
write-host $version