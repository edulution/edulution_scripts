#!/bin/bash

# Function to check internet connection
check_internet_connection() {
    # Use Zenity to display a progress dialog
    zenity --progress --pulsate --title="Checking internet connection" --text="Checking your internet connection. Please wait..." --auto-close &

    # Save the PID of the Zenity process
    ZENITY_PID=$!

    # Check if there is an internet connection
    wget -q --tries=10 --timeout=20 --spider http://google.com

    local exit_code=$?
    kill $ZENITY_PID
    return $exit_code
}
