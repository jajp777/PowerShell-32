# Get IP of a remote server 
Get-WmiObject Win32_NetworkAdapterConfiguration -computername <servername> | Select IPAddress, Description, DefaultGateway  
 
# Check if a port is open 
(New-Object Net.Sockets.TcpClient).Connect("127.0.0.1",139) #TCP   
(New-Object Net.Sockets.UdpClient).Connect("<remote machine>",<port>) #UDP   
 
# Download a test file 
"{0:N2} Mbit/sec" -f ((10/(Measure-Command {Invoke-WebRequest 'http://client.akamai.com/install/test-objects/10MB.bin'|Out-Null}).TotalSeconds)*8)   
"{0:N2} Mbit/sec" -f ((10/(Measure-Command {Copy-Item \\servername\d$\test\MBX01.cap -destination D:\test}).TotalSeconds)*8)  
 
# Ping every millisecond 
while($true){   
test-connection google.com -count 1 |   
select @{N='Time';E={[dateTime]::Now}},   
@{N='Destination';E={$_.address}},   
replysize,   
@{N='Time(ms)'; E={$_.ResponseTime}}   
}   
 
# Find IP address assigned by DHCP 
Get-NetIPAddress | Where-Object PrefixOrigin -eq dhcp| Select-Object -ExpandProperty IPAddress   
 
# Find IP address by location 
function Get-IPLocation([Parameter(Mandatory)]$IPAddress)   
{   
    Invoke-RestMethod -Method Get -Uri "http://geoip.nekudo.com/api/$IPAddress" |   
      Select-Object -ExpandProperty Country -Property City, IP, Location   
}   
 
#Working with netstat   
$a = netstat   
$a[4..$a.count] | ConvertFrom-String | select p2,p3,p4,p5 | where p4 -match '10.216'   
   
#Add static ARP entry   
arp -s 10.1.254.20 00-15-f2-d0-d8-87 10.1.254.2   
   
#Show ARP entries   
arp -a   
   
#Delete ARP entries   
arp -d   
   
#Ping from specific adapter   
ping -S $from $to   

<# Wireshark filters #>
# Fragmented packets	 
ip.flags.mf ==1 or ip.frag_offsetgt0  
 
# Packet loss	 
tcp.analysis.lost_segment  
 
# CDP	 
Cdp 
 
# DHCP	 
Bootp 

<# TCPDUMP #>
# Capture host any direction, any interface, show output
tcpdump host <ip> -i any -l

# TCPDump
# Capture traffic of a specific host on all interfaces
tcpdump -i any ‘host x.x.x.x’

# Add the -e parameter to see the interface MAC of a packet flow
tcpdump -e ‘host x.x.x.x’