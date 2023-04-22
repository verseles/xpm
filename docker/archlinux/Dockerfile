FROM archlinux:latest
RUN pacman -Sy git --noconfirm

# Installs xpm - https://xpm.link
ARG CACHEBUST=$(date +%Y%m%d%H) # bust cache every hour

RUN curl -sL "xpm.link?cache=${CACHEBUST}" | sh

