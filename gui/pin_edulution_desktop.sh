#!/bin/bash
# Pin the edulution desktop entry to the taskbar launcher
gsettings set com.canonical.Unity.Launcher favorites "$(gsettings get com.canonical.Unity.Launcher favorites | sed "s/]/, 'edulution.desktop']/")"
