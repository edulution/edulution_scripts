#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "  increase_session_timeout - Increase session timeout"
  echo
  echo "DESCRIPTION"
  echo "	This script is used to increase the idle session timeout to 15 minutes. It does this by using the 'sed' command to replace"
  echo "	 the value 720 in the KOLIBRI_SESSION_TIMEOUT variable in the .bashrc file with the value 900."
  exit 1
fi

#Increase idle session timeout to 15 mins
sudo sed -i 's/KOLIBRI_SESSION_TIMEOUT=720/KOLIBRI_SESSION_TIMEOUT=900/g' ~/.bashrc