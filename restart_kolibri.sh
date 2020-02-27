#!/bin/bash

# stop the kolibri server
python -m kolibri stop

# stop all processes running on port 8080
fuser -k 8080/tcp

# start the kolibri server
python -m kolibri start