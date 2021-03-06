#!/bin/bash

test_report_submission(){
	# Send testfile to make sure scripts are correctly set up
	touch ~/.reports/test.R

	# Populate the test file with the output of the whoru script
	~/.scripts/identify/whoru >> ~/.reports/test.R

	# Test the report submission by sending the test file
	echo "${WHITE}${BOLD}Testing report submission...${RESET}"

	# if connection lost the script will exit with status 1 and output error message
	if sshpass -p "$SSHPASS" scp ~/.reports/test.R edulution@130.211.93.74:/home/edulution/reports; then
		echo "${GREEN}${BOLD}Report submitted successfully!${RESET}"
		echo "${GREEN}${BOLD}Scripts have been set up correctly${RESET}"
	else
		echo "${RED}${BOLD}Something went wrong or internet connection was lost${RESET}" 1>&2
		exit 1
	fi

	# Delete testfile
	rm ~/.reports/test.R
}
