#!/bin/bash

# Create reverse ssh tunnel to Edulution cloud server
createTunnel() {
	if sshpass -p $SSHPASS /usr/bin/ssh -N -R 19999:localhost:22 edulution@130.211.93.74; then
		echo Tunnel to Edulution created successfully
	else
		echo An error occurred creating a tunnel to Edulution
	fi
}

# if there is no process id for ssh, create a new tunnel connection
if /bin/pidof ssh; then
	echo "Creating a tunnel connection to Edulution..."
	echo "Press CTRL + C or close this terminal to stop"
	createTunnel
fi