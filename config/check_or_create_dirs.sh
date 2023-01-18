#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "  check_or_create_dirs - Check or create directories"
  echo
  echo "DESCRIPTION"
  echo "	This script contains a function 'check_or_create_dirs' which is used to check and create directories specified as arguments."
  echo "	The function takes any number of directory paths as arguments and checks if they exist, if not it creates them."
  echo "	The function also prints messages to inform if a directory already exists or was created."
  exit 1
fi

check_or_create_dirs(){
	DIRECTORIES=("$@")
	for DIRECTORY in "${DIRECTORIES[@]}"; do
		if [ ! -d "$DIRECTORY" ]; then
			mkdir "$DIRECTORY"
			echo "$DIRECTORY does not exist. Creating directory..."
		else
			echo "${BLUE}$DIRECTORY already exists. Skipping this step${RESET}"
		fi
	done

	echo "${BLUE}${BOLD}Done!${RESET}"
}