# Install PowerShell Core and AzureRM
http://jessicadeen.com/linux/powershell-core-master/
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jldeen/pwshcore/master/install.sh)"

# Alternative
# https://github.com/PowerShell/PowerShellGet/issues/24
Install-Package -Name AzureRM.NetCore.Preview -Source https://www.powershellgallery.com/api/v2/ -ProviderName NuGet -ExcludeVersion -Destination $home/powershell/modules
Import-Module $home/powershell/modules/AzureRM.Profile.NetCore.Preview
Import-Module $home/powershell/modules/AzureRM.Resources.NetCore.Preview
Import-Module $home/powershell/modules/AzureRM.NetCore.Preview
Login-AzureRmAccout

# Build information
lsb_release -a