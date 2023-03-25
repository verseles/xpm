#!/usr/bin/env bash
set -eu
err() {
  echo -e "ERROR: $1.\nTry again or visit \033[0;34mhttps://xpm.link\033[0m for help."
  exit 1
}

if ((EUID != 0)); then
  echo -e "\033[0;34mThis script requires sudo permissions to install XPM.\033[0m" >&2
  exec sudo "$0" "$@"
fi

# Get latest release version from GitHub
VERSION=$(curl -s https://api.github.com/repos/verseles/xpm/releases/latest | awk -F'"' '/tag_name/{print $4}')
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
echo "Installing XPM version $VERSION..."

if [[ $OS =~ ^(linux|darwin)$ ]]; then
  curl -sL https://github.com/verseles/xpm/releases/download/"$VERSION"/xpm-"$OS" -o xpm || err "Download failed."
else
  err "This script only supports Linux and macOS. Check the site for manual installation instructions."
fi

[[ -f xpm ]] || err "File not found."

chmod +x xpm || err "Could not make xpm executable."

sudo mv -f xpm "${PATH%%:*}" || err "Could install xpm to applications"

xpm -v >/dev/null 2>&1 || err "XPM was not installed correctly."

xpm ref


echo "ooooooo  ooooo ooooooooo.   ooo        ooooo "
echo " \`8888    d8'  \`888   \`Y88. \`88.       .888' "
echo "   Y888..8P     888   .d88'  888b     d'888  "
echo "    \`8888'      888ooo88P'   8 Y88. .P  888  "
echo "   .8PY888.     888          8  \`888'   888  "
echo "  d8'  \`888b    888          8    Y     888  "
echo "o888o  o88888o o888o        o8o        o888o "
echo " "
echo "To search:   xpm <any word here>"
echo "To install:  xpm i program_name"
echo "To uninstall: xpm r program_name"
echo "To upgrade all packages: xpm"
echo "Others commands: xpm -h"
echo " "
