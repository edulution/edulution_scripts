test -f ~/Desktop/kolibri_commands.txt
if [ "$?" = "0" ]; then
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