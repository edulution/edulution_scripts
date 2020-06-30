#!/bin/bash

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