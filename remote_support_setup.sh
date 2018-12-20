#!/bin/bash

#Switch to home directory
cd ~

# Check if client script exists 
test -f ~/.remote_support/client.py
if [ "$?" = "0" ]; then
	echo "Client script found"
	cd ~/.remote_support/
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
	cd ~/.remote_support/
	./setup.sh > /dev/null
	echo "Checking if requirements satisfied.."
	./send_device_information.sh > /dev/null

fi