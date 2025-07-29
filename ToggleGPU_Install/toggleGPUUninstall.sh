#!/bin/bash

#clean up install directory
rm -rf "$HOME/ToggleGPU"

#remove desktop entry
rm -f "$HOME/.local/share/applications/toggleGPU.desktop"

echo "ToggleGPU has been removed"
