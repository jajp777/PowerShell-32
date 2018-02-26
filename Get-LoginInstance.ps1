#PowerShell Script Containing Function(s) Used to Retrieve Login & Logout Instances from a Local or Remote Computer
#Developer: Andrew Saraceni (saraceni@wharton.upenn.edu)
#Date: 10/23/14

function Get-LoginInstance
{
    <#
    .SYNOPSIS
    Retrieves login and logout instances from a local or remote computer.
    .DESCRIPTION
    Retrieves all interactive and remote-based logins from a specific 
    computer, then obtains all logouts and joins the instances together 
    via processing.  This information is retrieved from the Security 
    event logs on the computer, and thus can only pull data from logs 
    that have yet to turn over.

    Without parameters, a Get-LoginInstance command retrieves all logins 
    and logouts from the local computer within the past week.
    .PARAMETER ComputerName
    Specifies the computer from which to pull the login/logout 
    information.  The default value for this is the local computer.
    .PARAMETER StartDate
    Specifies the earliest (i.e. oldest) date from which to retrieve 
    logins/logouts.  The default value for this is one week before the 
    current date: (Get-Date).AddDays(-7)
    .PARAMETER EndDate
    Specifies the most recent date from which to retrieve logins/logouts.  
    The default value for this is the current date.
    .EXAMPLE
    Get-LoginInstance
    Retrieve all available login instances from the local computer within 
    the past week.
    .EXAMPLE
    Get-LoginInstance -ComputerName "GSR-242" -StartDate (Get-Date).AddMonths(-1) -Verbose
    Retrieve all available login instances from remote computer "GSR-242" 
    within the past month, displaying verbose output as well.
    .NOTES
    This cmdlet makes use of the Get-WinEvent cmdlet, which is only 
    available on Windows Vista, Windows Server 2008 R2 and later consumer 
    and enterprise verisons of Windows, respectively.

    Additionally, Remote Event Log Management will need to be enabled 
    via your firewall.  The following CMD prompt command can enable this 
    on a local computer:

    netsh advfirewall firewall set rule group=”remote event log management” new enable=yes
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$false)]
        [String]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Position=1,Mandatory=$false)]
        [DateTime]$StartDate = (Get-Date).AddDays(-7),
        [Parameter(Position=2,Mandatory=$false)]
        [DateTime]$EndDate = (Get-Date)
    )

    function Get-LoginData
    {
        param($ComputerName,$StartDate,$EndDate)
        
        Write-Verbose "Getting Login Data from $ComputerName..."
        [Int32[]]$loginID = @(4624)

        try
        {
            $loginEvents = Get-WinEvent -ComputerName $ComputerName -FilterHashtable @{ LogName="Security"; ID=$loginID; StartTime=$StartDate; EndTime=$EndDate } -ErrorAction Stop
        }
        catch
        {
            Set-Variable -Name catchError -Value $_
            if ($catchError -match "No events were found that match the specified selection criteria.")
            {
                Write-Warning "No Login Events Found - Ending Login Collection"
            }
        }

        Write-Verbose "Converting Logins to XML & Parsing Data for Better Readability..."
        foreach ($loginEvent in $loginEvents)
        {
            $xmlLoginEvent = [Xml]$loginEvent.ToXml()

            for ($i=0; $i -lt $xmlLoginEvent.Event.EventData.Data.Count; $i++)
            {            
                Add-Member -InputObject $loginEvent -MemberType NoteProperty -Name $xmlLoginEvent.Event.EventData.Data[$i].Name -Value $xmlLoginEvent.Event.EventData.Data[$i]."#Text" -Force
            }
        }

        $revisedLoginEvents = @()
        $xmlLoginEvents = $loginEvents | Where-Object { (($_.LogonType -eq "2") -or ($_.LogonType -eq "10")) -and ($_.TargetDomainName -ne "Window Manager") } | Select-Object -Property *
        foreach ($xmlLoginEvent in $xmlLoginEvents)
        {
            switch ($xmlLoginEvent.LogonType)
            {
                "2" {
                    $xmlLoginEvent.LogonType = "Login-Interactive"
                }
                "10" {
                    $xmlLoginEvent.LogonType = "Login-Remote"
                }
            }
            
            if (($xmlLoginEvent.IpAddress -eq "127.0.0.1") -or ($xmlLoginEvent.IpAddress -eq "::1"))
            {
                $xmlLoginEvent.IpAddress = $null
            }

            if ($xmlLoginEvent.IpPort -eq "0")
            {
                $xmlLoginEvent.IpPort = $null
            }
            
            $revisedLoginEvents += $xmlLoginEvent
        }
        
        return $revisedLoginEvents
    }

    function Get-LogoutData
    {
        param($ComputerName,$StartDate,$EndDate)

        Write-Verbose "Getting Logout Data from $ComputerName..."
        [Int32[]]$logoutID = @(4647)

        try
        {
            $logoutEvents = Get-WinEvent -ComputerName $ComputerName -FilterHashtable @{ LogName="Security"; ID=$logoutID; StartTime=$startDate; EndTime=$endDate } -ErrorAction Stop
        }
        catch
        {
            Set-Variable -Name catchError -Value $_
            if ($catchError -match "No events were found that match the specified selection criteria.")
            {
                Write-Warning "No Logout Events Found - Ending Logout Collection"
            }
        }

        Write-Verbose "Converting Logouts to XML & Parsing Data for Better Readability..."
        foreach ($logoutEvent in $logoutEvents)
        {
            $xmlLogoutEvent = [Xml]$logoutEvent.ToXml()

            for ($i=0; $i -lt $xmlLogoutEvent.Event.EventData.Data.Count; $i++)
            {            
                Add-Member -InputObject $logoutEvent -MemberType NoteProperty -Name $xmlLogoutEvent.Event.EventData.Data[$i].name -Value $xmlLogoutEvent.Event.EventData.Data[$i]."#Text" -Force
            }
        }
        
        $revisedLogoutEvents = @()
        $xmlLogoutEvents = $logoutEvents | Select-Object -Property *
        foreach ($xmlLogoutEvent in $xmlLogoutEvents)
        {
            Add-Member -InputObject $xmlLogoutEvent -MemberType NoteProperty -Name "WorkstationName" -Value $ComputerName -Force

            $revisedLogoutEvents += $xmlLogoutEvent
        }
        
        return $revisedLogoutEvents
    }

    $finalLoginEvents = Get-LoginData -ComputerName $ComputerName -StartDate $StartDate -EndDate $EndDate
    $finalLogoutEvents = Get-LogoutData -ComputerName $ComputerName -StartDate $StartDate -EndDate $EndDate

    Write-Verbose "Creating Final Collection of Revised Login and Logout Instance Data..."
    $loginInstances = @()

    foreach ($finalLoginEvent in $finalLoginEvents)
    {
        $instanceProperties = @{
            ComputerName = $finalLoginEvent.WorkstationName
            UserName = $finalLoginEvent.TargetUserName
            AccountDomain = $finalLoginEvent.TargetDomainName
            LoginTime = $finalLoginEvent.TimeCreated
            LogoutTime = $null
            TargetLogonID = $finalLoginEvent.TargetLogonID
            Days = $null
            Hours = $null
            Minutes = $null
            Seconds = $null
            SessionType = $finalLoginEvent.LogonType
            LoginIpAddress = $finalLoginEvent.IpAddress
            LoginIpPort = $finalLoginEvent.IpPort
            LogonGuid = $finalLoginEvent.LogonGuid
        }

        $loginInstance = New-Object -TypeName PSObject -Property $instanceProperties

        foreach ($finalLogoutEvent in $finalLogoutEvents)
        {
            if (($finalLogoutEvent.WorkstationName -eq $finalLoginEvent.WorkstationName) -and ($finalLogoutEvent.TargetUserName -eq $finalLoginEvent.TargetUserName) -and ($finalLogoutEvent.TargetLogonID -eq $finalLoginEvent.TargetLogonID))
            {
                $loginInstance.LogoutTime = $finalLogoutEvent.TimeCreated
                $loginInstance.Days = (New-TimeSpan -Start $finalLoginEvent.TimeCreated -End $finalLogoutEvent.TimeCreated).Days
                $loginInstance.Hours = (New-TimeSpan -Start $finalLoginEvent.TimeCreated -End $finalLogoutEvent.TimeCreated).Hours
                $loginInstance.Minutes = (New-TimeSpan -Start $finalLoginEvent.TimeCreated -End $finalLogoutEvent.TimeCreated).Minutes
                $loginInstance.Seconds = (New-TimeSpan -Start $finalLoginEvent.TimeCreated -End $finalLogoutEvent.TimeCreated).Seconds
            }
        }

        $loginInstances += $loginInstance
    }

    $fullLoginInstances = $loginInstances | Where-Object { $_.LogoutTime -ne $null }
    $partialLoginInstances = $loginInstances | Where-Object { $_.LogoutTime -eq $null } | Sort-Object -Property LoginTime -Descending -Unique

    $fullLoginInstanceLoginTimes = $fullLoginInstances | Select-Object -ExpandProperty LoginTime
    $filteredPartialLoginInstances = @()
    
    foreach ($partialLoginInstance in $partialLoginInstances)
    {
        if ($fullLoginInstanceLoginTimes -notcontains $partialLoginInstance.LoginTime)
        {
            $filteredPartialLoginInstances += $partialLoginInstance
        }
    }

    $finalLoginInstances = @($fullLoginInstances) + @($filteredPartialLoginInstances) | Sort-Object -Property LoginTime -Descending -Unique

    return $finalLoginInstances | Select-Object -Property ComputerName, UserName, AccountDomain, LoginTime, LogoutTime, TargetLogonID, Days, Hours, Minutes, Seconds, SessionType, LoginIpAddress, LoginIpPort, LogonGuid
}