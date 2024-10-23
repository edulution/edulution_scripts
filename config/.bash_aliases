#!/bin/bash
# source the file containing colors and text output styling

# shellcheck source=/dev/null
source ~/.bash_colors

alias shutdown='workon kolibri;kolibri stop;~/.scripts/backupdb/backup.sh;sudo shutdown -h now'
alias reboot='sudo reboot'
alias whoru='cd ~/.scripts/identify/;python identify.py'
alias alldata='~/.scripts/reporting/alldata.sh'
alias monthend='~/.scripts/reporting/monthend.sh'
alias monthend_swap='KOLIBRI_DATABASE_NAME=$KOLIBRI_SWAP_DB;BASELINE_DATABASE_NAME=$BASELINE_SWAP_DB;~/.scripts/reporting/monthend.sh'
alias restartko='workon kolibri;~/.scripts/restart_kolibri.sh;~/.scripts/config/flyway_bl.sh migrate;~/.scripts/config/flyway_bl.sh repair;~/.baseline_testing/scripts/startup_script;sudo systemctl restart nginx.service;rm ~/.kolibri/job_storage.sqlite3*'
alias backup='workon kolibri; python -m kolibri stop;sudo service nginx stop;~/.scripts/backupdb/backup.sh'
alias upgrade='~/upgrade'
alias tunnel='~/.scripts/ssh_tunnel/create_ssh_tunnel.sh'
alias swapdb='~/.scripts/swapdb/swapdb.sh'

#baseline aliases
alias baseline='~/.baseline_testing/scripts/reporting/baseline.sh'
alias restartbl='~/.baseline_testing/scripts/startup_script'
alias getkousers='~/.baseline_testing/scripts/start_users_extraction.sh'
alias flyway_bl='~/.scripts/config/flyway_bl.sh'

# assign live learners to the right groups
alias assign_learners='workon kolibri;~/.kolibri_helper_scripts/assign_learners.sh;~/.baseline_testing/scripts/startup_script'

# Regenerate lessons and quizzes, then assign learners and restart both kolibri and baseline
alias make_quiz='workon kolibri;kolibri stop;python ~/.kolibri_helper_scripts/setup.py;~/.kolibri_helper_scripts/assign_learners.sh;~/.scripts/restart_kolibri.sh;~/.baseline_testing/scripts/startup_script'

#Import all Kolibri channels from the internet
alias update_channels='workon kolibri;~/.kolibri_helper_scripts/channel_setup/import_channels_network.sh'

# Export Kolibri channels currently on the device to a specified directory
alias export_channels='workon kolibri;~/.kolibri_helper_scripts/channel_setup/export_channels.sh'