#!/bin/bash

# exit if anything returns a non-zero code
# set -e

# shellcheck source=/dev/null
# source helper function to create or replace config files
source ~/.scripts/config/check_file_and_replace.sh

# shellcheck source=/dev/null
source ~/.scripts/config/check_or_create_dirs.sh

# shellcheck source=/dev/null
source ~/.scripts/config/test_report_submission.sh

# List of directories to be checked for
DIRECTORIES=( ~/.reports ~/backups )

# Make backups and reports directories if they don't exist
check_or_create_dirs "${DIRECTORIES[@]}"

# Create or replace the bash colors file
check_file_and_replace ~/.bash_colors ~/.scripts/config/.bash_colors 1

# Create or replace the upgrade script
check_file_and_replace ~/upgrade ~/.scripts/upgrade 0

# Create or replace the bash aliases
check_file_and_replace ~/.bash_aliases ~/.scripts/config/.bash_aliases 0

# Run flyway migrations
~/.scripts/config/flyway_bl.sh migrate

# Run backup script
~/.scripts/backupdb/backup.sh

# Test report submission
test_report_submission