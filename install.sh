#!/bin/bash
set -e

RED='\033[0;31m'
NC='\033[0m'

DESTINATION_PATH="/usr/local/bin"
SCRIPT_NAME="h2mm"

if [ "$(id -u)" -eq 0 ]; then
    echo "Run me as normal user, not as root."
    exit 1
fi

echo -e "!!! ${RED}WARNING${NC} !!!"
echo -e "This script will install Helldivers 2 Mod Manager CLI for Linux to $DESTINATION_PATH/$SCRIPT_NAME."
echo -e "Running this script will require sudo permissions. ${RED}DO NOT TRUST${NC} random scripts from the internet."
echo -e "If you want to review the script before running it, check out the mod repository for yourself:"
echo -e "https://github.com/v4n00/h2mm-cli"
echo

read -p "Install the script to $DESTINATION_PATH or specify another path (must be included in \$PATH)? (Y/path): " response

if [[ "$response" != "y" && "$response" != "Y" && -n "$response" ]]; then
    DESTINATION_PATH=$(eval echo "$response")
    if [[ ! -d "$DESTINATION_PATH" ]]; then
        echo -e "${RED}Error:${NC} Path $DESTINATION_PATH does not exist. Exiting..."
        exit 1
    fi
fi

echo "Installing $SCRIPT_NAME to $DESTINATION_PATH."
sudo curl https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/master/h2mm --output "$DESTINATION_PATH/$SCRIPT_NAME" 
sudo chmod +x "$DESTINATION_PATH/$SCRIPT_NAME"

if [[ ! -x "$(command -v $SCRIPT_NAME)" ]]; then
    echo -e "${RED}Error:${NC} Installation failed."
    exit 1
fi

echo "Helldivers 2 Mod Manager CLI installed successfully to $DESTINATION_PATH/$SCRIPT_NAME. Use it by running '$SCRIPT_NAME'."