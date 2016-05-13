#!/bin/bash
## ========================================================================== ##
# File:             recipe-1-kali-updated-iso.sh
#
# Author:           Cashiuus
# Created:          15-OCT-2015             (Updated: 13-MAY-2016)
#
# Build Focus:      Standard Kali ISO, but fully updated.
#
#
# Desktop:          gnome
# Metapackages:
# Avg Build Time:   63 Minutes
# ISO Size:         3.0 GB
# Special Notes:    Default login is root/toor
#
## ========================================================================== ##
__version__="0.1"
__author__='Cashiuus'
SCRIPT_DIR=$(dirname $0)
## ===============[ Text Colors ]================ ##
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
RED="\033[01;31m"      # Issues/Errors
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal
## ========================================================================== ##
if [[ -s "${SCRIPT_DIR}/common.sh" ]]; then
    source "${SCRIPT_DIR}/common.sh"
else
    echo -e "${RED} [-] ERROR: ${RESET} common.sh functions file is missing."
    exit 1
fi
# ============[ DECLARE RECIPE DEFAULTS ]============== #
BUILD_NAME="1-kali-standard"
BUILD_VARIANT="variant-default"
BUILD_DIST="kali-rolling"
BUILD_ARCH="amd64"
## ========================================================================== ##
# =================================[ BEGIN ]================================== #
init_project

# ==================[ Recipe-Specific Customization ]==================== #



## ========================================================================== ##
# ===========================[ Stage 1: Packages ]============================ #
# Additional Last-Minute Tools/Pkgs
cd "${BUILD_DIR}"
file="${BUILD_DIR}/kali-config/${BUILD_VARIANT}/package-lists/kali.list.chroot"
#grep -q "amap" "${file}" || echo -e "amap" >> "${file}"

## ========================================================================== ##
# ============================[ Stage 2: Hooks ]============================== #


## ========================================================================== ##
# ===========================[ Stage 3: Includes ]============================ #


## ========================================================================== ##
# =========================[ END OF CUSTOMIZATIONS ]========================== #
# ======================[ Start Build - Go get coffee ]======================= #

start_build
## ========================================================================== ##
# =========================[ Post-Build - Move ISO ]========================== #

build_completion
