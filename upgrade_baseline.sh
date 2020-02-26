#!/bin/bash

#Switch to home directory
cd ~

# Check if client script exists 
test -f ~/.baseline_testing/scripts/startup_script
if [ "$?" = "0" ]; then
	echo "${blue}Baseline Testing already configured${reset}"
	cd ~/.baseline_testing/
	echo "Pulling latest changes to Baseline system..."
	git pull origin zambia > /dev/null

	#make script executable if it isnt
	chmod +x ~/.baseline_testing/scripts/setup.sh
	~/.baseline_testing/scripts/setup.sh
else
	echo "${yellow}Baseline system not configured correctly or missing from system${reset}"
	rm -rf ~/.baseline_testing
	echo "${blue}Cloning repository...${reset}"
	git clone https://github.com/techZM/offline_testing.git .baseline_testing > /dev/null
	cd ~/.baseline_testing/
	git checkout zambia

	#make script executable if it isnt
	chmod +x ~/.baseline_testing/scripts/setup.sh
	~/.baseline_testing/scripts/setup.sh
fi
