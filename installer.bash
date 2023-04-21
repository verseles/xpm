#!/usr/bin/env bash
set -eu

err() { echo -e "\033[0;31mERROR:\033[0m $1.\nTry again or visit \033[0;34mhttps://xpm.link\033[0m for help." >&2; exit 1; }

SUDO=$(command -v sudo || :)
if [ -n "$SUDO" ]; then
  if ! $SUDO -v >/dev/null 2>&1; then
    err "We need sudo to install XPM"
  fi
fi

REPO="verseles/xpm"
TAG=$(curl -s https://api.github.com/repos/$REPO/releases/latest | awk -F'"' '/tag_name/{print $4}')

echo -e "\033[0;34mInstalling XPM $TAG...\033[0m"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
BASE_URL="https://github.com/$REPO/releases/download"
FILE="$BASE_URL/$TAG/xpm-$OS-$ARCH.gz"
curl -sL "$FILE" | gunzip -c >./xpm || err "Could not download $FILE"

BIN_DIR="${PATH%%:*}"
(mkdir -p "$BIN_DIR"
&& chmod +x ./xpm
&& $SUDO mv -f ./xpm "$BIN_DIR/xpm"
&& xpm -v >/dev/null 2>&1) || err "XPM was not installed correctly."

xpm ref

echo -e "\n\033[0;32m   XPM was installed successfully\033[0m\n\n   to search:   xpm <any word here>\n   to install:  xpm i program-name\n\n   for more:    xpm -h\n"
