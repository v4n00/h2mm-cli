#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

DESTINATION_PATH="/usr/local/bin"
SCRIPT_NAME="h2mm"

if [ "$(id -u)" -eq 0 ]; then
    echo "Run me as normal user, not as root."
    exit 1
fi

# --- Main ---

# Warning

echo -e "!!! ${RED}WARNING${NC} !!!"
echo -e "This script will install Helldivers 2 Mod Manager CLI for Linux to $DESTINATION_PATH/$SCRIPT_NAME."
echo -e "Running this script will require sudo permissions. ${RED}DO NOT TRUST${NC} random scripts from the internet."
echo -e "If you want to review the script before running it, check out the mod repository for yourself:"
echo -e "https://github.com/v4n00/h2mm-cli"
echo -e "!!! ${RED}WARNING${NC} !!!"
echo

# Check if update

# Breaking changes hash table

breaking_changes_patches=(
    ["2"]='sed -i "s/^\([0-9]\+\),/\1,ENABLED,/" "$1/mods.csv"'
)

# Script

if [[ -x "$(command -v $SCRIPT_NAME)" ]]; then
    installed_version=$($SCRIPT_NAME --version)
    # version 1 show the help message, if the first character is not a 0, store installed version as 0.1.6
    [[ ${installed_version:0:1} != "0" ]] && { installed_version="0.1.6"; }

    latest_version=$(curl -sS https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/master/version)
    if [[ "$latest_version" == "$installed_version" ]]; then
        echo -e "You are reinstalling version $installed_version."
    else
        echo -e "You are upgrading from ${ORANGE}$installed_version${NC} -> ${GREEN}$latest_version${NC}."
    fi

    # split version numbers
    installed_major=""
    latest_major=""
    IFS='.' read -r _1 installed_major _2 <<< "$installed_version"
    IFS='.' read -r _1 latest_major _2 <<< "$latest_version"

    if [[ $latest_major -gt $installed_major ]]; then
        echo -e "${ORANGE}Warning:${NC} Major version upgrade detected."
        echo "Check out the changelogs here:"
        echo "https://github.com/v4n00/h2mm-cli/releases"
        echo "The script will proceed to upgrade ${SCRIPT_NAME} to avoid breaking changes."

        # find hd2 path
        search_dir="${HOME}"
        target_dir="Steam/steamapps/common/Helldivers\ 2/data"
        echo "Searching for the Helldivers 2 data directory..." >&2
        game_dir=$(find "$search_dir" -type d -path "*/$target_dir" 2>/dev/null | head -n 1)
        if [[ -z "$game_dir" ]]; then
            echo "Could not find the Helldivers 2 data directory automatically." >&2
            read -p "Please enter the path to the Helldivers 2 data directory: " game_dir
            game_dir=$(eval echo "$game_dir")

            if [[ ! -d "$game_dir" ]]; then
                echo -e "${RED}Error${NC}: Provided path is not a valid directory." >&2
                exit 1
            fi
        fi

        [[ ! -f "$game_dir/mods.csv" ]] && { echo -e "${RED}Error:${NC} mods.csv not found in $game_dir."; exit 1; }

        # iterate from installed major number to latest major number
        for ((i = installed_major + 1; i <= latest_major; i++)); do
            echo -e "${RED}[ ]${NC} Applying breaking changes patch for version $i."

            [[ -n "${breaking_changes_patches[$i]}" ]] && eval $(echo "${breaking_changes_patches[$i]}" | sed "s:\$1:$game_dir:")
            if [[ $? -ne 0 ]]; then
                echo -ne "${RED}Error:${NC} Failed to apply breaking changes patch for version $i. Do you want to continue? (Y/n): "
                read -r response
                
                [[ "$response" != "y" && "$response" != "Y" && -n "$response" ]] && { echo "Exiting. Uninstall the script first the retry the install script."; exit 1; }
            else
                echo -e "${GREEN}[X]${NC} Breaking changes patch for version $i applied successfully."
            fi
        done
    fi
fi

# Install

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