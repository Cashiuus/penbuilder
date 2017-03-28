#
# =============[ Default Settings ]============== #
SCRIPT_DIR=$(readlink -f $0)
APP_BASE=$(dirname ${SCRIPT_DIR})
BUILDS_BASE="${APP_BASE}/builds"
MASTER_CONFIG="${HOME}/git/master-live-build-config"
DEPENDENCY_PROJECT="${APP_BASE}/../penprep"

# Paths for live build stages to place files from functions
CHROOT_DIR="${BUILD_DIR}/kali-config/common/hooks"
KALI_INCLUDES_DIR="${BUILD_DIR}/kali-config/common/includes"
DEB_INCLUDES_DIR="${BUILD_DIR}/config/includes.chroot"
# ===============================[ Check Permissions ]============================== #
function check_root {
    ACTUAL_USER=$(env | grep SUDO_USER | cut -d= -f 2)
    ## Exit if the script was not launched by root or through sudo
    if [[ ${EUID} -ne 0 ]]; then
        echo "The script needs to run as sudo/root" && exit 1
    fi
}
# ===========[ Functions for all Live Build Recipes ]============= #
function check_connectivity() {
    netcheck=$(ip addr)
    # TODO:
}


function update_kali() {
    #check_connectivity
    apt-get update -qq
    # *NOTE: On 9/10/2015, Kali changed from cdebootstrap to debootstrap due to live-build 5.x
    apt-get install -y -qq git live-build debootstrap devscripts kali-archive-keyring apt-cacher-ng
}


function create_conf() {
    # During first-run, create the 'settings.conf' file that stores useful settings
    mkdir -p "${BUILDS_BASE}"
    cat << EOF > "${APP_BASE}/config/settings.conf"
# PERSONAL BUILD SETTINGS
VPN_SERVER=''
VPN_PORT='1194'
VPN_CLIENT_CONF="${APP_BASE}/config/vpn-client-confs/client1.conf"
ISO_FINAL_DIR="/var/www/html/iso"
EOF
    echo -e "\n\n${YELLOW}[WARN] First-Run: Settings file created at ${APP_BASE}/config/settings.conf${RESET}"
    echo -e "${YELLOW}[WARN] Open file for editing and press ANY KEY when ready to continue...${RESET}\n\n"
    read
    init_project
}

function print_banner() {
    lines=$(tput lines)
    columns=$(tput cols)
    #echo -e "Bar: ${BAR}"
    echo -e "\n${BLUE}===================[  ${RESET}${BOLD}Kali 2016 Live Build Engine  ${RESET}${BLUE}]===================${RESET}"
    echo -e ""
    echo -e "  ${BOLD}Build Name:${RESET}\t\t${BUILD_NAME}"
    echo -e "  ${BOLD}Build Variant:${RESET}\t${BUILD_VARIANT}"
    echo -e "  ${BOLD}Build Path:${RESET}\t\t${BUILD_DIR}"
    echo -e "${BLUE}===========================<${RESET} version: ${__version__} ${BLUE}>===========================\n${RESET}"
}


function init_project() {
    # If we have just pulled down this project, intialize the project directory and configurations
    if [[ ! -f "${APP_BASE}/config/settings.conf" ]]; then
        #read -p "[+] Declare your BUILDS folder for this and future build efforts: " -i "${HOME}/builds" -e BUILDS_BASE
        create_conf
    else
        source "${APP_BASE}/config/settings.conf"
    fi

    BUILD_DIR="${BUILDS_BASE}/${BUILD_NAME}"
    IMAGES_DIR="${BUILD_DIR}/images"

    # Establish the main config structure we begin with
    [[ ! -d "{BUILD_DIR}" ]] && mkdir -p "${BUILD_DIR}"
    if [[ ! -d "${MASTER_CONFIG}" ]]; then
        mkdir -p ~/git && cd ~/git
        git clone git://git.kali.org/live-build-config.git master-live-build-config
    fi

        # Copy the master config git to this project folder if it's not already there
    if [[ ! -d "{BUILD_DIR}/kali-config" ]]; then
        # Cannot use "*" within quotes, because inside quotes, special chars do not expand
        cp -r ${MASTER_CONFIG}/. ${BUILD_DIR}
        # Another way to do this is to use "shopt in bash or setopt in zsh"
        # Enable ("set") dotfiles inclusive for cp,mv commands
        #shopt -s dotglob
        # Disable ("unset") when done
        #shopt -u dotglob
    fi

    # Also git clone sister project "penprep" in order to use helper installer scripts
    if [[ ! -d "${DEPENDENCY_PROJECT}" ]]; then
        mkdir -p "${DEPENDENCY_PROJECT}"
        git clone https://github.com/cashiuus/penprep "${DEPENDENCY_PROJECT}"
    fi

    print_banner
    update_kali
    # -------- Setup a build cache -- to make future builds much faster
    # Launch apt-cache if not already running
    netstat -antpl | grep -q "3142" && /etc/init.d/apt-cacher-ng start && export http_proxy=http://localhost:3142/
    cd "${BUILD_DIR}"
    START_TIME=$(date +%s)
}


function start_build() {
    echo -e "\n\n${GREEN}[*] =====${RESET}[ Begin Live Build ]${GREEN}===== [*] ${RESET}"
    cd "${BUILD_DIR}"
    STR_VARIANT=$(echo $BUILD_VARIANT | cut -d "-" -f2)
    #./build.sh
    #       --distribution {sana,} (*or instead, use*) --kali-dev or --kali-rolling
    #       --variant {gnome,kde,xfce,mate,e17,lxde,i3wm,light}
    #               *Each valid variant has a folder within "./live-build-config/kali-config/"
    #       --arch
    #       --get-image-path
    #       --subdir
    #./build.sh --distribution ${BUILD_DIST} --variant ${STR_VARIANT} --subdir "${BUILD_NAME}" --verbose
    ./build.sh --distribution ${BUILD_DIST} --variant ${STR_VARIANT} --verbose
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] with ${BUILD_NAME} build process${RESET}"
        exit 1
    fi
}

# ======================== [ Functions: Post-Build ] ================================= #
function build_completion() {
    FINISH_TIME=$(date +%s)
    # Remove default from string, output filename only includes variant if it's not the default
    if [[ $STR_VARIANT == 'default' ]]; then
        ISO_NAME="kali-linux-${BUILD_DIST}-${BUILD_ARCH}.iso"
    fi
    if [[ ${BUILD_DIST} == 'kali-rolling' ]]; then
        #echo -e "${YELLOW}[DEBUG] ${RESET}Distro kali-rolling in use. Renamed expected ISO."
        if [[ $STR_VARIANT == 'default' ]]; then
            ISO_NAME="kali-linux-rolling-${BUILD_ARCH}.iso"
        else
            ISO_NAME="kali-linux-${STR_VARIANT}-rolling-${BUILD_ARCH}.iso"
        fi
    else
        ISO_NAME="kali-linux-${STR_VARIANT}-${BUILD_DIST}-${BUILD_ARCH}.iso"
    fi
    ISO_FILE="${IMAGES_DIR}/${ISO_NAME}"

    echo -e "${GREEN}[*]${RESET} Copying finished ISO to www Directory. Please wait..."

    if [[ "${ISO_FINAL_DIR}" != "" ]]; then
        [[ ! -d "${ISO_FINAL_DIR}" ]] && mkdir -p "${ISO_FINAL_DIR}"
        md5sum "${ISO_FILE}" > "${ISO_FINAL_DIR}/${BUILD_NAME}.md5"
        # -u = means only copy if source file is newer than destination file
        cp -u "${ISO_FILE}" "${ISO_FINAL_DIR}/${BUILD_NAME}.iso"
    else
        echo -e "${YELLOW}[WARN]${RESET} 'ISO_FINAL_DIR' variable empty. Skipping ISO copy..."
        echo -e "${GREEN}[*]${RESET} Location of ISO: ${ISO_FILE}"
    fi

    print_banner
    echo -e "${GREEN}[*] ===[ Build Completed Successfully${YELLOW} ( Time: $(( $(( FINISH_TIME - START_TIME )) / 60 )) minutes )${GREEN} ]=== [*]\n${RESET}"
}


# ===========================[ Functions: VM-Tools ]============================== #
function include_vm_tools() {
    # Create a vm-tools installer script and run it during boot
    file="install-vm-tools.sh"
    cat <<EOF > "/tmp/${file}"
#!/bin/sh

if (dmidecode | grep -iq virtual); then
    apt-get -qq update
    apt-get -y install open-vm-tools-desktop fuse
fi
EOF

    # Add file to Desktop so user can run script right after booting
    cp "/tmp/${file}" "${DEB_INCLUDES_DIR}/root/Desktop/${file}"

    mv "/tmp/${file}" "${BUILD_DIR}/config/includes.chroot/${file}"
    chmod 755 "${BUILD_DIR}/config/includes.chroot/${file}"
    # TODO: Add a line to end of preseed to execute this file


}


# ============================== [ Functions: SSH ] =============================== #
function setup_ssh() {
    #
    # SSH  -------- Create SSH key w/o password since it's for an agent
    echo -e "${GREEN}[*]${RESET} Configuring SSH Capability"

    cd "${BUILD_DIR}"
    # If our build server doesn't already have an SSH private key, generate one
    [[ ! -s "${HOME}/.ssh/id_rsa" ]]  &&   ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -P ""

    FILE_DIR="${DEB_INCLUDES_DIR}/root/.ssh"
    [[ ! -d "${FILE_DIR}" ]] && mkdir -p "${FILE_DIR}"
    # Put our public key into the authorized file for the agent so we can SSH into it
    [[ -s "${FILE_DIR}/authorized_keys" ]] && rm "${FILE_DIR}/authorized_keys"
    cp "${HOME}/.ssh/id_rsa.pub" "${FILE_DIR}/authorized_keys"

    # TODO: Set it up to run the "setup-ssh-server.sh" file after install
    FILE_DIR="${DEB_INCLUDES_DIR}/root/scripts"
    [[ ! -d "${FILE_DIR}" ]] && mkdir -p "${FILE_DIR}"
    echo -e "${GREEN}[*] ===> ${RESET}Placing 'setup-ssh-server.sh' into build image"
    #cp "${DEPENDENCY_PROJECT}/kali/setup/setup-ssh-server.sh" "${FILE_DIR}/"

    # or we run it right now during chroot phase
    cp "${DEPENDENCY_PROJECT}/kali/setup/setup-ssh-server.sh" "${CHROOT_DIR}/0801-setup-ssh-server.hook.chroot"
    chmod 755 "${CHROOT_DIR}/0801-setup-ssh-server.hook.chroot"

}


# =============================[ Functions: VPN ]============================== #
function list_vpn_confs {
    # List all files in the vpn client configs directory in case we aren't sure of name
    echo -e "List of VPN client configs that are present:"
    if [[ ! ${VPN_CLIENT_CONF} ]]; then
        for entry in $(dirname ${VPN_CLIENT_CONF}); do
            echo "${entry}"
        done
    fi
}

function setup_vpn {
    echo -e "${GREEN}[*] ${RESET}Configuring VPN Capability"
    cd "${BUILD_DIR}"
    file="config/includes.chroot/etc/openvpn"
    [[ ! -d "${file}" ]] && mkdir -p "${file}"
    # If an all-in-one client file exists, just copy the conf
    echo -e "${GREEN}[*]${RESET} Using VPN Client File: ${VPN_CLIENT_CONF}"

    if [[ -f "${VPN_CLIENT_CONF}" ]]; then
        echo -e "${GREEN}[*] ${RESET}VPN Client file found in build, cleaning chroot first..."
        rm -rf "${file}"/*
        cp "${VPN_CLIENT_CONF}" "${file}/"
    elif [[ -f "${VPN_PREP_DIR}/${CLIENT_NAME}.conf" ]]; then
        echo -e "${GREEN}[*] ${RESET}VPN Client file found in VPN Setup directory. Copying into build."
        rm -rf "${file}"/*
        cp "${VPN_PREP_DIR}/${CLIENT_NAME}.conf" "${VPN_CLIENT_CONF}"
        cp "${VPN_CLIENT_CONF}" "${file}/"
    else
        echo -e "${YELLOW} [ERROR] << Missing VPN client package >> ${RESET}Please create one or remove VPN from this build script.\n\n"
        exit 1
    fi
}


# ==================[ Functions: Misc Utilities ]==================== #
function copy_package_list() {
    # Copy a specified package list to be included in the build
    cp -u "${APP_BASE}/config/package-lists/${1}" "${BUILD_DIR}/kali-config/common/package-lists/${1}"
}


function xfce4_default_layout() {
    # Copy default xfce4 desktop layout folder shell over

    cp -R "${APP_BASE}"/config/includes/. "${BUILD_DIR}/config/includes.chroot/"
}



# ==================[ Functions: Git ]==================== #
function check_git_repo() {
    # Check if repo exists
    [[ -d $1 ]]

}


function clone_git_repo() {
    #TODO: Function to clone git repo
    CLONE_PATH='/opt/git'

    git clone -q ${1} || echo -e '[ERROR] Problem cloning ${1}'
}

# ==================[ Functions:  ]==================== #
