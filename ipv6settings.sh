#!/bin/bash

# ip6tables
# by Ray-works.de
# Update: 21.10.2013

#########################
# Configuration
#########################

INTERFACE=eth0
IPTABLES=`which ip6tables`

# TCP & UDP Ports for incoming traffic
INTCPPORTS=""
INUDPPORTS=""

# TCP & UDP Ports for outgoing traffic
OUTTCPPORTS=""
OUTUDPPORTS=""

# SSH Port for extra protection via limits
SSHPORT=""

#########################
# Turn iptables (for IPv6) on
#########################
function on {
       	
# Flush & default
$IPTABLES -F

# Block Everything
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP

# New Chain for logging
$IPTABLES -N LOGNDROP
$IPTABLES -A LOGNDROP -j LOG -m limit --limit 1/min --log-prefix "[Dropped IPv6]: " --log-level 7
$IPTABLES -A LOGNDROP -j DROP

# New Chain for portscan logging
$IPTABLES -N PORTSCAN
$IPTABLES -A PORTSCAN -j LOG -m limit --limit 1/min --log-prefix "[Portscan IPv6]: " --log-level 7
$IPTABLES -A PORTSCAN -j DROP

# Allow Protocol 41
$IPTABLES -I INPUT 1 -p 41 -j ACCEPT

# Allow established and related connection
$IPTABLES -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A OUTPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

$IPTABLES -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A OUTPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow ICMP
$IPTABLES -A INPUT -p icmpv6 -j ACCEPT
$IPTABLES -A OUTPUT -p icmpv6 -j ACCEPT

# Allow internal addresses
$IPTABLES -A INPUT -s fe80::/10 --jump ACCEPT
$IPTABLES -A OUTPUT -s fe80::/10 --jump ACCEPT

# Allow DNS Lookup
$IPTABLES -A OUTPUT -p udp --dport 53 -j ACCEPT

#
# TCP & UDP Ports for incoming traffic
#

for PORT in $INTCPPORTS; do
	$IPTABLES -A INPUT -p tcp -i $INTERFACE --dport $PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
done;

for PORT in $INUDPPORTS; do
	$IPTABLES -A INPUT -p udp -i $INTERFACE --dport $PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
done;

#
# TCP & UDP Ports for outgoing traffic
#

for PORT in $OUTTCPPORTS; do
	$IPTABLES -A OUTPUT -p tcp -o $INTERFACE --dport $PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
done;

for PORT in $OUTUDPPORTS; do
	$IPTABLES -A OUTPUT -p udp -o $INTERFACE --dport $PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
done;

# Deny more than 3 connection attempts per 10 minutes (SSH)
$IPTABLES -A INPUT -p tcp --dport $SSHPORT -m state --state NEW -m recent --set --name SSH
$IPTABLES -A INPUT -p tcp --dport $SSHPORT -m state --state NEW -m recent --update --seconds 600 --hitcount 4 --rttl --name SSH -j LOGNDROP

# Limit connections per minute from single ip to 10 (HTTP)
$IPTABLES -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --set --name http
$IPTABLES -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 --rttl --name http -j LOGNDROP

# Rate limit ICMP (ping) packets
$IPTABLES -I INPUT -p ipv6-icmp --icmpv6-type echo-request -m recent --set
$IPTABLES -I INPUT -p ipv6-icmp --icmpv6-type echo-request -m recent --update --seconds 10 --hitcount 5 -j LOGNDROP

# Drop all invalid packets
$IPTABLES -A INPUT -m state --state INVALID -j LOGNDROP
$IPTABLES -A FORWARD -m state --state INVALID -j LOGNDROP
$IPTABLES -A OUTPUT -m state --state INVALID -j LOGNDROP

# Drop new connections without the SYN flag set
$IPTABLES -A INPUT -p tcp ! --syn -m state --state NEW -j PORTSCAN

# syn flood limitation
$IPTABLES -A INPUT -p tcp --syn -m limit --limit 5/s --limit-burst 10 -j LOG --log-prefix "SYN flood: " 
$IPTABLES -A INPUT -p tcp --syn -j DROP

# Portscan: Drop ALL
$IPTABLES -A INPUT -p tcp --tcp-flags ALL ALL -j PORTSCAN

# Portscan: Drop FIN + URG + PSH
$IPTABLES -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j PORTSCAN

# Portscan: Drop nmap Null scan
$IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j PORTSCAN

# Portscan: Drop nmap FIN stealth scan
$IPTABLES -A INPUT -p tcp --tcp-flags ALL FIN -j PORTSCAN

# Portscan: Drop XMAS
$IPTABLES -A INPUT -p tcp --tcp-flags ALL URG,ACK,PSH,RST,SYN,FIN -j PORTSCAN

# Portscan: Other combinations
$IPTABLES -A INPUT -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j PORTSCAN
$IPTABLES -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j PORTSCAN
$IPTABLES -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j PORTSCAN
$IPTABLES -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j PORTSCAN
$IPTABLES -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j PORTSCAN
$IPTABLES -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j PORTSCAN
$IPTABLES -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j PORTSCAN
$IPTABLES -A INPUT -p tcp --tcp-flags ACK,URG URG -j PORTSCAN

echo "Firewall ($IPTABLES): enabled."

}


#########################
# Turn ip6tables off
#########################

function off {

$IPTABLES -F
$IPTABLES -X
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT

echo "Firewall ($IPTABLES): disabled. (allowing all access)"

}

#########################
# Script usage
#########################

case "$1" in
    start)
	on
    ;;
    stop)
	off
    ;;
    restart)
       off
	sleep 3;
       on
    ;;
    *)
	echo "$0 {start|stop|restart}"
	echo "Start executes primary ruleset."
	echo "Stop disables all filtering"
	echo "restart clears then enables"
    ;;
esac