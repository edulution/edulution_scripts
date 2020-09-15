#!/bin/bash

check_package_installed(){
	package_name=$1

	# check if postgresql is installed. Alert user to contact support if it is not installed
	#if [ "$(dpkg-query -W -f='${Status}' postgresql 2>/dev/null | grep -c 'ok installed')" -eq 0 ];
	if [ "$(dpkg -l | grep "$package_name")" -eq 0 ];
	then
	  echo "${RED}${BOLD}$package_name is not installed. Please contact support${RESET}"
	  
	else
	  echo "${BLUE}$package_name is already installed. Skipping..${RESET}"
	fi
}
