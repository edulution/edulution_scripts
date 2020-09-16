#!/bin/bash
# shellcheck source=/dev/null

# Function to check for a file, then create or replace
check_file_and_replace(){
	# Args:
	# 	$1 file to check for
	# 	$2 file to create or replace it with
	# 	$3 (1 or 0) Source the file immediately after creating or replacing it

	# convert command line args to local vars
	local expected_file_path=$1
	local replace_with_file=$2
	local source_flag=$3

	# name of the expected file (without the path)
	local expected_file_name
	expected_file_name=$(basename "$1")

	# Directoty where expected file is found
	local expected_file_dir
	expected_file_dir=$(dirname "$(realpath "$expected_file_path")")

	# Check if file already exists
	if test -f "$expected_file_path"; then
		# If exists, replace it with latest version
		echo "$expected_file_name already exists. Replacing with $replace_with_file"
		sudo rm "$expected_file_path"
		cp "$replace_with_file" "$expected_file_dir"
	else
		# If not, create it
		echo "$expected_file_name does not exist. Creating it in $expected_file_dir"
		cp "$replace_with_file" "$expected_file_dir"
	fi

	# If -s flag was passed in, source the file after creating/replacing it
	if [ "$source_flag" -eq 1 ]; then
		echo "sourcing $expected_file_path"
	    . "$expected_file_path"
	fi
 
}