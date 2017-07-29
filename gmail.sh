#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

app_name="Gmail Desktop"
app_slug="gmail"
app_zip="${app_slug}.zip"
app_base="/opt/${app_slug}"
app_exec="${app_base}/${app_slug}"
app_bin_path="/usr/bin/${app_slug}"
app_desktop="/usr/share/applications/${app_slug}.desktop"

OS_ARCH=$(uname -m)

# Decide if the system architeture is 32 or 64
if [ $OS_ARCH != 'x86_64' ]
then
	app_url="https://github.com/insign/gmail-desktop/releases/download/0.0.4/gmail-linux-ia32.zip"
else
	app_url="https://github.com/insign/gmail-desktop/releases/download/0.0.4/gmail-linux-x64.zip"
fi

printf "Starting ${app_name} installation, ${RED}please give admin privilegies${NC}\n"

sudo apt-get -qq install aria2

aria2c --max-concurrent-downloads=5 --max-connection-per-server=5 --min-split-size="2M" --allow-overwrite=true --out="$app_zip" $app_url

if [ -s $app_zip ]; then

	# Remove old copies
	sudo rm -rf ${app_base}*
	sudo rm -rf $app_bin_path
	sudo rm -rf $app_desktop
  
	# unzip in right folder
	sudo unzip -oq $app_zip -d /opt/
	
    # move if necessary
	sudo mv ${app_base}-*/ $app_base
	
	# permissions
	sudo chmod 777 -R ${app_base}

	# link to executables folder
	sudo ln -sf $app_exec $app_bin_path

	# Creates desktop entry
	echo "[Desktop Entry]\nVersion=1.0\nName=${app_name}\nExec=${app_exec}\nIcon=${app_base}/resources/app/icon.png\nType=Application\nCategories=Application;Network;" | sudo tee $app_desktop
	sudo chmod +x $app_desktop

    if [ -s $app_exec ];
    then
        printf "${CYAN}${app_name} installed!${NC}\n"
    else
        printf "${RED}Something went wrong, the installation of ${app_name} failed.${NC}\n"
    fi
	sudo rm -rf $app_zip
else
    echo "${RED}Sorry, the installation of ${app_name} failed, check you internet connection${NC}\n"
fi

