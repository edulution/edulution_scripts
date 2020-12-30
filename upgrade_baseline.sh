#!/bin/bash

#Switch to home directory
cd ~ || exit

# Check if client script exists 
if test -f ~/.baseline_testing/scripts/startup_script; then
	echo "${BLUE}Baseline Testing already configured${RESET}"
	cd ~/.baseline_testing/ || exit
	echo "Pulling latest changes to Baseline system..."
	git pull origin develop > /dev/null

	#make script executable if it isnt
	chmod +x ~/.baseline_testing/scripts/setup.sh
	~/.baseline_testing/scripts/setup.sh
else
	echo "${YELLOW}Baseline system not configured correctly or missing from system${RESET}"
	rm -rf ~/.baseline_testing
	echo "${BLUE}Cloning repository...${RESET}"
	git clone https://github.com/edulution/offline_testing.git .baseline_testing > /dev/null
	cd ~/.baseline_testing/ || exit
	git checkout develop

	#make script executable if it isnt
	chmod +x ~/.baseline_testing/scripts/setup.sh
	~/.baseline_testing/scripts/setup.sh
fi
