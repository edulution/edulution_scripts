#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "   insert_zm_gr7_revision_into_channel_module - Insert Zambia grade 7 revision"
  echo
  echo "DESCRIPTION"
  echo "	This script is used to insert a grade 7 revision Zambia channel into the channel module table in the Kolibri database, "
  echo "	if it does not already exist. It does this by using the 'psql' command to connect to the Kolibri database using the provided"
  echo "	host, user, password, and database name, and then using the 'INSERT INTO' and 'ON CONFLICT' SQL statements to insert or update"
  echo "	the specified channel ID and module value."
  exit 1
fi
# insert grade 7 revision zambia into channel module if it does not exist
PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD psql -h "$KOLIBRI_DATABASE_HOST" -U "$KOLIBRI_DATABASE_USER" -d "$KOLIBRI_DATABASE_NAME" -c "INSERT INTO channel_module(channel_id, module) VALUES ('8d368058-6565-44e2-b7fe-62eb2a632698', 'numeracy') on conflict (channel_id) DO UPDATE SET module = EXCLUDED.module;"