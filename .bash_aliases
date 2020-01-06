alias shutdown='~/.scripts/backupdb/backup.sh;sudo shutdown -h now'
alias reboot='sudo reboot'
alias whoru='cd ~/.scripts/identify/;python identify.py'
alias alldata='~/.scripts/reporting/alldata.sh'
alias monthend='~/.scripts/reporting/monthend.sh'
alias monthend_swap='KOLIBRI_DATABASE_NAME=$KOLIBRI_SWAP_DB;BASELINE_DATABASE_NAME=$BASELINE_SWAP_DB;~/.scripts/reporting/monthend.sh'
alias restartko='~/.scripts/restart_kolibri.sh;chmod +x ~/.baseline_testing/scripts/startup_script;~/.baseline_testing/scripts/startup_script'
alias backup='python -m kolibri stop;sudo service nginx stop;~/.scripts/backupdb/backup.sh'
alias upgrade='~/upgrade'
alias tunnel='~/.scripts/ssh_tunnel/create_ssh_tunnel.sh'
alias swapdb='~/.scripts/swapdb/swapdb.sh'

#baseline aliases
alias baseline='chmod +x ~/.baseline_testing/scripts/reporting/baseline.sh;~/.baseline_testing/scripts/reporting/baseline.sh'
alias restartbl='chmod +x ~/.baseline_testing/scripts/startup_script;~/.baseline_testing/scripts/startup_script'
alias getkousers='chmod +x ~/.baseline_testing/scripts/start_users_extraction.sh;~/.baseline_testing/scripts/start_users_extraction.sh'

# assign live learners to the right groups
alias assign_learners='~/.kolibri_helper_scripts/assign_learners.sh'

