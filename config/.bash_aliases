#!/bin/bash
# source the file containing colors and text output styling

# shellcheck source=/dev/null
source ~/.bash_colors

alias shutdown='kolibri stop;~/.scripts/backupdb/backup.sh;sudo shutdown -h now'
alias reboot='sudo reboot'
alias whoru='cd ~/.scripts/identify/;python identify.py'
alias alldata='~/.scripts/reporting/alldata.sh'
alias monthend='~/.scripts/reporting/monthend.sh'
alias monthend_swap='KOLIBRI_DATABASE_NAME=$KOLIBRI_SWAP_DB;BASELINE_DATABASE_NAME=$BASELINE_SWAP_DB;~/.scripts/reporting/monthend.sh'
alias restartko='~/.scripts/restart_kolibri.sh;~/.baseline_testing/scripts/startup_script'
alias backup='python -m kolibri stop;sudo service nginx stop;~/.scripts/backupdb/backup.sh'
alias upgrade='~/upgrade'
alias tunnel='~/.scripts/ssh_tunnel/create_ssh_tunnel.sh'
alias swapdb='~/.scripts/swapdb/swapdb.sh'

#baseline aliases
alias baseline='~/.baseline_testing/scripts/reporting/baseline.sh'
alias restartbl='~/.baseline_testing/scripts/startup_script'
alias getkousers='~/.baseline_testing/scripts/start_users_extraction.sh'
alias flyway_bl='~/.scripts/config/flyway_bl.sh'

# assign live learners to the right groups
alias assign_learners='~/.kolibri_helper_scripts/assign_learners.sh;~/.baseline_testing/scripts/startup_script'

#Import all Kolibri channels from the internet
alias update_channels='~/.kolibri_helper_scripts/channel_setup/import_channels_network.sh'

# Export Kolibri channels currently on the device to a specified directory
alias export_channels='~/.kolibri_helper_scripts/channel_setup/export_channels.sh'