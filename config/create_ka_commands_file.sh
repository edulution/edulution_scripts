test -f ~/Desktop/ka_commands.txt
if [ "$?" = "0" ]; then
	echo "KA Commands file already exists. Skipping...."
else
	echo "Creating KA commands file..."
	touch ~/Desktop/ka_commands.txt 
	echo "Open the terminal and excecute the command below in case all commands stop working:" >> ~/Desktop/ka_commands.txt
	echo "cd ~/.scripts;./setup.sh" >> ~/Desktop/ka_commands.txt
	echo "After excecuting the command, close the terminal and open it again" >> ~/Desktop/ka_commands.txt
	echo "(Tip: You can copy highlighted text by pressing ctrl + C, and paste into the terminal by pressing ctrl+ shift + V)" >> ~/Desktop/ka_commands.txt
	echo "Done"
fi