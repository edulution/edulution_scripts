#!/bin/bash
# import Playlists from Kolibri Studio
echo "Importing Playlists from the internet"

# For each channel, always importchannel before importcontent

#Pre Alpha A
python -m kolibri manage importchannel -- network 3d6c9d72a2e047d4b7a0ed20699e1b1f
python -m kolibri manage importcontent -- network 3d6c9d72a2e047d4b7a0ed20699e1b1f

#Pre Alpha B
python -m kolibri manage importchannel -- network 6380a6a98a4c4b268b3147ad1c7ada13
python -m kolibri manage importcontent -- network 6380a6a98a4c4b268b3147ad1c7ada13

#Pre Alpha C
python -m kolibri manage importchannel -- network 20113bf1ba074e08bcc7faaca03ade8a
python -m kolibri manage importcontent -- network 20113bf1ba074e08bcc7faaca03ade8a

#Pre Alpha D
python -m kolibri manage importchannel -- network 1700bf9e71094857abf36c04a1963004
python -m kolibri manage importcontent -- network 1700bf9e71094857abf36c04a1963004

#Alpha A
python -m kolibri manage importchannel -- network 8784b9f78d584273aff579b246529215
python -m kolibri manage importcontent -- network 8784b9f78d584273aff579b246529215

#Alpha B
python -m kolibri manage importchannel -- network cc80537886cb498eb564242f44c87723
python -m kolibri manage importcontent -- network cc80537886cb498eb564242f44c87723

#Alpha C
python -m kolibri manage importchannel -- network 7035e7921ddf489fad4544c814a199fb
python -m kolibri manage importcontent -- network 7035e7921ddf489fad4544c814a199fb

#Alpha D
python -m kolibri manage importchannel -- network 1d8f1428da334779b95685c4581186c4
python -m kolibri manage importcontent -- network 1d8f1428da334779b95685c4581186c4

# Bravo A
python -m kolibri manage importchannel -- network 57995474194c4068bfed1ee16108093f
python -m kolibri manage importcontent -- network 57995474194c4068bfed1ee16108093f

# Bravo B
python -m kolibri manage importchannel -- network b7214b921fd94a1cb758821919bcd3e0
python -m kolibri manage importcontent -- network b7214b921fd94a1cb758821919bcd3e0

# Bravo C
python -m kolibri manage importchannel -- network 5aee4435135b4039a3a824d96f72bfcb
python -m kolibri manage importcontent -- network 5aee4435135b4039a3a824d96f72bfcb

# Bravo D
python -m kolibri manage importchannel -- network 98ab8048107545da92e3394409955526
python -m kolibri manage importcontent -- network 98ab8048107545da92e3394409955526