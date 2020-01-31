#!/bin/bash

#Increase idle session timeout to 15 mins
sudo sed -i 's/KOLIBRI_SESSION_TIMEOUT=720/KOLIBRI_SESSION_TIMEOUT=900/g' .bashrc