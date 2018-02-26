Import-Module activedirectory
ForEach ($Server in (get-content ".\Servers.txt")) 
{   
  Try {
    Get-ADComputer $Server
    Write-Host "$Server found in Active Directory" -Backgroundolor green -Foregroundcolor black
  }
  Catch {
    Write-Host "$Server NOT found in Active Directory" -Backgroundcolor red -Foregroundcolor black
  }
}
