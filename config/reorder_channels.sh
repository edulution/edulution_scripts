#!/bin/bash

# export the python path
PYTHONPATH=/usr/lib/python2.7

# Order the channels with Pre Alpha channels appearing first and Bravo last


python -m kolibri manage setchannelposition 3d6c9d72-a2e0-47d4-b7a0-ed20699e1b1f 1 #Pre Alpha A

python -m kolibri manage setchannelposition 6380a6a9-8a4c-4b26-8b31-47ad1c7ada13 2 #Pre Alpha B

python -m kolibri manage setchannelposition 20113bf1-ba07-4e08-bcc7-faaca03ade8a 3 #Pre Alpha C

python -m kolibri manage setchannelposition 1700bf9e-7109-4857-abf3-6c04a1963004 4 #Pre Alpha D

python -m kolibri manage setchannelposition 8784b9f7-8d58-4273-aff5-79b246529215 5 #Alpha A

python -m kolibri manage setchannelposition cc805378-86cb-498e-b564-242f44c87723 6 #Alpha B

python -m kolibri manage setchannelposition 7035e792-1ddf-489f-ad45-44c814a199fb 7 #Alpha C

python -m kolibri manage setchannelposition 1d8f1428-da33-4779-b956-85c4581186c4 8 #Alpha D

python -m kolibri manage setchannelposition 57995474-194c-4068-bfed-1ee16108093f 9 #Bravo A

python -m kolibri manage setchannelposition b7214b92-1fd9-4a1c-b758-821919bcd3e0 10 #Bravo B

python -m kolibri manage setchannelposition 5aee4435-135b-4039-a3a8-24d96f72bfcb 11 #Bravo C

python -m kolibri manage setchannelposition 98ab8048-1075-45da-92e3-394409955526 12 #Bravo D