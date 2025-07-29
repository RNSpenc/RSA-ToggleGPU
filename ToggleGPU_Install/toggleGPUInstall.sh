#!/bin/bash

set -e
echo "Running ToggleGPU install script..."

#make ToggleGPU directory in home
INSTALL_DIR="$HOME/ToggleGPU"
mkdir -p "$INSTALL_DIR"

#copy ToggleGPU config script, icon, and ToggleGPU shell script from ToggleGPU_vX.X.X data directory to ToggleGPU directory
cd data
cp toggleGPUConf.sh ToggleGPU.sh icon.png "$INSTALL_DIR"

#create ToggleGPU desktop file for toggleGPU.sh and add to applications
DESKTOP_FILE="$HOME/.local/share/applications/ToggleGPU.desktop"
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=ToggleGPU
Comment=Enable or disable a secondary GPU
Exec=$INSTALL_DIR/ToggleGPU.sh
Icon=$INSTALL_DIR/icon.png
Terminal=true
Type=Application
Categories=System;Utility;
EOF

chmod +x "$INSTALL_DIR/ToggleGPU.sh"
chmod +x "$DESKTOP_FILE"

#run config script from ToggleGPU directory to ask user for GPU to toggle and create config file.
echo "Data installed, running config script..."
bash "$INSTALL_DIR/toggleGPUConf.sh"

echo "Installation complete"
