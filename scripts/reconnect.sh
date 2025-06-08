#!/bin/bash

# Interface to reset (change this if needed)
INTERFACE="enp2s0"


# Check if ping works
ping -c 2 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "$(date): Internet down, trying to reconnect..." | tee -a /log/net-reconnect.log

    # Restart networking (choose based on your setup)
    if systemctl is-active --quiet NetworkManager; then
        systemctl restart NetworkManager
        sleep 3
        nmcli networking off && sleep 2 && nmcli networking on
    elif systemctl is-active --quiet systemd-networkd; then
        systemctl restart systemd-networkd
    else
        ip link set $INTERFACE down
        sleep 2
        ip link set $INTERFACE up
        dhclient $INTERFACE
    fi

    # Optionally re-apply netplan if it's used
    if ls /etc/netplan/*.yaml 1>/dev/null 2>&1; then
        netplan apply
    fi

    echo "$(date): Reconnection attempt complete." | tee -a /log/net-reconnect.log
else
    # echo "$(date): Internet is working." | tee -a /log/net-reconnect.log
fi
