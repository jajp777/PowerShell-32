Function Get-HostToIP($hostname) { 
  $result = [system.Net.Dns]::GetHostByName($hostname) 
  $result.AddressList | ForEach-Object { $hostname; $_.IPAddressToString } 
} 

# Get-Content ".\Servers.txt" | ForEach-Object {(Get-HostToIP($_)) >> C:\Resolutions.txt} 
