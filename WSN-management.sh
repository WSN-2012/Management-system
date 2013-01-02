#!/bin/bash
# 
# $1 is the gateway 
# $2 is the basestation
# $3 is the central server

COL1=20
COL2=650

HEIGHT_DIFF=200

function usage {
    echo "Usage: ./WSN-management.sh username@gateway username@basestation username@server"
}

function gateway {
    cmd="ssh -t -X $1 \"remountrw; soundmodemconfig; killall -v soundmodem; soundmodem; read -p Done...\""
    run "Gateway Soundmodem" "$cmd" $COL1 20
    run "Gateway Alsamixer" "ssh -t $1 \"/usr/bin/alsamixer\"" $COL1 $HEIGHT_DIFF
    run "Gateway Service" "ssh -t $1 \"cd; cd BPF-Gateway-Service; ant;read -p Done...\"" $COL1 500 
}

function basestation {
    nat="iptables --flush; iptables --table nat --flush; iptables --delete-chain; iptables --table nat --delete-chain; iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE; iptables --append FORWARD --in-interface sm0 -j ACCEPT"
    cmd="ssh -X -t $1 \"remountrw; $nat; soundmodemconfig; killall -v soundmodem; soundmodem; read -p Done....\""
    run "Basestation Soundmodem" "$cmd" $COL2 20
    run "Basestation Alsamixer" "ssh -t $1 \"/usr/bin/alsamixer\"" $COL2 300
}

function server {
    cmd="ssh -t $1 \"cd; cd BPF-Internet-Service; ant; bash ./run.sh; read -p Done...\""
    run "Server" "$cmd" $COL2 500
}

function run {
    echo "Running command: $2 in shell $1"
    xterm -T "$1" -geometry 100x40+$3+$4 -e "$2" &
}

# Check the params
if [ $# -ne 3 ]; then
    usage
    exit 0
fi

# Run the gateway
gateway "$1"

# Run the base station 
basestation "$2"

# Run the server
server "$3"



