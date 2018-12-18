#!/bin/sh

#Switch to home directory
cd ~

# Check if client script exists 
test -f ~/.baseline_testing/scripts/startup_script
if [ "$?" = "0" ]; then
	echo "Baseline Testing already configured"
	cd ~/.baseline_testing/
	echo "Pulling latest changes to Baseline system..."
	git pull origin master
	./scripts/setup.sh
else
	echo "Baseline system not configured correctly or missing from system"
	rm -rf ~/.baseline_testing
	echo "Cloning repository..."
	git clone https://github.com/techZM/offline_testing.git .baseline_testing
	cd ~/.baseline_testing/
	./scripts/setup.sh
fi
