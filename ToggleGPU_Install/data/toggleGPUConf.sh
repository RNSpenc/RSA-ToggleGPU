#!/bin/bash
# toggleGPU.sh

CONFIG_FILE="$HOME/ToggleGPU/toggleGPU.conf"

# List all VGA and 3D controllers
mapfile -t gpu_list < <(lspci -nn | grep -Ei "VGA|3D|Display controller")

if [ "${#gpu_list[@]}" -eq 0 ]; then
    echo "No GPU devices found."
    exit 1
fi

echo "Available GPU devices:"
for i in "${!gpu_list[@]}"; do
    echo "[$i] ${gpu_list[$i]}"
done

#handle input for user request for the GPU to toggle
while true; do
    read -p "Enter the number of the discrete GPU to toggle, if no discrete cards appear, quit.\n
    DO NOT select integrated graphics or your display might break. (q to quit): " choice

    if [[ "$choice" == "q" ]]; then
        echo "Quitting setup."
        exit 0
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -lt "${#gpu_list[@]}" ]; then
        break  # Valid selection made
    else
        echo "Invalid selection. Please enter a number from the list or q to quit."
    fi
done


selected_line="${gpu_list[$choice]}"
pci_id="$(echo "$selected_line" | awk '{print $1}')"

# Attempt to detect driver
driver_path="/sys/bus/pci/devices/$pci_id/driver"
if [ -L "$driver_path" ]; then
    driver=$(basename "$(readlink "$driver_path")")
else
     # Fallback to lspci -k
    driver=$(lspci -nnk -s "${pci_id#0000:}" | awk -F: '/Kernel driver in use:/ {gsub(/^[ \t]+/, "", $2); print $2}')
    if [[ -z "$driver" ]]; then
        driver="unknown"
    fi
fi

# Save to config
cat <<EOF > "$CONFIG_FILE"
PCI_ID=$pci_id
GPU=$GPU
DRIVER=$driver
EOF

echo "Configuration saved to $CONFIG_FILE:"
echo "  PCI_ID=$pci_id"
echo "  DRIVER=$driver"
