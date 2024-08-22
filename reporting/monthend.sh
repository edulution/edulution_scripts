#!/bin/bash

# Define spinner
SPIN='⣾⣽⣻⢿⡿⣟⣯⣷'

# Function to show spinner
show_spinner() {
    local delay=0.1
    local i=0
    while true; do
        printf "\r${SPIN:i++%${#SPIN}:1} $1"
        sleep $delay
    done
}

# Start spinner in the background
show_spinner "Report submission in progress" &
SPINNER_PID=$!

# Pull latest changes from the master branch in repo
cd ~/.scripts || exit
# git reset --hard origin/zambia > /dev/null 2>&1
git pull origin zambia > /dev/null 2>&1

# Do a silent upgrade of all scripts
./upgrade_silent.sh > /dev/null 2>&1

# Stop the spinner before printing any new messages
kill $SPINNER_PID
wait $SPINNER_PID 2>/dev/null  # Ensure the spinner has fully stopped
printf "\r"

# Function to check if a process is running
check_process_running() {
    local ps_out
    ps_out=$(ps -ef | grep "$1" | grep -v 'grep' | grep -v "$0")
    if echo "$ps_out" | grep -q "$1"; then
        echo "Running"
    else
        echo "Not Running"
    fi
}

psql_running=$(check_process_running postgresql)

if [[ "$psql_running" == 'Running' ]]; then
    if echo "$1" | grep -E '^(1[0-2]|0[0-9])[-/][0-9]{2}$' > /dev/null; then
        printf "${GREEN}Stopping Kolibri server${RESET}\n"
        python -m kolibri stop > /dev/null 2>&1
        sudo service nginx stop > /dev/null 2>&1

        # Delete any loose csv files in the reports directory before extraction
        cd ~/.reports || exit
        find . -type f \( -name "*.csv" \) -exec rm {} \;

        echo "${GREEN}Extracting data for month $1${RESET}"
        printf "Beginning report extraction.....\n"

        # Restart the spinner before starting a new background task
        show_spinner "Extracting data..." &
        SPINNER_PID=$!

        # Fetch the first argument given on the command line and use it as an argument to the Rscript
        cd ~/.scripts/reporting || exit
        Rscript monthend.R "$1" > /dev/null 2>&1

        # After Rscript executes, execute send report script
        ~/.scripts/reporting/send_report.sh > /dev/null 2>&1

        # Submit baseline tests for the selected month
        ~/.baseline_testing/scripts/reporting/baseline.sh "$1" > /dev/null 2>&1

        # Pull latest changes to baseline system
        ~/.scripts/upgrade_baseline.sh > /dev/null 2>&1

        # Stop the spinner when the tasks are complete
        kill $SPINNER_PID
        wait $SPINNER_PID 2>/dev/null  # Ensure the spinner has fully stopped
        printf "\r${GREEN}${BOLD}✔ Report submission completed${RESET}\n"
    else
        printf "${RED}Please enter a valid year and month e.g 02-17${RESET}\n"
        exit 1
    fi
else
    printf "${RED}${BOLD}Error. Report NOT extracted. Please contact tech support.${RESET}\n" >&2
    exit 1
fi
