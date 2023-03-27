#!/usr/bin/env bash
set -eu

err() { echo -e "ERROR: $1.\nTry again or visit \033[0;34mhttps://xpm.link\033[0m for help." >&2; exit 1; }

if command -v sudo &> /dev/null && ((EUID == 0)); then
  echo -e "\033[0;34mThis script requires sudo permissions to install XPM.\033[0m" >&2;
  exec sudo "$0" "$@";
fi


VERSION=$(curl -s https://api.github.com/repos/verseles/xpm/releases/latest | awk -F'"' '/tag_name/{print $4}')
echo "Installing XPM $VERSION..."

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
BASE_URL="https://github.com/verseles/xpm/releases/download/$VERSION"

curl -sL "$BASE_URL"/xpm-"$OS"-"$ARCH".gz | gunzip -c >./xpm || err "Could not download XPM"

(chmod +x ./xpm && sudo mv -f ./xpm "${PATH%%:*}/xpm" && xpm -v >/dev/null 2>&1) || err "XPM was not installed correctly."

xpm ref

echo -e "\n\033[0;32m   XPM was installed successfully\033[0m\n\n   to search:   xpm <any word here>\n   to install:  xpm i program-name\n\n   for more:    xpm -h\n"
