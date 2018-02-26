# Author: Dale Morson
# Email: dale.morson@gmail.com
# Date: 14/05/17
# Version: 1.0

#region REUSABLE FUNCTIONS
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "TXT (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

Function Get-Telnet
{   Param (
        [Parameter(ValueFromPipeline=$true)]
        [String[]]$Commands = @("username","password","disable clipaging","sh config"),
        [string]$RemoteHost = "HostnameOrIPAddress",
        [string]$Port = "23",
        [int]$WaitTime = 1000,
        [string]$OutputPath = "\\server\share\switchbackup.txt"
    )
    #Attach to the remote device, setup streaming requirements
    $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)
    If ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Buffer = New-Object System.Byte[] 1024 
        $Encoding = New-Object System.Text.AsciiEncoding

        #Now start issuing the commands
        ForEach ($Command in $Commands)
        {   $Writer.WriteLine($Command) 
            $Writer.Flush()
            Start-Sleep -Milliseconds $WaitTime
        }
        #All commands issued, but since the last command is usually going to be
        #the longest let's wait a little longer for it to finish
        Start-Sleep -Milliseconds ($WaitTime * 4)
        $Result = ""
        #Save all the results
        While($Stream.DataAvailable) 
        {   $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }
    }
    Else     
    {   $Result = "Unable to connect to host: $($RemoteHost):$Port"
    }
    #Done, now save the results to a file
    $Result | Out-File $OutputPath
}

#endregion

#region VARIABLES AND CONSTANTS

$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes','Description.'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No','Description.'
$exit = New-Object System.Management.Automation.Host.ChoiceDescription '&Exit','Description.'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit)
$optionsDisclaimer = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$dateStamp = Get-Date -Format dd-MMM-HHmm

$sessionNew = $dateStamp

$TARGETDIR = ".\sessions\telnet\$sessionNew"
if(!(Test-Path -Path $TARGETDIR )){
	New-Item -ItemType directory -Path $TARGETDIR
	}
		
$TARGETDIRTEMP = ".\sessions\telnet\$sessionNew\temp"
if(!(Test-Path -Path $TARGETDIRTEMP )){
	New-Item -ItemType directory -Path $TARGETDIRTEMP
	}

Start-Transcript $TARGETDIR\session-transcript.txt


#endregion

#region DISCLAIMER
Clear-Host
Write-Output ''
Write-Output '--------------------------------'
Write-Output 'USE THIS SCRIPT AT YOUR OWN RISK'
Write-Output '--------------------------------'
Write-Output ''
Write-Output 'The entire risk arising out of the use of this script remains with you.'
Write-Output ''
$message = 'Do you wish to continue?'
$result = $host.ui.PromptForChoice($title, $message, $optionsDisclaimer, 0)
switch ($result) {
    0{
        Write-output "Accepted"
        Clear-Host    
    }1{
        Exit
    }
}


#endregion

#region LOAD IPS

Clear-Host
Write-Output ''
Write-Output '----------------'
Write-Output '(1/4) LOAD IP(s)'
Write-Output '----------------'
Write-Output ''
Write-Output 'Select the .txt file containing the list of network device IP(s)'
Do{
	Try{
		$inputfile = Get-FileName .\
		$inputdata = get-content $inputfile
		$inputdataRAW = get-content $inputfile -raw
		If (($inputdata) -eq $Null) {
			Write-Output ''
			".txt file is blank, please try again" 
			} 
		}
	Catch{
		Write-Output ''
		Write-Output 'User cancelled.'
		Write-Output ''
		Exit
		}
}
While(!$inputdata)
Write-Output ''
Write-Output 'The following IP(s) have been selected:'
Write-Output ''
Write-Host -ForegroundColor Green "$inputdataRAW"
Write-Output ''
Write-Output 'Press any key to continue...'
[void][System.Console]::ReadKey($true)
Clear-Host

#endregion

#region LOAD COMMANDS

Clear-Host
Write-Output ''
Write-Output '----------------'
Write-Output '(2/4) COMMAND(S)'
Write-Output '----------------'
Write-Output ''
Write-Output 'Select the .txt file that contains the command(s) to be executed against the selected IP(s).'
Write-Output ''
Write-Warning "Do not include the enable command as this can be configured in step 4/4"
Do
{
	Try {
		$inputFileCommands = Get-FileName .\
		$commandBlock = get-content $inputFileCommands
		$commandBlockRAW = get-content $inputFileCommands -raw
		If (($commandblock) -eq $Null) {
			Write-Output ''
			".txt file is blank, please try again" 
			} 
	}
	Catch{
		Write-Output ''
		Write-Output 'User cancelled.'
		Write-Output ''
		Exit
	}
}
while(!$commandBlock)
Write-Output ''
Write-Output 'The following commands will be executed:'
Write-Output ''
Write-Host -ForegroundColor Green "$commandBlockRAW"
Write-Output ''
Write-Output 'Press any key to continue...'
[void][System.Console]::ReadKey($true)
Clear-Host

#endregion

#region CREDENTIALS
Clear-Host
Write-Output ''
Write-Output '-------------------'
Write-Output '(3/4) CREDENTIAL(S)'
Write-Output '-------------------'
Write-Output ''
Write-Output ''
Write-Output 'Select the .txt file that contains a list of username(s).'
Write-Output ''
Do
{
	Try {
		$inputUsernames = Get-FileName .\
		$credUsernames = get-content $inputUsernames
		$credUsernamesRAW = get-content $inputUsernames -raw
		If (($credUsernames) -eq $Null) {
			Write-Output ''
			"File is blank, please try again" 
			} 
	}
	Catch{
		Write-Output ''
		Write-Output 'User cancelled.'
		Write-Output ''
		Exit
	}
}
while(!$credUsernames)
Write-Output 'The following username(s) will be attempted:'
Write-Output ''
Write-Host -ForegroundColor Green "$credUsernamesRAW"
Write-Output ''
Write-Output ''
# load list of passwords
Write-Output 'Select the .txt file that contains a list of password(s).'
Write-Output ''
Do{
	Try {
		$inputPasswords = Get-FileName .\
		$credPasswords = get-content $inputPasswords
		$credPasswordsRAW = get-content $inputPasswords -raw
		If (($credPasswords) -eq $Null) {
			Write-Output ''
			"File is blank, please try again" 
			} 
	}
	Catch{
		Write-Output ''
		Write-Output 'User cancelled.'
		Write-Output ''
		Exit
	}
}
while(!$credPasswords)
Write-Output 'The following password(s) will be attempted:'
Write-Output ''
Write-Host -ForegroundColor Green "$credPasswordsRAW"
Write-Output ''
Write-Output ''
Write-Output 'Press any key to continue...'
[void][System.Console]::ReadKey($true)
Clear-Host
#endregion

#region ENABLE PASSWORD

Clear-Host
Write-Output ''
Write-Output '---------------------'
Write-Output '(4/4) ENABLE PASSWORD'
Write-Output '---------------------'
Write-Output ''
$message = 'Is there an enable password required?'
$result = $host.ui.PromptForChoice($title, $message, $options, 1)
switch ($result) {
    0{
        Write-Output ''
        $enablePassword = read-host 'Enable password'
        Write-Output ''
        Write-Output 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)  
        Clear-Host    
    }1{
        Write-Output ''
        Write-Warning 'You skipped entering an enable password.'
        Write-Output ''
        Write-Output 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)
        Clear-Host
    }2{
        Write-Output 'User cancelled.'
        Write-Output ''
        Exit
    }
}
Clear-Host

#endregion

#region RUN SCRIPT
Clear-Host # start fresh screen
Write-Output ''
Write-Output '--------------'
Write-output 'SCRIPT SUMMARY' # advise user next step
Write-Output '--------------'
Write-Output ''
Write-output 'IP(s):'
Write-Host -ForegroundColor Green "$inputdataRAW"
Write-Output ''
Write-output 'Command(s):'
Write-Host -ForegroundColor Green "$commandBlockRAW"
Write-Output ''
Write-output 'Username(s):'
Write-Host -ForegroundColor Green "$credUsernamesRAW"
Write-Output ''
Write-output 'Password(s):'
Write-Host -ForegroundColor Green "$credPasswordsRAW"
Write-Output ''
Write-output 'Enable Password:'
if ($enablePassword) 
{ 
Write-Host -ForegroundColor Green "$enablePassword"                                    		
} 
else
{
Write-Host -ForegroundColor Green "No enable password"                                            		
}
Write-Output ''
Start-sleep 1
$message = 'Do you wish to continue?'
$result = $host.ui.PromptForChoice($title, $message, $optionsDisclaimer, 0)
switch ($result) {
    0{
        Write-output "Start Script"
        Clear-Host    
    }1{
        Exit
    }
}
Clear-Host # clear screen
$inputdata | ForEach-Object {
    Clear-Host
    Write-Output ''
    Write-output "#### $_" # advise user next step
    Write-Output ''
    write-output "   Testing port 23 for $_"
    #$testTelnetPort = Test-NetConnection -ComputerName $_ -Port 23 | select-object tcpTestSucceeded -ExpandProperty tcpTestSucceeded
    #$testTelnetPort = Test-Port $_ 23
    $IP = $_
    try{
        $t = New-Object Net.Sockets.TcpClient $_, 23 -ErrorAction stop
        if ($t.Connected){	
            Write-Output ''
            Write-Output '   Port 23 is open'
            Start-Sleep 1
            Write-Output ''
            $credUsernames | ForEach-Object	{
                $currentUsername = $_
                $credPasswords | ForEach-Object {
                    $currentPassword = $_
                    if ($enablePassword) { 
                        try{
                            write-output "   Attempting to execute commands against $IP using $currentUsername / $currentPassword"
                            Write-Output ''
                            Get-Telnet -RemoteHost $IP -Commands $currentUsername, $currentPassword, "en", $enablePassword, (get-content $inputFileCommands -raw) -OutputPath $TARGETDIRTEMP\$IP.txt
                            $stringStream = get-content $TARGETDIRTEMP\$IP.txt
                            $checkStream = $stringStream | Out-String
                            if (($checkStream -like "*fail*") -or ($checkStream -like "*denied*") -or ($checkStream -like "*reject*")){
                                Write-Host -ForegroundColor Yellow "   Login failed for $IP using $currentUsername / $currentPassword"
                                Write-Output ''
                                Write-Host -ForegroundColor Yellow "   Writing failure to $TARGETDIR\telnet-failed.csv"
                                Write-Output ''
                                start-sleep 1
                                [pscustomobject]@{
                                IP = $IP
                                Completed = "No"
                                TelnetPort = "Open"
                                Username = ($currentUsername | Out-String).Trim()
                                Password = ($currentPassword | Out-String).Trim()
                                Enable = ($enablePassword | Out-String).Trim()
                                Output = 'Failed login'
                                } | Export-Csv $TARGETDIR\telnet-failed.csv -Append -NoTypeInformation
                            }					
                            else{
                                Write-Host -ForegroundColor Green "   Commands run successfully using $currentUsername / $currentPassword"
                                Write-Output ''
                                Write-Host -ForegroundColor Green "   Writing success to $TARGETDIR\telnet-successful.csv"
                                Write-Output ''
                                start-sleep 1
                                [pscustomobject]@{
                                IP = $IP
                                Completed = "Yes"
                                TelnetPort = "Open"
                                Username = ($currentUsername | Out-String).Trim()
                                Password = ($currentPassword | Out-String).Trim()
                                Enable = ($enablePassword | Out-String).Trim()
                                Output = ($stringStream | Out-String).Trim()
                                } | Export-Csv $TARGETDIR\telnet-successful.csv -Append -NoTypeInformation
                                
                            }
                        }
                    catch{
                        Write-Output ''
                        $errorMsg = $_.Exception.Message
                        Write-Output ''
                        #Write-warning $errorMsg
                        Write-Host -ForegroundColor Yellow '   Failed to connect'
                        Write-Output ''
                        Write-Host -ForegroundColor Yellow "   Writing failure to $TARGETDIR\telnet-failed.csv"
                        Write-Output ''
                        start-sleep 1
                        [pscustomobject]@{
                        IP = $IP
                        Completed = "No"
                        TelnetPort = "Open"
                        Username = ($currentUsername | Out-String).Trim()
                        Password = ($currentPassword | Out-String).Trim()
                        Enable = ($enablePassword | Out-String).Trim()
                        Output = $errorMsg
                        } | Export-Csv $TARGETDIR\telnet-failed.csv -Append -NoTypeInformation
                    }   
                }
                else{
                    try{
                        write-output "   Attempting to execute commands against $IP using $currentUsername / $currentPassword"
                        Write-Output ''
                        Get-Telnet -RemoteHost $IP -Commands $currentUsername, $currentPassword, (get-content $inputFileCommands -raw) -OutputPath $TARGETDIRTEMP\$IP.txt
                        $stringStream = get-content $TARGETDIRTEMP\$IP.txt
                        $checkStream = $stringStream | Out-String
                        if (($checkStream -like "*fail*") -or ($checkStream -like "*denied*") -or ($checkStream -like "*reject*")){
                            Write-Host -ForegroundColor Yellow "   Login failed for $IP using $currentUsername / $currentPassword"
                            Write-Output ''
                            Write-Host -ForegroundColor Yellow "   Writing failure to $TARGETDIR\telnet-failed.csv"
                            Write-Output ''
                            start-sleep 1
                            [pscustomobject]@{
                            IP = $IP
                            Completed = "No"
                            TelnetPort = "Open"
                            Username = ($currentUsername | Out-String).Trim()
                            Password = ($currentPassword | Out-String).Trim()
                            Enable = ''
                            Output = 'Failed login'
                            } | Export-Csv $TARGETDIR\telnet-failed.csv -Append -NoTypeInformation
                        }
                        else{
                            Write-Host -ForegroundColor Green "   Commands run successfully using $currentUsername / $currentPassword"
                            Write-Output ''
                            Write-Host -ForegroundColor Green "   Writing success to $TARGETDIR\telnet-successful.csv"
                            Write-Output ''
                            start-sleep 1
                            [pscustomobject]@{
                            IP = $IP
                            Completed = "Yes"
                            TelnetPort = "Open"
                            Username = ($currentUsername | Out-String).Trim()
                            Password = ($currentPassword | Out-String).Trim()
                            Enable = ''
                            Output = ($stringStream | Out-String).Trim()
                            } | Export-Csv $TARGETDIR\telnet-successful.csv -Append -NoTypeInformation
                            
                        }
                    }
                catch{
                    Write-Output ''
                    $errorMsg = $_.Exception.Message
                    Write-Host -ForegroundColor Yellow $errorMsg
                    Write-Output ''
                    Write-Host -ForegroundColor Yellow '   Failed to connect'
                    Write-Output ''
                    Write-Host -ForegroundColor Yellow "   Writing failure to $TARGETDIR\telnet-failed.csv"
                    Write-Output ''
                    start-sleep 1
                    [pscustomobject]@{
                    IP = $IP
                    Completed = "No"
                    TelnetPort = "Open"
                    Username = ($currentUsername | Out-String).Trim()
                    Password = ($currentPassword | Out-String).Trim()
                    Enable = ''
                    Output = $errorMsg
                    } | Export-Csv $TARGETDIR\telnet-failed.csv -Append -NoTypeInformation
                }
            }
        } # End loop of passwords
    } # end loop of usernames
}
    else{
        Write-Output ''
        Write-Host -ForegroundColor Yellow '   Telnet port 23 is closed'
        Write-Output ''
        [pscustomobject]@{
        IP = $IP
        Completed = "No"
        TelnetPort = "Closed"
        Username = ''
        Password = ''
        Enable = ''
        Output = "Port Closed"
        } | Export-Csv $TARGETDIR\telnet-failed.csv -Append -NoTypeInformation
        }
    }
# close if statement for checking if port open
    catch{
        $errorMsg = $_.Exception.Message
        #Write-warning $errorMsg
        Write-Output ''
        Write-Host -ForegroundColor Yellow '   An error occurred, possibly due to port closed or IP not responding'
        Write-Output ''
        Write-Host -ForegroundColor Yellow '   Writing error to output'
        start-sleep 1
        [pscustomobject]@{
        IP = $IP
        Completed = "No"
        TelnetPort = "Closed"
        Username = ''
        Password = ''
        Enable = ''
        Output = "Port Closed"
        } | Export-Csv $TARGETDIR\telnet-failed.csv -Append -NoTypeInformation
    }
}

#endregion

#region COMPLETE

Clear-Host
Write-Output ''
Write-Output '----------------'
Write-Output 'SCRIPT COMPLETED'
Write-Output '----------------'
Write-Output ''
Write-Output 'Outputs folder will now open in Explorer.'
ii $TARGETDIR
Write-Output ''
Exit

#endregion