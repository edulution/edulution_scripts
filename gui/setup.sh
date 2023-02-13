#!/bin/bash

# Source the script containg major functions
source $(dirname "${BASH_SOURCE[0]}")/functions.sh

# Get the current directory
CURRENT_DIR=$(dirname "$0")

# Create error log directory
DIRECTORIES=( ~/.logs )

# Create the logs directory if it does not exist
check_or_create_dirs "${DIRECTORIES[@]}"

# System-wide installation
sudo cp "$CURRENT_DIR"/edulution.desktop /usr/share/applications/

# Installation for current user
cp "$CURRENT_DIR"/edulution.desktop ~/.local/share/application

# Pin the edulution desktop entry to the taskbar launcher
gsettings set com.canonical.Unity.Launcher favorites "$(gsettings get com.canonical.Unity.Launcher favorites | sed "s/]/, 'edulution.desktop']/")"
