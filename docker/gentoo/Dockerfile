FROM gentoo/stage3:latest
RUN emerge --sync
RUN emerge --quiet --autounmask-write net-misc/curl dev-vcs/git
# @FIX use xpm to install git

# Installs xpm - https://xpm.link
RUN curl -sL xpm.link | sh
