#!/bin/bash

check_package_installed(){
	package_name=$1

	# check if postgresql is installed. Alert user to contact support if it is not installed
	# shellcheck disable=SC2086
	if [ "$(which $package_name)" != "" ]
	# if [ "$(dpkg -l | grep "$package_name")" -eq 0 ];
	then
	  echo "${BLUE}$package_name is already installed.${RESET}"
	  
	else
	  echo "${RED}${BOLD}$package_name is not installed.${RESET}"
	fi
}
