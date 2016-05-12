#!/bin/bash
## ========================================================================== ##
#
# Created:          2015-Oct-15     (Updated: 2016-Apr-27)
# Author:           Cashiuus - cashiuus(at)gmail
#
# Build Focus:      Standard Kali ISO, but fully updated and minor tweaks.
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
# ============[ DECLARE DEFAULTS ]============== #
BUILD_NAME="1-kali-standard"
BUILD_VARIANT="variant-default"
BUILD_DIST="kali-rolling"
BUILD_ARCH="amd64"
## ========================================================================== ##

init_project

# ==================[ Recipe-Specific Customization ]==================== #




# ======================[ Stage 1: Packages ]=========================
# Additional Last-Minute Tools/Pkgs
cd "${BUILD_DIR}"
file="${BUILD_DIR}/kali-config/${BUILD_VARIANT}/package-lists/kali.list.chroot"
#grep -q "amap" "${file}" || echo -e "amap" >> "${file}"


# ======================[ Stage 2: Hooks ]=========================
# Hook 01: Auto-Start Services on boot
#file="config/hooks"



# ======================[ Stage 3: Includes ]=========================

# Binary 01: Override default manu, disabling the BELL sound (^G)
cd "${BUILD_DIR}"
filedir="config/includes.binary/isolinux"
[[ ! -d "${filedir}" ]] && mkdir -p "${filedir}"
cat << EOF > "${filedir}/menu.cfg"
menu hshift 0
menu width 82

menu title Kali Linux 2016.x Boot menu
include live.cfg
include install.cfg
include stdmenu.cfg
menu end

menu clear
EOF

# Binary 02: Override installer
file="config/includes.binary/isolinux"
[[ ! -d "${file}" ]] && mkdir -p "${file}"
cat << EOF > "${file}/install.cfg"
label install
    menu label ^Unattended Install Kali Linux 2.x
    menu default
    linux /install/vmlinuz
    initrd /install/initrd.gz
    append vga=788 auto=true priority=critical -- locale=en_US keymap=us hostname=kali-drop domain=home file=/cdrom/install/preseed.cfg
EOF

# Binary 03: Override isolinux
cd "${BUILD_DIR}"
filedir="config/includes.binary/isolinux"
[[ ! -d "${filedir}" ]] && mkdir -p "${filedir}"
cat << EOF > "${filedir}/isolinux.cfg"
include menu.cfg
ui vesamenu.c32
default install
prompt 0
timeout 5
EOF

# Binary 04: Preseed File
# Setup the unattended install preseed file
file="${BUILD_DIR}/kali-config/common/includes.installer"
[[ ! -d "${file}" ]] && mkdir -p "${file}"
[[ ! -d config/includes.installer ]] && mkdir -p config/includes.installer

file="${BUILD_DIR}/kali-config/common/includes.installer/preseed.cfg"
file2="${BUILD_DIR}/config/includes.installer/preseed.cfg"
cat << EOF > "${file}"
# Example Preseed: https://www.debian.org/releases/stable/example-preseed.txt
#
#
# Locale by itself sets language, country, and locale
d-i debian-installer/locale string en_US

# Or you can set them individually if needed
#d-i debian-installer/language string en
#d-i debian-installer/country string NL
#d-i debian-installer/locale string en_GB.UTF-8
# Optionally specify additional locales to be generated.
#d-i localechooser/supported-locales multiselect en_US.UTF-8, nl_NL.UTF-8

### Keyboard Selection
d-i console-keymaps-at/keymap select us
d-i keyboard-configuration/xkb-keymap select us

### Hardware Considerations
#d-i hw-detect/load_firmware boolean false

### Network Configuration
# netcfg will choose an interface that has link if possible. This makes it
# skip displaying a list if there is more than one interface.
d-i netcfg/choose_interface select auto
# To pick a particular interface instead:
#d-i netcfg/choose_interface select eth0
d-i netcfg/dhcp_timeout string 60

# If you prefer to configure the network manually, uncomment this line and
# the static network configuration below.
#d-i netcfg/disable_autoconfig boolean true

# If you want the preconfiguration file to work on systems both with and
# without a dhcp server, uncomment these lines and the static network
# configuration below.
#d-i netcfg/dhcp_failed note
#d-i netcfg/dhcp_options select Configure network manually

### Static network configuration.
# IPv4 example
#d-i netcfg/get_ipaddress string 192.168.1.42
#d-i netcfg/get_netmask string 255.255.255.0
#d-i netcfg/get_gateway string 192.168.1.1
#d-i netcfg/get_nameservers string 192.168.1.1
#d-i netcfg/confirm_static boolean true
#
# IPv6 example
#d-i netcfg/get_ipaddress string fc00::2
#d-i netcfg/get_netmask string ffff:ffff:ffff:ffff::
#d-i netcfg/get_gateway string fc00::1
#d-i netcfg/get_nameservers string fc00::1
#d-i netcfg/confirm_static boolean true

# Any hostname and domain names assigned from dhcp take precedence over
# values set here. However, setting the values still prevents the questions
# from being shown, even if values come from dhcp.
d-i netcfg/get_hostname string kali-2016
d-i netcfg/get_domain string local.lan

# If you want to force a hostname, regardless of what either the DHCP
# server returns or what the reverse DNS entry for the IP is, uncomment
# and adjust the following line.
d-i netcfg/hostname string kali-2016

# Disable that annoying WEP key dialog.
d-i netcfg/wireless_wep string

### Network console
# Use the following settings if you wish to make use of the network-console
# component for remote installation over SSH. This only makes sense if you
# intend to perform the remainder of the installation manually.
#d-i anna/choose_modules string network-console
#d-i network-console/authorized_keys_url string http://10.0.0.1/openssh-key
#d-i network-console/password password sshPassword123
#d-i network-console/password-again password sshPassword123

### Mirror Settings
#
d-i mirror/country string United States
d-i mirror/http/hostname string http.kali.org
d-i mirror/http/directory string /kali
d-i mirror/http/proxy string
d-i mirror/codename string kali-rolling
d-i mirror/suite string kali-rolling
d-i apt-setup/use_mirror boolean true

### User Accounts
#
# Uncomment if you want to disable root user account
#d-i passwd/root-login boolean false
# Do not create a normal user account
d-i passwd/make-user boolean false
d-i passwd/root-password password toor
d-i passwd/root-password-again password toor
# or encrypted using an MD5 hash (mkpasswd -m sha-512 -or- mkpasswd -m md5)
# If your hashed password contains dollar signs, be sure to escape them!!!
#d-i passwd/root-password-crypted password \$1\$/i0jcKec\$AdXAbEcIaj4g5wezvXaHL1

# To create a normal user account.
#d-i passwd/user-fullname string User1
#d-i passwd/username string debian
# Normal user's password, either in clear text
#d-i passwd/user-password password insecure
#d-i passwd/user-password-again password insecure
# or encrypted using an MD5 hash.
# If your hashed password contains dollar signs, be sure to escape them!!!
#d-i passwd/user-password-crypted password [MD5 hash]
# Create the first user with the specified UID instead of the default.
#d-i passwd/user-uid string 1010

# The user account will be added to some standard initial groups; This overrides that.
#d-i passwd/user-default-groups string audio cdrom video

### Clock and time zone setup
#
# Controls whether or not the hardware clock is set to UTC
d-i clock-setup/utc boolean true
# Any valid TZ -- See /usr/share/zoneinfo/ for valid values
# or https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
d-i time/zone string UTC

# Controls whether to use NTP to set the clock during the install
#d-i clock-setup/ntp boolean true
# NTP server to use. The default is almost always fine here.
#d-i clock-setup/ntp-server string ntp.example.com

### Base system installation
#

### Apt Setup
#
d-i apt-setup/non-free boolean true
d-i apt-setup/contrib boolean true

# Disable volatile and security (defaults are: security, updates)
d-i apt-setup/services-select multiselect

# Disable source repositories too
d-i apt-setup/enable-source-repositories boolean false

# Disable CDROM entries after install
d-i apt-setup/disable-cdrom-entries boolean true

# Uncomment this to add multiarch configuration for i386
#d-i apt-setup/multiarch string i386

### Package selection
# This can be preseeded to override the default desktop.
# Choices: gnome, kde, xfce, lxde, cinnamon, mate
#tasksel tasksel/desktop xfce

#tasksel tasksel/first multiselect standard, web-server, kde-desktop

# Install a limited subset of tools from the Kali Linux repositories
#d-i pkgsel/include string openssh-server openvpn metasploit-framework metasploit nano ntp

# Upgrade installed packages after debootstrap
# Choices: none, safe-upgrade, full-upgrade
# Since we are working from an updated ISO, no reason to upgrade them here...?
d-i pkgsel/upgrade select none

# Report back installed pkgs for popularity rankings
popularity-contest popularity-contest/participate boolean false


### Partitioning
#
# Installater will auto-select disk by default,
# but to declare specific disk use line below
#d-i partman-auto/disk string /dev/sda

# Methods:  'regular': usual partition types
#           'lvm': use LVM to partition the disk
#           'crypto': use LVM within an encrypted partition
d-i partman-auto/method string regular

# Below are settings if an old LVM config is previously present
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true

# Partition Method Recipes:
#           'atomic': All files in one partition
#           'home': Separate /home partition
#           'multi': Separate /home, /var, /tmp partitions
d-i partman-auto/choose_recipe select atomic

# Accept Partition Selections
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman-partitioning/confirm_write_new_label boolean true

### Boot Loader Installation
#
# Tell Grub to install automatically to MBR if no other OS detected
d-i grub-installer/only_debian boolean true
# Set to false means only install to MBR if another OS is not detected
d-i grub-installer/with_other_os boolean false

# This usually must be specified
#d-i grub-installer/bootdev string /dev/sda
# This works as long as we aren't installing to a USB drive
d-i grub-installer/bootdev string default

# Avoid final note indicating install is complete
d-i finish-install/reboot_in_progress note

### Post-Installation Tasks
#
# This is how to make the installer shutdown when finished, but not
# reboot into the installed system.
#d-i debian-installer/exit/halt boolean true
# This will power off the machine instead of just halting it.
#d-i debian-installer/exit/poweroff boolean true

### Preseeding other packages
#
# Depending on what software you choose to install, or if things go wrong
# during the installation process, it's possible that other questions may
# be asked. You can preseed those too, of course. To get a list of every
# possible question that could be asked during an install, do an
# installation, and then run these commands:
#   debconf-get-selections --installer > file
#   debconf-get-selections >> file

### Kismet
kismet kismet/install-setuid boolean false
kismet kismet/install-users string

### MySQL Setup
mysql-server-5.5 mysql-server/root_password_again password
mysql-server-5.5 mysql-server/root_password password
mysql-server-5.5 mysql-server/error_setting_password error
mysql-server-5.5 mysql-server-5.5/postrm_remove_databases boolean false
mysql-server-5.5 mysql-server-5.5/start_on_boot boolean true
mysql-server-5.5 mysql-server-5.5/nis_warning note
mysql-server-5.5 mysql-server-5.5/really_downgrade boolean false
mysql-server-5.5 mysql-server/password_mismatch error
mysql-server-5.5 mysql-server/no_upgrade_when_using_ndb error

#### Advanced options
### Running custom commands during the installation

# Clean up
d-i preseed/late_command \
    string in-target  sed -i 's/^deb cdrom:/# deb cdrom:/g' /etc/apt/sources.list; \
    in-target apt-get -y autoremove; \
    in-target apt-get -y clean; \
    in-target rm -rf /var/lib/apt/lists/*; \
    in-target rm -rf /var/cache/*;
    in-target gsettings set org.gnome.desktop.session idle-delay 1800;

EOF
cp "${file}" "${file2}"


# =========================[ END OF CUSTOMIZATIONS ]========================== #

# ======================[ Start Build - Go get coffee ]======================= #

# Optionally, add metadata to the image
#lb config --iso-application Kali --iso-preparer Cashiuus

start_build

# =========================[ Post-Build - Move ISO ]========================== #

build_completion

