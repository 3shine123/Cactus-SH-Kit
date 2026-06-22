#!/bin/bash

INSTALL_DIR="/usr/local/share/Cactus-SH-Kit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$SCRIPT_DIR" = "$INSTALL_DIR" ]; then
    echo "Already installed."
    exit 0
fi

if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf "$INSTALL_DIR"
fi

sudo cp -r "$SCRIPT_DIR" /usr/local/share/
echo "Installed to: $INSTALL_DIR"
