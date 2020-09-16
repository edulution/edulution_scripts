#!/bin/bash

check_package_installed(){
	package_name=$1

	# Check if a package is installed and inform the user
	# shellcheck disable=SC2086
	if [ "$(which $package_name)" != "" ]
	then
	  echo "${BLUE}$package_name is already installed.${RESET}"
	  
	else
	  echo "${RED}${BOLD}$package_name is not installed.${RESET}"
	fi
}
