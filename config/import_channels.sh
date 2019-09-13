#!/bin/bash
echo "Importing numeracy playlists"

# the channel data for all the numeracy channel is stored in /opt/KOLIBRI_DATA

python -m kolibri manage importchannel -- disk 1700bf9e71094857abf36c04a1963004 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 1700bf9e71094857abf36c04a1963004 /opt/KOLIBRI_DATA/

python -m kolibri manage importchannel -- disk 6380a6a98a4c4b268b3147ad1c7ada13 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 6380a6a98a4c4b268b3147ad1c7ada13 /opt/KOLIBRI_DATA/

python -m kolibri manage importchannel -- disk 1d8f1428da334779b95685c4581186c4 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 1d8f1428da334779b95685c4581186c4 /opt/KOLIBRI_DATA/

python -m kolibri manage importchannel -- disk 7035e7921ddf489fad4544c814a199fb /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 7035e7921ddf489fad4544c814a199fb /opt/KOLIBRI_DATA/

python -m kolibri manage importchannel -- disk 20113bf1ba074e08bcc7faaca03ade8a /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 20113bf1ba074e08bcc7faaca03ade8a /opt/KOLIBRI_DATA/

python -m kolibri manage importchannel -- disk 8784b9f78d584273aff579b246529215 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 8784b9f78d584273aff579b246529215 /opt/KOLIBRI_DATA/

python -m kolibri manage importchannel -- disk 3d6c9d72a2e047d4b7a0ed20699e1b1f /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 3d6c9d72a2e047d4b7a0ed20699e1b1f /opt/KOLIBRI_DATA/

python -m kolibri manage importchannel -- disk cc80537886cb498eb564242f44c87723 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk cc80537886cb498eb564242f44c87723 /opt/KOLIBRI_DATA/