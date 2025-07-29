#!/bin/bash
#ToggleGPU.sh

CONFIG_FILE="$HOME/ToggleGPU/toggleGPU.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Missing configuration file: $CONFIG_FILE"
    echo "Run toggleGPUInstall.sh first."
    exit 1
fi

source "$CONFIG_FILE"

if [[ "$DRIVER" == "unknown" ]]; then
    echo "Warning: GPU driver is unknown. Aborting."
    exit 1
fi

echo "Using PCI_ID: $PCI_ID"
echo "Using DRIVER: $DRIVER"

#if GPU detected, then remove
if [ -e /sys/bus/pci/drivers/$DRIVER/$PCI_ID ]; then
    echo "GPU is bound. Unbinding and removing..."
    echo $PCI_ID | sudo tee /sys/bus/pci/drivers/$DRIVER/unbind
    echo "removing from PCIe"
    echo 1 | sudo tee /sys/bus/pci/devices/$PCI_ID/remove

#if not, scan and add
else
    echo "GPU unbound. Rescanning PCIe and rebinding..."
    echo 1 | sudo tee /sys/bus/pci/rescan
    
    # Wait until device appears again after rescan
    for i in {1..10}; do
        if [ -e /sys/bus/pci/devices/$PCI_ID ]; then
        	break
   	 fi
   	 sleep 0.2
         echo "Waiting for GPU to be found..."
    done

    echo "Binding GPU."
    # Check if already bound
    if [ -e /sys/bus/pci/drivers/$DRIVER/$PCI_ID ]; then
         echo "GPU already bound."
    else
         echo "Binding GPU."
         echo $DRIVER | sudo tee /sys/bus/pci/devices/$PCI_ID/driver_override > /dev/null
         echo $PCI_ID | sudo tee /sys/bus/pci/drivers/$DRIVER/bind > /dev/null
    fi
    echo "" | sudo tee /sys/bus/pci/devices/$PCI_ID/driver_override > /dev/null

fi

