#!/bin/sh
# This script should only be ran once on each device to configure the tunnel!
# generate ssh keys
ssh-keygen -t dsa
#if ssh keys already exist, don't overwrite!
# add ssh keys to known hosts on our google server
cat ~/.ssh/id_dsa.pub | sshpass -p "$SSHPASS" ssh -l edulution 130.211.93.74 "[ -d /home/edulution/.ssh ] || mkdir -m 700 /home/edulution/.ssh; cat >> /home/edulution/.ssh/authorized_keys"
# install openssh server if not already installed
sudo apt-get install -y openssh-server
#allow incoming connections on port 22
sudo ufw allow 22

