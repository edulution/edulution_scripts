#!/bin/bash
# update test responses with course name grade7 revision to zm_gr7_revision
PGPASSWORD=$BASELINE_DATABASE_PASSWORD psql -h "$BASELINE_DATABASE_HOST" -U "$BASELINE_DATABASE_USER" -d "$BASELINE_DATABASE_NAME" -c "update responses set course = 'zm_gr7_revision' where course = 'grade7_revision';"