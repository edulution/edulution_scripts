#!/bin/bash

# System-wide installation
sudo cp ~/.scripts/gui/edulution.desktop /usr/share/applications/

# Installation for current user
cp ~/.scripts/gui/edulution.desktop ~/.local/share/application

# Pin the edulution desktop entry to the taskbar launcher
gsettings set com.canonical.Unity.Launcher favorites "$(gsettings get com.canonical.Unity.Launcher favorites | sed "s/]/, 'edulution.desktop']/")"
