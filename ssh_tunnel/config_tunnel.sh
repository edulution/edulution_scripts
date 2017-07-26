#!/bin/sh
ssh-keygen -t dsa

cat ~/.ssh/id_dsa.pub | ssh -l edulution 130.211.93.74 "[ -d /home/edulution/.ssh ] || mkdir -m 700 /home/edulution/.ssh; cat >> /home/edulution/.ssh/authorized_keys"
