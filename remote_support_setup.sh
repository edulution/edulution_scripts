#!/bin/bash

#Switch to home directory
cd ~ || exit

# Check if client script exists 
if test -f ~/.remote_support/client.py; then
	echo "Client script found"
	cd ~/.remote_support/ || exit
	echo "Pulling latest changes to Client script..."
	git pull > /dev/null
	./setup.sh > /dev/null
	echo "Checking if requirements satisfied.."
	./send_device_information.sh > /dev/null
else
	echo "Client script not found"
	echo "Removing old code if found"
	rm -rf ~/.remote_support
	echo "Cloning new client script"
	git clone https://github.com/techZM/remote_support_client.git .remote_support > /dev/null
	cd ~/.remote_support/ || exit
	./setup.sh > /dev/null
	echo "Checking if requirements satisfied.."
	./send_device_information.sh > /dev/null

fi