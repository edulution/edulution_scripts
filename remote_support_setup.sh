#!/bin/sh

#Switch to home directory
cd ~

# Check if client script exists 
test -f ~/.remote_support/client.py
if [ "$?" = "0" ]; then
	echo "Client script found"
	cd ~/.remote_support/
	echo "Pulling latest changes to Client script..."
	git pull
	./setup.sh
	echo "Checking if requirements satisfied.."
	./send_device_information.sh
else
	echo "Client script not found"
	echo "Removing old code if found"
	rm -rf ~/.remote_support
	echo "Cloning new client script"
	git clone https://github.com/techZM/remote_support_client.git .remote_support
	cd ~/.remote_support/
	./setup.sh
	echo "Checking if requirements satisfied.."
	./send_device_information.sh

fi