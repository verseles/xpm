FROM archlinux:latest
RUN pacman -Sy git jq --noconfirm

# Installs xpm - https://xpm.link
RUN echo "XTAG: $XTAG"
RUN curl -sL "xpm.link?t=$XTAG" | sh

