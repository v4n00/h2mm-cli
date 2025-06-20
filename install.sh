#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

DESTINATION_PATH="/usr/local/bin"
SCRIPT_NAME="h2mm"
REPO_URL="https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/remove-nexus-upgrade"

function log() {
	local type="$1"
	shift
	case "$type" in
		INFO)
			echo -e "$*" >&2
			;;
		ERROR)
			echo -e "${RED}[ERROR]${NC} $*" >&2
			;;
		PROMPT)
			echo -ne "$*" >&2
			;;
	esac
}

# --- Main ---

# warning

cat << EOF
!!! WARNING !!!
This script will install Helldivers 2 Mod Manager CLI for Linux to $DESTINATION_PATH/$SCRIPT_NAME.
Running this script will require sudo permissions. DO NOT TRUST random scripts from the internet.
If you want to review the script before running it, check out the mod repository for yourself:
https://github.com/v4n00/h2mm-cli
!!! WARNING !!!

EOF

# breaking changes hash table
breaking_changes_patches=(
    ["2"]='sed -i "s/^\([0-9]\+\),/\1,ENABLED,/" "$1/mods.csv"'
    ["3"]='sed -i "1 i\\3" "$1/mods.csv"'
	["4"]='tmp_file=$(mktemp) && awk '\''BEGIN {FS=OFS=","} NR==1 {print 4; next} {print NR-1, $2, $3, $4, $5}'\'' "$1/mods.csv" > "$tmp_file" && tee "$1/mods.csv" < "$tmp_file" > /dev/null && rm "$tmp_file"'
	["5"]='sed -i "s/^\([0-9]\+\),\(.*\),\(.*\),\(.*\)/\1,\2,\3,,,,\4/" "$1/mods.csv"; sed -i "1 s/4/5/" "$1/mods.csv"'
	["6"]='sed -i "s/^\([0-9]\+\),\(.*\),\(.*\),\(.*\),\(.*\),\(.*\),\(.*\)/\1,\2,\3,\4,\6,\7/" "$1/mods.csv"; sed -i "1 s/5/6/" "$1/mods.csv"'
)

# notify if update is happening
installed_version=""
latest_version=""
if [[ -x "$(command -v $SCRIPT_NAME)" ]]; then
    installed_version=$($SCRIPT_NAME --version)

	# if installed version isn't x.x.x crash
	if [[ ! "$installed_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		log ERROR "Installed version is not in the correct format."
		log ERROR "h2mm is installed here -> $(which h2mm)"
		log ERROR "Delete the script file and retry the install script, any mods installed will not be lost."
		log INFO 'Download using the command: bash -c "$(curl -fsSL https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/master/install.sh)"'
		exit 1
	fi

    latest_version=$(curl -sS "$REPO_URL"/version)
    if [[ "$latest_version" == "$installed_version" ]]; then
        log INFO "You are reinstalling version ${GREEN}$installed_version${NC}."
    else
        log INFO "You are upgrading from ${ORANGE}$installed_version${NC} -> ${GREEN}$latest_version${NC}."
    fi
fi

# if steam deck, set destination path to ~/.local/bin
log PROMPT "Are you installing on a Steam Deck? (y/N): "
IFS= read -e response_sd

if [[ "$response_sd" == "y" || "$response_sd" == "Y" ]]; then
    # steam deck
    DESTINATION_PATH="$HOME/.local/bin"
    mkdir -p "$DESTINATION_PATH"

    # check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        # add ~/.local/bin to PATH
        log INFO "Installing the script on a Steam Deck means adding $DESTINATION_PATH to your \$PATH."
        log INFO "If you're using a different shell than bash (the default), you may need to add it manually."

		log PROMPT "Do you want to add $DESTINATION_PATH to your \$PATH in ~/.bashrc? (Y/n): "
        IFS= read -e response
        if [[ "$response" == "y" || "$response" = "Y" || -z "$response" ]]; then
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
			[[ $? -ne 0 ]] && { log ERROR "Failed to add $DESTINATION_PATH to \$PATH in ~/.bashrc." ; exit 1; }

			source "$HOME/.bashrc"
			export PATH="$HOME/.local/bin:$PATH" # fallback kinda in case sourcing fails

            log INFO "Added $DESTINATION_PATH to your \$PATH in ~/.bashrc."
        fi
    fi
else
    # not steam deck
    # set another path if needed
	log PROMPT "Install the script to $DESTINATION_PATH or specify another path (must be included in \$PATH)? (Y/path): "
    IFS= read -e response

    if [[ "$response" != "y" && "$response" != "Y" && -n "$response" ]]; then
        DESTINATION_PATH="$response"
        [[ ! -d "$DESTINATION_PATH" ]] && { log ERROR "Path $DESTINATION_PATH does not exist." ; exit 1; }
    fi
fi

# handle breaking changes
installed_major=$(echo "$installed_version" | awk -F. '{print $2}')
latest_major=$(echo "$latest_version" | awk -F. '{print $2}')

if [[ $latest_major -gt $installed_major ]]; then
	log INFO ""
	log INFO "Major version upgrade detected."
	log INFO "Check out the changelogs here -> https://github.com/v4n00/h2mm-cli/releases"
	log INFO "The script will proceed to upgrade the database file to avoid breaking changes."

	# find hd2 path
	search_dir="${HOME}"
	target_dir="Steam/steamapps/common/Helldivers\ 2/data"

	# make backup
	log INFO "Creating a backup in case anything goes wrong."
	h2mm export

	# check if game directory is in ~/.config/h2mm/h2path
	if [[ -f "$HOME/.config/h2mm/h2path" ]]; then
		game_dir=$(cat "$HOME/.config/h2mm/h2path")
		[[ ! -d "$game_dir" ]] && { log ERROR "Helldivers 2 data directory is not valid: $game_dir." ; exit 1; }
	else
		log INFO "Searching for the Helldivers 2 data directory... (10 seconds timeout)"
		game_dir=$(timeout 10 find "$search_dir" -type d -path "*/$target_dir" 2>/dev/null | head -n 1)
	fi

	# if not found, prompt user
	if [[ -z "$game_dir" ]]; then
		# if not found, ask user for the directory
		log INFO "Could not find the Helldivers 2 data directory automatically."
		log PROMPT "Please enter the path to the Helldivers 2 data directory: "
		IFS= read -e game_dir; unset IFS
		game_dir="$(substitute_home "$game_dir")"

		[[ ! -d "$game_dir" ]] && { log ERROR "Provided path is not a valid directory."; exit 1; }
	else
		# confirm with the user that the directory is ok
		log INFO "Found Helldivers 2 data directory: $game_dir"
		log PROMPT "Is this the correct directory? (Y/n): "
		read confirm

		if [[ "$confirm" != "y" && "$confirm" != "Y" && "$confirm" != "" ]]; then
			log PROMPT "Please enter the path to the Helldivers 2 data directory: "
			IFS= read -e game_dir; unset IFS
			game_dir="$(substitute_home "$game_dir")"

			[[ ! -d "$game_dir" ]] && { log ERROR "Provided path is not a valid directory."; exit 1; }
		fi
	fi

	[[ ! -f "$game_dir/mods.csv" ]] && { log ERROR "mods.csv not found in $game_dir." ; exit 1; }

	# iterate from installed major number to latest major number
	for ((i = installed_major + 1; i <= latest_major; i++)); do
		if [[ -n "${breaking_changes_patches[$i]}" ]]; then
			# apply breaking changes patch
			eval $(echo "${breaking_changes_patches[$i]}" | sed "s:\$1:$game_dir:g")
		else
			log INFO "No breaking changes for version $i."
			continue
		fi

		if [[ $? -ne 0 ]]; then
			log ERROR "Failed to apply breaking changes patch for version $i. Do you want to continue? (Y/n): "
			read -er response

			[[ "$response" != "y" && "$response" != "Y" && -n "$response" ]] && { log INFO "Exiting." ; exit 1; }
		else
			log INFO "Version upgrade fix ${GREEN}successfully${NC} applied for version $i."
		fi
	done
	log INFO ""
fi

# install
log INFO "Installing $SCRIPT_NAME to $DESTINATION_PATH."
sudo curl "$REPO_URL"/h2mm --output "$DESTINATION_PATH/$SCRIPT_NAME"
sudo chmod +x "$DESTINATION_PATH/$SCRIPT_NAME"
log INFO ""

[[ ! -x "$(command -v $SCRIPT_NAME)" ]] && { log ERROR "Installation failed. Mod manager was not found in \$PATH." ; exit 1; }

log INFO "Helldivers 2 Mod Manager CLI ${GREEN}successfully${NC} installed."
log INFO "${GREEN}IMPORTANT${NC}: To install mods, you need to have installed:"
log INFO " -> \"unzip\" package for .zip archives"
log INFO " -> \"unarchiver\" package for .rar archives"
log INFO "If you do not know how to install these packages, please search for your linux distro on how to install packages."
log INFO ""
log INFO "Use the mod manager by running '$SCRIPT_NAME' in your terminal."
log INFO "Made with love <3 by v4n and contributors."
