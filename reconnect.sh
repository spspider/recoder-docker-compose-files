#!/bin/bash
while true; do
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo "Network down, attempting to reconnect..."
        sudo systemctl restart NetworkManager
    fi
    sleep 60
done
