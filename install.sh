#!/bin/bash
set -e

if [ "$(id -u)" -eq 0 ]; then
    echo "Run me as normal user, not as root."
    exit 1
fi

DESTINATION_PATH="/usr/local/bin"
SCRIPT_NAME="h2mm"

echo "Installing $SCRIPT_NAME..."
sudo curl https://raw.githubusercontent.com/v4n00/h2mm-cli/refs/heads/master/h2mm --output "$DESTINATION_PATH/$SCRIPT_NAME" 
sudo chmod +x "$DESTINATION_PATH/$SCRIPT_NAME"

if [[ ! -x "$(command -v $SCRIPT_NAME)" ]]; then
    echo "Installation failed."
    exit 1
fi

echo "Helldivers 2 Mod Manager CLI installed successfully to $DESTINATION_PATH/$SCRIPT_NAME. Use it by running '$SCRIPT_NAME'."
