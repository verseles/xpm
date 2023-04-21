#!/usr/bin/env bash
# This script installs/updates the XPM CLI on Linux or macOS.
set -eu

# The err function prints an error message and exits the script.
err() {
  echo -e "\033[0;31mERROR:\033[0m $1.\nTry again or visit \033[0;34mhttps://xpm.link\033[0m for help." >&2
  exit 1
}

# Check if the user has sudo. If they do, we'll use it to install
# XPM. If they don't, we'll install XPM without root privileges.
SUDO=$(command -v sudo || :)
if [ -n "$SUDO" ]; then
  if ! $SUDO -v >/dev/null 2>&1; then
    err "We need sudo to install XPM"
  fi
fi

# XPM will be installed in the first directory in the user's PATH
BIN_DIR="${PATH%%:*}"

# If the user passed the "uninstall" argument, then we're uninstalling
# XPM. Delete the XPM executable and exit.
if [ "${1:-}" = "uninstall" ]; then
  echo "Uninstalling XPM..."
  $SUDO rm -rf "$BIN_DIR"/xpm || err "Could not remove xpm from $BIN_DIR"
  echo -e "\n\033[0;32m   XPM was \033[0;31muninstalled\033[0;32m successfully\033[0m\n"
  exit 0
fi

# Get the latest release tag from GitHub
REPO="verseles/xpm"
TAG=$(curl -s https://api.github.com/repos/$REPO/releases/latest | awk -F'"' '/tag_name/{print $4}')

echo -e "\n\033[0;32m   Installing XPM $TAG\033[0m\n"

# Determine the OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')

# The base URL for the XPM executable.
BASE_URL="https://github.com/$REPO/releases/download"

# The URL of the XPM executable for this OS and architecture.
FILE="$BASE_URL/$TAG/xpm-$OS-$ARCH.gz"

# Download the XPM file from the specified URL.
curl -sL "$FILE" | gunzip -c >./xpm || err "Could not download $FILE"

# Move it to the bin directory.
mkdir -p "$BIN_DIR" || err "Could not create $BIN_DIR"

# Make the XPM executable.
chmod +x ./xpm || err "Could not make xpm executable"

# Move the XPM executable to the bin directory.
$SUDO mv -f ./xpm "$BIN_DIR/xpm" || err "Could not move xpm to $BIN_DIR"

# Check if XPM was installed correctly.
xpm -v >/dev/null 2>&1 || err "XPM was not installed correctly."

# Refresh the repository index for the first time.
xpm ref

# Print the success message.
echo -e "\n\033[0;32m   XPM was installed successfully\033[0m\n\n   to search:   xpm <any word here>\n   to install:  xpm i program-name\n\n   for more:    xpm -h\n"
