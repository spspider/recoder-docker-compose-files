#!/bin/bash  
  
# Path to the log file  
LOG_FILE="/var/log/ram_badblocks.log"  
  
# Path to the grub configuration file  
GRUB_CONFIG="/etc/default/grub"  
  
# Test size for memtester (adjust based on available free RAM, e.g., 256M)  
TEST_SIZE="256M"  
  
# Function to log messages  
log_message() {  
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"  
}  
  
# Run memtester and capture bad memory addresses  
log_message "Starting RAM test with memtester..."  
MEMTEST_OUTPUT=$(memtester $TEST_SIZE 1 2>&1)  
  
# Check if memtester found any errors  
if echo "$MEMTEST_OUTPUT" | grep -q "FAILURE"; then  
    log_message "RAM errors detected. Extracting bad addresses..."  
    BAD_ADDRESSES=$(echo "$MEMTEST_OUTPUT" | grep -oP '0x[0-9a-fA-F]+' | sort -u)  
else  
    log_message "No RAM errors detected."  
    exit 0  
fi  
  
# Function to update GRUB with bad RAM addresses  
update_grub_badram() {  
    log_message "Updating GRUB configuration with bad RAM addresses..."  
    BADRAM_STR=""  
  
    for ADDR in $BAD_ADDRESSES; do  
        BADRAM_STR="${BADRAM_STR}${ADDR},"  
    done  
  
    # Remove trailing comma  
    BADRAM_STR=${BADRAM_STR%,}  
  
    # Update the GRUB configuration  
    if grep -q "^GRUB_BADRAM=" "$GRUB_CONFIG"; then  
        sed -i "s/^GRUB_BADRAM=.*/GRUB_BADRAM=\"$BADRAM_STR\"/" "$GRUB_CONFIG"  
    else  
        echo "GRUB_BADRAM=\"$BADRAM_STR\"" >> "$GRUB_CONFIG"  
    fi  
  
    # Update GRUB  
    log_message "Updating GRUB bootloader..."  
    grub-mkconfig -o /boot/grub/grub.cfg  
}  
  
# Update GRUB with the bad memory addresses  
update_grub_badram  
  
log_message "RAM test completed. System will avoid bad memory areas after reboot."  