#!/bin/bash
function local_nic() {
    local NUM ARRAY_LENGTH
    NUM=0
    for NIC_NAME in $(ls /sys/class/net|grep -vE "lo|docker0"); do
        NIC_IP=$(ifconfig $NIC_NAME |awk -F'[: ]+' '/inet addr/{print $4}')
        if [ -n "$NIC_IP" ]; then
            NIC_IP_ARRAY[$NUM]="$NIC_NAME:$NIC_IP"    
            let NUM++
        fi
    done
    ARRAY_LENGTH=${#NIC_IP_ARRAY[*]}
    if [ $ARRAY_LENGTH -eq 1 ]; then     
        NIC=${NIC_IP_ARRAY[0]%:*}
        return 0
    elif [ $ARRAY_LENGTH -eq 0 ]; then   
        echo "No available network card!"
        exit 1
    else
        for NIC in ${NIC_IP_ARRAY[*]}; do
            echo $NIC
        done
        while true; do
            read -p "Please enter local use to network card name: " INPUT_NIC_NAME
            COUNT=0
            for NIC in ${NIC_IP_ARRAY[*]}; do
                NIC_NAME=${NIC%:*}
                if [ $NIC_NAME == "$INPUT_NIC_NAME" ]; then
                    NIC=${NIC_IP_ARRAY[$COUNT]%:*}
                    return 0
                else
                   COUNT+=1
                fi
            done
            echo "Not match! Please input again."
        done
    fi
}
local_nic
