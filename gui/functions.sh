#!/bin/bash

# Function to check internet connection
check_internet_connection() {
    # Use Zenity to display a progress dialog
    zenity --progress --pulsate --title="Checking internet connection" --text="Please wait..." --auto-close &

    # Save the PID of the Zenity process
    ZENITY_PID=$!

    # Check if there is an internet connection
    wget -q --tries=10 --timeout=20 --spider http://google.com

    if [[ $? -eq 0 ]]; then
        # Connection is successful
        zenity --info --title="Internet connection" --text="You are connected to the internet."
        kill $ZENITY_PID
    else
        # Connection is not successful
        zenity --error --title="Internet connection" --text="You are not connected to the internet."
        kill $ZENITY_PID
    fi
}
