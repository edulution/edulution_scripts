#!/bin/bash
# insert grade 7 mock 3 into test_marks if it does not exist
PGPASSWORD=$BASELINE_DATABASE_PASSWORD psql -h "$BASELINE_DATABASE_HOST" -U "$BASELINE_DATABASE_USER" -d "$BASELINE_DATABASE_NAME" -c "INSERT INTO public.test_marks(test_id, test_name, course, module, testmaxscore, test_pass_score, channel_id) VALUES ('grade7_mock4', 'Grade 7 - Mock 4', 'zm_gr7_revision','numeracy', 60, 0.75, '8d368058-6565-44e2-b7fe-62eb2a632698') on conflict (test_id, course, module) DO NOTHING;"