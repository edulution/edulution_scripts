#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "   check_package_installed - Check package installed"
  echo
  echo "DESCRIPTION"
  echo "	This script contains a function 'check_package_installed' which is used to check if a package is installed on the system."
  echo "	The function takes the package name as the argument, and checks if it is already installed by using the 'which' command."
  echo "	If the package is installed it informs the user, otherwise it prompts the user that the package is not installed."
  echo 
  exit 1
fi

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
