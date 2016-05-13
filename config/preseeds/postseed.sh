#!/bin/sh
# File:     postseed.sh

if (dmidecode | grep -iq virtual); then
    apt-get -qq update
    apt-get -y install open-vm-tools-desktop fuse
fi
