#!/usr/bin/env sh
echo 'enabling firewall... '

# use full paths so it works properly when run from crontab @reboot
T=$(which iptables)
T6=$(which ip6tables)

default(){
    $1 -F; $1 -X
    $1 -P INPUT DROP
    $1 -P FORWARD DROP
    $1 -P OUTPUT DROP
    $1 -A INPUT -i lo -j ACCEPT
    $1 -A OUTPUT -o lo -j ACCEPT
}
default $T
default $T6

# aout <udp|tcp> <port>
aout() {
    $T -A INPUT  -p $1 --sport $2 -j ACCEPT
    $T -A OUTPUT -p $1 --dport $2 -j ACCEPT
}
# ain <udp|tcp> <port>
ain() {
    $T -A INPUT -p $1 --dport $2 -j ACCEPT
    $T -A OUTPUT -p $1 --sport $2 -j ACCEPT
}

# always allow outbound dns, ntp, splunk, http, and https
aout udp 53
aout udp 123
aout udp 514
aout tcp 80
aout tcp 443

# allow pings in and out (0: echo-reply, 8: echo-request)
aping(){ 
    $T -A $1 -p icmp --icmp-type $2 -j ACCEPT 
}
aping INPUT 8
aping OUTPUT 8
aping INPUT 0
aping OUTPUT 0

# allow server side ports
ain tcp 22
ain tcp 80

echo 'done'
