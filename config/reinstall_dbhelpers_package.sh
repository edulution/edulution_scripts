#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "  reinstall_dbhelpers_package - Reinstall dbhelpers R package"
  echo
  echo "DESCRIPTION"
  echo "	This script installs the 'dbhelpers' R package from the 'Aypak' GitHub repository using 'devtools' package."
  exit 1
fi

sudo su - -c "R -e \"devtools::install_github('Aypak/dbhelpers', upgrade = 'never')\""