#!/bin/bash

# Default values
URL="https://raw.githubusercontent.com/vtrcka/KaliSetupForMacVirtual/main/config/terminator.conf"
USERS=""
ROOT_USER="false"

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# Function to display help
usage() {
    echo -e "${YELLOW}Usage: $0 [-u user1,user2,...] [-r]${RESET}"
    echo -e "  ${BLUE}-u user1,user2,...${RESET}  : Specify multiple usernames for setup, separated by commas (e.g., kali,user2)."
    echo -e "  ${BLUE}-r${RESET}                  : Download the config file for the root user."
    exit 1
}

# Function to check if Terminator is installed, install if not
check_terminator() {
    if ! command -v terminator &> /dev/null; then
        echo -e "${YELLOW}[INFO] Terminator is not installed. Installing...${RESET}"
        sudo apt update && sudo apt install -y terminator
        if [ $? -ne 0 ]; then
            echo -e "${RED}[ERROR] Failed to install Terminator.${RESET}"
            exit 1
        fi
        echo -e "${GREEN}[SUCCESS] Terminator installed successfully.${RESET}"
    else
        echo -e "${GREEN}[SUCCESS] Terminator is already installed.${RESET}"
    fi
}

# Function to set Terminator as the default terminal
set_default_terminal() {
    echo -e "${YELLOW}[INFO] Setting Terminator as the default terminal...${RESET}"
    sudo update-alternatives --set x-terminal-emulator /usr/bin/terminator
    echo -e "${GREEN}[SUCCESS] Terminator is now the default terminal.${RESET}"
}

# Function to update .desktop files to use Terminator
update_desktop_files() {
    echo -e "${YELLOW}[INFO] Updating .desktop files to use Terminator...${RESET}"
    local desktop_dirs=(
        "/home/*/.config/xfce4/panel"
        "/root/.config/xfce4/panel"
    )
    for dir in "${desktop_dirs[@]}"; do
        if [ -d "$dir" ]; then
            sudo find "$dir" -type f -name "*.desktop" -exec grep -lE "Terminal|exo-open --launch TerminalEmulator" {} \; | while read file; do
                echo -e "${YELLOW}[INFO] Updating $file to use Terminator...${RESET}"
                sudo sed -i 's|^Exec=.*|Exec=terminator|' "$file"
            done
        fi
    done
    echo -e "${GREEN}[SUCCESS] .desktop files updated to use Terminator.${RESET}"
}

# Function to check and create directory if not exists
ensure_directory_exists() {
    local dir="$1"
    local owner="$2"
    if [ ! -d "$dir" ]; then
        echo -e "${YELLOW}[INFO] Directory $dir does not exist. Creating it...${RESET}"
        sudo mkdir -p "$dir"
    fi
    sudo chown -R "$owner:$owner" "$dir"
    sudo chmod 775 "$dir"
    echo -e "${GREEN}[SUCCESS] Directory $dir is set up.${RESET}"
}

# Function to check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[ERROR] This script must be run as root. Try using sudo.${RESET}"
        exit 1
    fi
}

# Parse command-line options
while getopts "u:r" opt; do
    case ${opt} in
        u) USERS="${OPTARG}" ;;
        r) ROOT_USER="true" ;;
        *) usage ;;
    esac
done

# Check if at least one option is provided
if [ -z "$USERS" ] && [ "$ROOT_USER" = "false" ]; then
    echo -e "${RED}[ERROR] You must specify at least one user with -u or use -r for root.${RESET}"
    usage
fi

# Ensure script is run as root
check_root

# Check and install Terminator
check_terminator

# Set Terminator as the default terminal
set_default_terminal

# Update .desktop files to use Terminator
update_desktop_files

# Process root user if -r is set
if [ "$ROOT_USER" = "true" ]; then
    TARGET_PATH="/root/.config/terminator/config"
    TARGET_DIR=$(dirname "$TARGET_PATH")
    ensure_directory_exists "$TARGET_DIR" "root"
    
    echo -e "${YELLOW}[INFO] Downloading Terminator config file for root...${RESET}"
    wget -O "$TARGET_PATH" "$URL"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Download failed for root.${RESET}"
        exit 1
    fi
    
    sudo chown root:root "$TARGET_PATH"
    sudo chmod 775 "$TARGET_PATH"
    echo -e "${GREEN}[SUCCESS] Config file downloaded successfully for root and permissions set.${RESET}"
fi

# Process each user specified in -u
if [ -n "$USERS" ]; then
    IFS=',' read -ra USER_LIST <<< "$USERS"
    for USER in "${USER_LIST[@]}"; do
        TARGET_PATH="/home/$USER/.config/terminator/config"
        TARGET_DIR=$(dirname "$TARGET_PATH")
        
        ensure_directory_exists "$TARGET_DIR" "$USER"
        
        echo -e "${YELLOW}[INFO] Downloading Terminator config file for user $USER...${RESET}"
        sudo -u "$USER" wget -O "$TARGET_PATH" "$URL"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}[ERROR] Download failed for user $USER.${RESET}"
            exit 1
        fi
        
        sudo chown "$USER:$USER" "$TARGET_PATH"
        sudo chmod 775 "$TARGET_PATH"
        echo -e "${GREEN}[SUCCESS] Config file downloaded successfully for user $USER and permissions set.${RESET}"
    done
fi
