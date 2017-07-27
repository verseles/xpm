#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'


NC='\033[0m' # No Color

printf "Starting Telegram installation, ${RED}please give admin privilegies${NC}\n"

sudo apt-get -qq install aria2

telegram_url="https://telegram.org/dl/desktop/linux"
telegram_file="telegram_setup.tar.xz"
OS_ARCH=$(uname -m)

# Decide if the system architeture is 32 or 64
if [ $OS_ARCH != 'x86_64' ]; then
	telegram_url="${telegram_url}32"
fi

aria2c --max-concurrent-downloads=5 --max-connection-per-server=5 --min-split-size="2M" --allow-overwrite=true --out="$telegram_file" $telegram_url


if [ -s $telegram_file ]; then

	# Remove old copies
	sudo rm -rf /opt/telegram* 
	sudo rm -rf /usr/bin/telegram
	sudo rm -rf /usr/share/applications/telegram.desktop

	# unzip in right folder
	sudo tar Jxf $telegram_file -C /opt/

	# move if necessary
	sudo mv /opt/Telegram*/ /opt/telegram

	# link to executables folder
	sudo ln -sf /opt/telegram/Telegram /usr/bin/telegram

	# Creates desktop entry
	echo -e '[Desktop Entry]\n Version=1.0\n Exec=/opt/telegram/Telegram\n Icon=Telegram\n Type=Application\n Categories=Application;Network;' | sudo tee /usr/share/applications/telegram.desktop
	sudo chmod +x /usr/share/applications/telegram.desktop

	printf "${CYAN}Telegram installed! Since Telegram has built-in update, you never should run this command again.${NC}\n"

	sudo rm -rf $telegram_file

	exit
fi

echo "Sorry, the installation failed, check you internet connection"
