#!/bin/bash
# ==============================================================================
# File:     
#
# Author:   Cashiuus
# Created:  01//2016
# Revised:  
#
# Purpose:  Find an IP address without knowing anything about the env
#
# ==============================================================================
__version__="0.1"
__author__='Cashiuus'
## ===========[ Text Colors ]============== ##
GREEN="\033[01;32m"    # Success
BLUE="\033[01;34m"     # Heading
YELLOW="\033[01;33m"   # Warnings/Information
RED="\033[01;31m"      # Issues/Errors
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal


# =============================[      ]===================================




# ifconfig - This will grab "eth0"
ifconfig -a | grep -o "eth.*" |cut -d " " -f1


# ip - 
ip -4 -oneline addr


# arp - Get the ARP table, showing numeric addresses instead of resolving
arp -vn


# route


# netstat

# Display a list of all network interfaces
netstat --interfaces

# tcpdump





###

# Assign an IP address to the ethernet device eth0
ip addr add 192.168.44.91 dev eth0



# ================[ Expression Cheat Sheet ]==================================
#
#   -d      file exists and is a directory
#   -e      file exists
#   -f      file exists and is a regular file
#   -h      file exists and is a symbolic link
#   -s      file exists and size greater than zero
#   -r      file exists and has read permission
#   -w      file exists and write permission granted
#   -x      file exists and execute permission granted
#   -z      file is size zero (empty)



#   [[ $? -eq 0 ]]    Previous command was successful
#   [[ ! $? -eq 0 ]]    Previous command NOT successful
#

