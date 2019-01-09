#!/bin/bash

#remove old host key
echo "Removing old host key"
ssh-keygen -R "130.211.93.74"

# add new host key
echo "Replacing with new host key"
echo "|1|DNVdoDJGliybDxFRyUSpRlC5EiM=|Ft29VRG/72v7cRd/fjDPJzYlMHI= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOSxgT95GCevftJ/Sh3Aeu1yOoJkZqzecgqBiP+fbgu9XKB89to+I3+B7JpPd/0oPrKfpY4xI3uGXFMYSiee4Ig=" >> ~/.ssh/known_hosts