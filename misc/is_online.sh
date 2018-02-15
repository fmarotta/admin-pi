#!/bin/bash
# Checks every 10 minutes if the network is reachable; if it is not for two
# consecutive times, it shuts the machine down. It is useful if the machine is
# connected to a backup battery, because this script can prevent a sudden loss
# of power, and hence hardware damage. 
# Here the reachability of the network is used as representative of the
# electrical status of the house: if there is a black out the modem will not
# work. This is a conservative measure, but I cannot afford other black outs.
# By the way, this daemon will also log every time the network is down.

GATEWAY=`ip route | grep default | cut -d ' ' -f 3`

function is_online {
    # NOTE: even if google is pretty reliable, no site is 100% secure. Also,
    # wgetting google is not the best choice because if there is a problem
    # with Internet, but electrically speaking the house is good, the machine
    # will shut down. The most secure thing, I think, is to ping our modem.
    # That way, only in case of an hardware failure will the machine be
    # affected. Thus I am abandoning wget in favor of ping.
    # wget -q --spider https://google.com && return 0 || return 1

    sudo ping -I eth0 -r -c 3 -w 3 -q $GATEWAY &> /dev/null \
        && return 0 || return 1
}

SECOND=0
while true
do
    if is_online
    then
        #echo "I'm online."
        SECOND=0
    else
        if [ $SECOND -eq 0 ]
        then
            #echo "I'm in danger, do something now!"
            echo "$(date): the modem is unreachable." \
                >> ../log/is_online.log
            SECOND=1
        elif [ $SECOND -eq 1 ]
        then
            #echo "Too late, I'm dying :("
            echo "$(date): the machine is going into apoptosis." \
                >> ../log/is_online.log
            sudo shutdown now --no-wall
        fi
    fi

    sleep 10m
done

