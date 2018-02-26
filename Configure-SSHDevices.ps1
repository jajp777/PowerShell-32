# Author: Dale Morson
# Email: dale.morson@gmail.com
# Date: 14/05/17
# Version: 1.0

#region REUSABLE FUNCTIONS

# Call Get-FileName to open a dialog box and filter by .txt files

Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "TXT (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

#endregion

#region VARIABLES AND CONSTANTS

# Yes, No, Exit options for reusable menu system.

$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes','Description.'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No','Description.'
$exit = New-Object System.Management.Automation.Host.ChoiceDescription '&Exit','Description.'

# Create options.

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit)

# Custom option for the disclaimer splash screen at the start of the script. Yes or no.

$optionsDisclaimer = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

# Use dateStamp to ensure same time to the second is used in variables such as creating folders.

$dateStamp = Get-Date -Format dd-MMM-HHmm

# Assign the dateStamp variable to the sessionNew variable to be used for creating folders etc.

$sessionNew = $dateStamp

# Create directories to be used to store session information. This is created each time you run the script.

$TARGETDIR = ".\sessions\ssh\$sessionNew"
if(!(Test-Path -Path $TARGETDIR )){
	New-Item -ItemType directory -Path $TARGETDIR
	}

# Create a temporary directory within the session directory to dump outputs.	

$TARGETDIRTEMP = ".\sessions\ssh\$sessionNew\temp"
if(!(Test-Path -Path $TARGETDIRTEMP )){
	New-Item -ItemType directory -Path $TARGETDIRTEMP
	}

# Start transcript to record the session

Start-Transcript $TARGETDIR\session-transcript.txt

#endregion

#region DISCLAIMER

# Quick disclaimer that records Accepted in the transcript.

Clear-Host
Write-Output ''
Write-Output '--------------------------------'
Write-Output 'USE THIS SCRIPT AT YOUR OWN RISK'
Write-Output '--------------------------------'
Write-Output ''
Write-Output 'The entire risk arising out of the use of this script remains with you.'
Write-Output ''
$message = 'Do you wish to continue?'
$result = $host.ui.PromptForChoice($title, $message, $optionsDisclaimer, 0) # 0 makes Yes the default option. 
switch ($result) {
    0{
        Write-output "Accepted"
        Clear-Host    
    }1{
        Exit
    }
}

#endregion

#region CHECK POSH-SSH

# The script relies on Posh SSH, check if Post-SSH module is installed, if not, install it.

Clear-Host 
Write-Output ''
Write-Output '--------------------'
Write-Output '(1/6) CHECK POSH-SSH'
Write-Output '--------------------'
Write-Output ''

# Check is installed

if (Get-Module -ListAvailable -Name Posh-SSH) { 
        Write-Host -ForegroundColor Green '   PoshSSH Module is installed'
        Write-Output ''
        Write-Output 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)
        Clear-Host
} else { 

# Download
# Check if user is running as an Administrator.
# If not Administrator, warn user and exit.

        If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] 'Administrator'))
        {
            Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator."
            Write-Output 'Press any key to continue...'
            [void][System.Console]::ReadKey($true)
            Exit
        }

        Write-Output 'Installing PoshSSH Module.'
        Write-Output ''

# Download and install Posh-SSH if user is running as Administrator

        Invoke-Expression (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev") -Verbose
        Write-Output ''
        Write-Output 'Press any key to continue...'
        [void][System.Console]::ReadKey($true)  
        Clear-Host  
}
Clear-Host

#endregion

#region LOAD IPS

# Load in a list of SSH devices by IP as a .txt file.

Clear-Host
Write-Output ''
Write-Output '----------------'
Write-Output '(2/6) LOAD IP(s)'
Write-Output '----------------'
Write-Output ''
Write-Output 'Select the .txt file containing the list of network device IP(s)'
Do{
	Try{

        # Test to see if the file is blank and prompt user to try again

		$inputfile = Get-FileName .\
		$inputdata = get-content $inputfile
		$inputdataRAW = get-content $inputfile -raw
		If (($inputdata) -eq $Null) {
			Write-Output ''
			"File is blank, please try again" 
			} 
		}

    # If any errors or user CTRL + Cs then exit

	Catch{
		Write-Output ''
		Write-Output 'User cancelled.'
		Write-Output ''
		Exit
		}
}
# Once $inputdata is not empty output the IPs for review by user

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

# Load in the list of commands that will be past to ALL SSH devices loaded in the previous prompt
# User will be prompted to not to enter the enable command for Cisco devices as this will be asked in separate screen

Clear-Host
Write-Output ''
Write-Output '----------------'
Write-Output '(3/6) COMMAND(S)'
Write-Output '----------------'
Write-Output ''
Write-Output 'Select the .txt file that contains the command(s) to be executed against the selected IP(s).'
Write-Output ''
Write-Warning "Do not include the enable command as this can be configured in step 5/6"
Do
{
	Try {
		$inputFileCommands = Get-FileName .\
		$commandBlock = get-content $inputFileCommands
		$commandBlockRAW = get-content $inputFileCommands -raw
		If (($commandblock) -eq $Null) {
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
while(!$commandBlock)
Write-Output ''
Write-Output 'The following command(s) will be executed:'
Write-Output ''
Write-Host -ForegroundColor Green "$commandBlockRAW"
Write-Output ''
Write-Output 'Press any key to continue...'
[void][System.Console]::ReadKey($true)
Clear-Host

#endregion

#region CREDENTIALS

# Load in a list of possible usernames and passwords
# This is useful if there are multiple combinations of usernames and passwords across the list of devices

Clear-Host
Write-Output ''
Write-Output '-------------------'
Write-Output '(4/6) CREDENTIAL(S)'
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

# If the list of SSH devices are all Cisco then prompt for the enable password
# If there is no enable password, i.e. non-cisco then don't enter an enable password

Clear-Host
Write-Output ''
Write-Output '---------------------'
Write-Output '(5/6) ENABLE PASSWORD'
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

#region TIMEWAIT

# There is an issue running SSH commands in that there is no way to check if each command has completed
# Posh-SSH will send each command one after another without waiting which could cause incorrect configurations
# The workaround is to send each command individually and then wait a few seconds before sending the next
# Enter in seconds how long to wait. If devices are old and slow, enter a longer number
# TEST if possible before deciding on a number! Especially is using this to roll out configurations

Clear-Host
Write-Output ''
Write-Output '--------------------------------'
Write-Output '(6/6) TIME WAIT BETWEEN COMMANDS'
Write-Output '--------------------------------'
Write-Output ''
Write-Output 'Posh-SSH will not check to see if a command has been executed successfully.'
Write-Output 'In seconds, how long do you want to wait for each command to be executed?'
Write-Output ''
Write-Output 'Increase this for slower devices and if you do not see results.'
Write-Output ''
do{
    Try{
        [int]$timeWait = read-host "Enter seconds"
	    If (($timeWait) -is [string]) {
		Write-Output ''
		"You did not enter a number, please try again" 
		} 
    }
	Catch{
		Write-Output ''
		Write-Output 'You did not enter a number.'
		Write-Output ''
		Exit
		}
}
while(!$timeWait)
Write-Output ''
Write-Output 'Press any key to continue...'
[void][System.Console]::ReadKey($true)
Clear-Host

#endregion

#region SCRIPT SUMMARY

# Provide a summary to the user allowing user to exit if incorrect and start again

Clear-Host
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
if ($enablePassword){ 
    Write-Host -ForegroundColor Green "$enablePassword"
    } 
else{
    Write-Host -ForegroundColor Green "No enable password"
    }
Write-Output ''
Write-output 'Seconds to wait between commands:'
Write-Host -ForegroundColor Green "$timeWait"
Write-Output ''
Start-sleep 1
$message = 'Do you wish to continue?'
$result = $host.ui.PromptForChoice($title, $message, $optionsDisclaimer, 0)
switch ($result){
    0{
        Write-output "Start Script"
        Clear-Host    
    }1{
        Exit
    }
}

#endregion

#region START SCRIPT

# No turning back now...

Clear-Host

# Begin the script by looping for each IP address, saved as variable $inputData

$inputdata | ForEach-Object{

# Assign the current variable as $IP to be used later in script as $_ will change depending on which loop it's used in

$IP = $_

Clear-Host
Write-Output ''
Write-Output ''

# Display the current SSH device 

Write-host -ForegroundColor Green "CURRENT IP: $_" 
Write-Output ''
Write-Output ''
write-output "   Testing port 22 for $_"

# Test is port 22 is open

try{
    $t = New-Object Net.Sockets.TcpClient $_, 22 -ErrorAction stop
    if ($t.Connected){

    # If the port is open, then move onto attempting to login

        try{

        # Start a loop for the list of usernames provided stored as $credUsernames

        $credUsernames | ForEach-Object {
        
        # Add the current entry as $currentUsername

        $currentUsername = $_

        # Start another loop for each of the usernames to try each password provided

        $credPasswords | ForEach-Object {

            # Store the current password as $currentPassword

            $currentPassword = $_
            $secPassword = $_ | ConvertTo-SecureString -AsPlainText -Force
            $creds = New-Object System.Management.Automation.PSCredential `
            -ArgumentList $currentUsername, $secPassword
            try{
            Write-output "   Removing existing SSH sessions"

            # Remove existing SSH connections to start fresh

            Get-SSHSession | Remove-SSHSession
            Write-Output ''
            write-output "   Attempting to connect to $IP via SSH using $currentUsername / $currentPassword"
            Write-Output ''

            # Try and login using the provided credentials

            try{	
                
                # Create a new Post-SSH session
                # Use the -AcceptKey paramater to automatically accept

                New-SSHSession -Credential $creds -ComputerName $IP -AcceptKey -ErrorAction Stop
                $objectStream = ""
		        $stringStream = ""
		        $snmpStream = ""

                # Get the current session to create a new stream for sending commands

		        $session = Get-SSHSession -ComputerName $IP -Debug
		        Start-Sleep 1
		        Write-Output ''
		        write-output "   Attempting to create shell stream"
		        $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
		        Start-Sleep 1
		        Write-Output ''
		        write-output "   Running commands"

                # If the variable $enablePassword is not null, then attempt the Cisco enable password

                if ($enablePassword) 
                    { 

                    # Send the enable command and return

                    $stream.Write("en`n")
                    Start-Sleep 1

                    # Send the enable password and return

                    $stream.write("$enablePassword`n")
                    Start-Sleep 1

                    # This is where the commands are now sent to the SSH device

                    foreach ($line in $commandBlock)
                    {
                        $stream.write("$line`n")
                        Start-Sleep $timeWait
                    }
			    $objectStream = $stream.read()

                # Output the stream to the temporary directory

			    $objectStream | out-file $TARGETDIRTEMP\$IP.txt
			    $stringStream = get-content $TARGETDIRTEMP\$IP.txt
			    Start-Sleep 1
			    Write-Output ''
			    Write-Host -ForegroundColor Green "   Commands run successfully using $currentUsername / $currentPassword"
			    Write-Output ''
			    Write-Host -ForegroundColor Green "   Writing success to $TARGETDIR\ssh-successful.csv"
			    Write-Output ''
			    start-sleep 1
			    [pscustomobject]@{
			    IP = $IP
			    Completed = "Yes"
			    SSHPort = "Open"
			    Username = ($currentUsername | Out-String).Trim()
			    Password = ($currentPassword | Out-String).Trim()
			    Enable = ($enablePassword | Out-String).Trim()
			    Output = ($stringStream | Out-String).Trim()
			    } | Export-Csv $TARGETDIR\ssh-successful.csv -Append -NoTypeInformation
                	
            } 
            else

            # run without an enable password 

            {  
                foreach ($line in $commandBlock){
			$stream.write("$line`n")
			 Start-Sleep $timeWait
                }
			    $objectStream = $stream.read()
			    $objectStream | out-file $TARGETDIRTEMP\$IP.txt
			    $stringStream = get-content $TARGETDIRTEMP\$IP.txt
			    Start-Sleep 1
			    Write-Output ''
			    Write-Host -ForegroundColor Green "   Commands run successfully using $currentUsername / $currentPassword"
			    Write-Output ''
			    Write-Host -ForegroundColor Green "   Writing success to $TARGETDIR\ssh-successful.csv"
			    Write-Output ''
			    start-sleep 1
			    [pscustomobject]@{
			    IP = $IP
			    Completed = "Yes"
			    SSHPort = "Open"
			    Username = ($currentUsername | Out-String).Trim()
			    Password = ($currentPassword | Out-String).Trim()
			    Enable = ($enablePassword | Out-String).Trim()
			    Output = ($stringStream | Out-String).Trim()
			    } | Export-Csv $TARGETDIR\ssh-successful.csv -Append -NoTypeInformation
                
            }
}
        Catch 
            {
            # Sequence contains more than one element
            Write-Host -ForegroundColor Yellow "   Failed connecting to $IP using $currentUsername / $currentPassword"
            Write-Output ''
            Write-Host -ForegroundColor Yellow "   Writing failure to $TARGETDIR\ssh-failed.csv"
            Write-Output ''
            start-sleep 1
            $errorMsg = $_.Exception.Message
            [pscustomobject]@{
            IP = $IP
            Completed = "No"
            SSHPort = "Open"
            Username = ($currentUsername | Out-String).Trim()
            Password = ($currentPassword | Out-String).Trim()
            Enable = ($enablePassword | Out-String).Trim()
            Output = "Failed login"
            } | Export-Csv $TARGETDIR\ssh-failed.csv -Append -NoTypeInformation
            }
            Finally{Start-Sleep 1}				
            }
            catch{}
}
        }
        }
        catch{
            $errorMsg = $_.Exception.Message
            Write-warning $errorMsg
            Write-Host -ForegroundColor Yellow "   Failed connecting to $IP using $currentUsername / $currentPassword"
            Write-Output ''
            Write-Host -ForegroundColor Yellow "   Writing failure to $TARGETDIR\ssh-failed.csv"
            Write-Output ''
            start-sleep 1
            [pscustomobject]@{
            IP = $IP
            Completed = "Failed"
            SSHPort = "Unknown"
            Username = ($currentUsername | Out-String).Trim()
            Password = ($currentPassword | Out-String).Trim()
            Enable = ($enablePassword | Out-String).Trim()
            Output = $errorMsg
            } | Export-Csv $TARGETDIR\ssh-failed.csv -Append -NoTypeInformation
            }
        finally{start-sleep 1}
        
    }
        else
    {      
        Write-Output ''
        Write-Host -ForegroundColor Yellow "   Telnet port 22 is closed"
        Write-Output ''
        Write-Host -ForegroundColor Yellow "   Writing failure to $TARGETDIR\ssh-failed.csv"
        Write-Output ''
        start-sleep 1
        [pscustomobject]@{
        IP = $IP
        Completed = "Failed"
        SSHPort = "Closed"
        Username = ($currentUsername | Out-String).Trim()
        Password = ($currentPassword | Out-String).Trim()
        Enable = ($enablePassword | Out-String).Trim()
        Output = 'Telnet port 22 is closed'
        } | Export-Csv $TARGETDIR\ssh-failed.csv -Append -NoTypeInformation
    }
}
catch{
        $errorMsg = $_.Exception.Message
        Write-Output ''
        Write-Host -ForegroundColor Yellow "   An error occurred, possibly due to port closed or IP not responding"
        Write-Output ''
        Write-Host -ForegroundColor Yellow "   Writing failure to $TARGETDIR\ssh-failed.csv"
        start-sleep 2
        [pscustomobject]@{
        IP = $IP
        Completed = "Failed"
        SSHPort = "Unknown"
        Username = ($currentUsername | Out-String).Trim()
        Password = ($currentPassword | Out-String).Trim()
        Enable = ($enablePassword | Out-String).Trim()
        Output = $errorMsg
        } | Export-Csv $TARGETDIR\ssh-failed.csv -Append -NoTypeInformation
    }
finally{}
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