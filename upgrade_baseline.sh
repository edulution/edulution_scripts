#!/bin/bash

#colors
#=======
export black=`tput setaf 0`
export red=`tput setaf 1`
export green=`tput setaf 2`
export yellow=`tput setaf 3`
export blue=`tput setaf 4`
export magenta=`tput setaf 5`
export cyan=`tput setaf 6`
export white=`tput setaf 7`

# reset to default bash text style
export reset=`tput sgr0`

# make actual text bold
export bold=`tput bold`

# make background color on text
export bold_mode=`tput smso`

# remove background color on text
export exit_bold_mode=`tput rmso`

#Switch to home directory
cd ~

# Check if client script exists 
test -f ~/.baseline_testing/scripts/startup_script
if [ "$?" = "0" ]; then
	echo "${blue}Baseline Testing already configured${reset}"
	cd ~/.baseline_testing/
	echo "Pulling latest changes to Baseline system..."
	git pull origin kolibri > /dev/null

	#make script executable if it isnt
	chmod +x ~/.baseline_testing/scripts/setup.sh
	~/.baseline_testing/scripts/setup.sh
else
	echo "${yellow}Baseline system not configured correctly or missing from system${reset}"
	rm -rf ~/.baseline_testing
	echo "${blue}Cloning repository...${reset}"
	git clone https://github.com/techZM/offline_testing.git .baseline_testing > /dev/null
	cd ~/.baseline_testing/

	#make script executable if it isnt
	chmod +x ~/.baseline_testing/scripts/setup.sh
	~/.baseline_testing/scripts/setup.sh
fi
