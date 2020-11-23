#!/bin/bash
# insert grade 7 revision zambia into channel module if it does not exist
PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD psql -h "$KOLIBRI_DATABASE_HOST" -U "$KOLIBRI_DATABASE_USER" -d "$KOLIBRI_DATABASE_NAME" -c "INSERT INTO channel_module(channel_id, module) VALUES ('8d368058-6565-44e2-b7fe-62eb2a632698', 'numeracy') on conflict (channel_id) DO NOTHING;"