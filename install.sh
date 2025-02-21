#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

DESTINATION_PATH="/usr/local/bin"
SCRIPT_NAME="h2mm"
REPO_URL="https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/master"

# --- Main ---

# Warning

echo -e "!!! ${RED}WARNING${NC} !!!" >&2
echo -e "This script will install Helldivers 2 Mod Manager CLI for Linux to $DESTINATION_PATH/$SCRIPT_NAME." >&2
echo -e "Running this script will require sudo permissions. ${RED}DO NOT TRUST${NC} random scripts from the internet." >&2
echo -e "If you want to review the script before running it, check out the mod repository for yourself:" >&2
echo -e "https://github.com/v4n00/h2mm-cli" >&2
echo -e "!!! ${RED}WARNING${NC} !!!" >&2
echo >&2

# Check if update

# Breaking changes hash table

breaking_changes_patches=(
    ["2"]='sed -i "s/^\([0-9]\+\),/\1,ENABLED,/" "$1/mods.csv"'
    ["3"]='sed -i "1 i\\3" "$1/mods.csv"'
)

# Handle breaking changes

if [[ -x "$(command -v $SCRIPT_NAME)" ]]; then
    installed_version=$($SCRIPT_NAME --version)
    # version 1 show the help message, if the first character is not a 0, store installed version as 0.1.6
    [[ ${installed_version:0:1} != "0" ]] && { installed_version="0.1.6"; }

    latest_version=$(curl -sS "$REPO_URL"/version)
    if [[ "$latest_version" == "$installed_version" ]]; then
        echo -e "You are reinstalling version ${GREEN}$installed_version${NC}." >&2
    else
        echo -e "You are upgrading from ${ORANGE}$installed_version${NC} -> ${GREEN}$latest_version${NC}." >&2
    fi

    # split version numbers
    installed_major=""
    latest_major=""
    IFS='.' read -r _1 installed_major _2 <<< "$installed_version"
    IFS='.' read -r _1 latest_major _2 <<< "$latest_version"

    if [[ $latest_major -gt $installed_major ]]; then
        echo -e "${ORANGE}Warning:${NC} Major version upgrade detected." >&2
        echo -e "${ORANGE}Info${NC}: Check out the changelogs here -> https://github.com/v4n00/h2mm-cli/releases" >&2
        echo -e "The script will proceed to upgrade ${SCRIPT_NAME} to avoid breaking changes." >&2

        # find hd2 path
        search_dir="${HOME}"
        target_dir="Steam/steamapps/common/Helldivers\ 2/data"
        echo "Searching for the Helldivers 2 data directory... (20 seconds timeout)" >&2

        game_dir=$(timeout 20 find "$search_dir" -type d -path "*/$target_dir" 2>/dev/null | head -n 1)
        if [[ -z "$game_dir" ]]; then
			echo "Could not find the Helldivers 2 data directory automatically." >&2
			echo -ne "Please enter the path to the Helldivers 2 data directory: " >&2
			IFS= read -e game_dir
			if [[ ! -d "$game_dir" ]]; then
				echo -e "${RED}Error${NC}: Provided path is not a valid directory." >&2
				exit 1
			fi
		fi

        [[ ! -f "$game_dir/mods.csv" ]] && { echo -e "${RED}Error:${NC} mods.csv not found in $game_dir." >&2; exit 1; }

        # iterate from installed major number to latest major number
        for ((i = installed_major + 1; i <= latest_major; i++)); do
            if [[ -n "${breaking_changes_patches[$i]}" ]]; then
                eval $(echo "${breaking_changes_patches[$i]}" | sed "s:\$1:$game_dir:")
            else
                echo "No breaking changes for version $i." >&2
            fi
            if [[ $? -ne 0 ]]; then
                echo -ne "${RED}Error:${NC} Failed to apply breaking changes patch for version $i. Do you want to continue? (Y/n): " >&2
                read -er response

                [[ "$response" != "y" && "$response" != "Y" && -n "$response" ]] && { echo "Exiting. Uninstall the script first the retry the install script." >&2; exit 1; }
            else
                echo -e "Breaking changes patch for version ${ORANGE}$i${NC} applied ${GREEN}successfully${NC}." >&2
            fi
        done
    fi
    echo
fi

# Install

# if steam deck, set destination path to ~/.local/bin
echo -ne "Are you installing on a Steam Deck? (y/N): " >&2
IFS= read -e response_sd

if [[ "$response_sd" == "y" || "$response_sd" == "Y" ]]; then
    # steam deck
    DESTINATION_PATH="$HOME/.local/bin"
    mkdir -p "$DESTINATION_PATH"

    # check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        # add ~/.local/bin to PATH
        echo -e "${ORANGE}Warning:${NC} Installing the script on a Steam Deck means adding $DESTINATION_PATH to your \$PATH." >&2
        echo -e "${ORANGE}Warning:${NC} If you're using a different shell than bash, you may need to add it manually." >&2

		echo -ne "Do you want to add $DESTINATION_PATH to your \$PATH in ~/.bashrc? (Y/n): " >&2
        IFS= read -e response
        if [[ "$response" == "y" || "$response" = "Y" || -z "$response" ]]; then
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
            echo -e "${GREEN}Success:${NC} Added $DESTINATION_PATH to your \$PATH in ~/.bashrc." >&2
        fi
    fi
else
    # not steam deck
    # set another path if needed
	echo -ne "Install the script to $DESTINATION_PATH or specify another path (must be included in \$PATH)? (Y/path): " >&2
    IFS= read -e response

    if [[ "$response" != "y" && "$response" != "Y" && -n "$response" ]]; then
        DESTINATION_PATH="$response"
        [[ ! -d "$DESTINATION_PATH" ]] && { echo -e "${RED}Error:${NC} Path $DESTINATION_PATH does not exist." >&2; exit 1; }
    fi
fi

echo -e "Installing $SCRIPT_NAME to $DESTINATION_PATH." >&2
sudo curl "$REPO_URL"/h2mm --output "$DESTINATION_PATH/$SCRIPT_NAME"
sudo chmod +x "$DESTINATION_PATH/$SCRIPT_NAME"

[[ ! -x "$(command -v $SCRIPT_NAME)" ]] && { echo -e "${RED}Error:${NC} Installation failed. Mod manager was not found in \$PATH." >&2; exit 1; }

echo "Helldivers 2 Mod Manager CLI installed successfully to $DESTINATION_PATH/$SCRIPT_NAME. Use it by running '$SCRIPT_NAME'." >&2
