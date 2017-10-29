#!/bin/bash

# increase correct streak by replacing distributed/settings.py file

sudo rm /usr/lib/python2.7/dist-packages/kalite/distributed/settings.py
echo "Removing old distributed settings file"
sudo cp ~/.scripts/config/settings.py /usr/lib/python2.7/dist-packages/kalite/distributed/
echo "Copied new distributed settings file"