#!/bin/bash
echo "Importing numeracy playlists"

#Pre Alpha A
python -m kolibri manage importchannel -- disk 3d6c9d72a2e047d4b7a0ed20699e1b1f /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 3d6c9d72a2e047d4b7a0ed20699e1b1f /opt/KOLIBRI_DATA/

#Pre Alpha B
python -m kolibri manage importchannel -- disk 6380a6a98a4c4b268b3147ad1c7ada13 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 6380a6a98a4c4b268b3147ad1c7ada13 /opt/KOLIBRI_DATA/

#Pre Alpha C
python -m kolibri manage importchannel -- disk 20113bf1ba074e08bcc7faaca03ade8a /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 20113bf1ba074e08bcc7faaca03ade8a /opt/KOLIBRI_DATA/

#Pre Alpha D
python -m kolibri manage importchannel -- disk 1700bf9e71094857abf36c04a1963004 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 1700bf9e71094857abf36c04a1963004 /opt/KOLIBRI_DATA/

#Alpha A
python -m kolibri manage importchannel -- disk 8784b9f78d584273aff579b246529215 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 8784b9f78d584273aff579b246529215 /opt/KOLIBRI_DATA/

#Alpha B
python -m kolibri manage importchannel -- disk cc80537886cb498eb564242f44c87723 /opt/KOLIBRI_DATA/
python -m kolibri manage importchannel -- disk cc80537886cb498eb564242f44c87723 /opt/KOLIBRI_DATA/

#Alpha C
python -m kolibri manage importchannel -- disk 7035e7921ddf489fad4544c814a199fb /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 7035e7921ddf489fad4544c814a199fb /opt/KOLIBRI_DATA/

#Alpha D
python -m kolibri manage importchannel -- disk 1d8f1428da334779b95685c4581186c4 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 1d8f1428da334779b95685c4581186c4 /opt/KOLIBRI_DATA/

# Bravo A
python -m kolibri manage importchannel -- disk 57995474194c4068bfed1ee16108093f /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 57995474194c4068bfed1ee16108093f /opt/KOLIBRI_DATA/

# Bravo B
python -m kolibri manage importchannel -- disk b7214b921fd94a1cb758821919bcd3e0 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk b7214b921fd94a1cb758821919bcd3e0 /opt/KOLIBRI_DATA/

# Bravo C
python -m kolibri manage importchannel -- disk 5aee4435135b4039a3a824d96f72bfcb /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 5aee4435135b4039a3a824d96f72bfcb /opt/KOLIBRI_DATA/

# Bravo D
python -m kolibri manage importchannel -- disk 98ab8048107545da92e3394409955526 /opt/KOLIBRI_DATA/
python -m kolibri manage importcontent -- disk 98ab8048107545da92e3394409955526 /opt/KOLIBRI_DATA/