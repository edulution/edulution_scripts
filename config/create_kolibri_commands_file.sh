#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "   create_kolibri_commands_file - Create Kolibri commands file"
  echo
  echo "DESCRIPTION"
  echo "	This script is used to check if a file named 'kolibri_commands.txt' exists on the desktop. If the file exists, it informs the user"
  echo "	that it already exists and skips the script, otherwise it creates the file and writes some content to it."
  echo "	The file created contains information on how to execute kolibri commands in case they stop working and also a tip on how to copy and"
  echo "	paste commands in the terminal."
  exit 1
fi

if test -f ~/Desktop/kolibri_commands.txt; then
	echo "Kolibri commands file already exists. Skipping...."
else
	echo "Creating Kolibri commands file..."
	touch ~/Desktop/kolibri_commands.txt 
	echo "Open the terminal and excecute the command below in case all commands stop working:" >> ~/Desktop/kolibri_commands.txt
	echo "cd ~/.scripts;./setup.sh" >> ~/Desktop/kolibri_commands.txt
	echo "After excecuting the command, close the terminal and open it again" >> ~/Desktop/kolibri_commands.txt
	echo "(Tip: You can copy highlighted text by pressing ctrl + C, and paste into the terminal by pressing ctrl+ shift + V)" >> ~/Desktop/kolibri_commands.txt
	echo "Done"
fi