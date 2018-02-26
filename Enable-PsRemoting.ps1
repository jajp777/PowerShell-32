workflow PSRemoting {

$computers = get-content "C:\list.txt"

foreach -parallel -throttlelimit 16 ($computer in $computers)
    {
if(Test-Connection -ComputerName $computer -BufferSize 16 -Count 1 -Quiet)
    {
    psexec -s \\$computer powershell.exe Enable-PSRemoting -force
    }
else{
    "$computer is offline"
    }
    }

}

#Run this to actually start the workflow
PSRemoting