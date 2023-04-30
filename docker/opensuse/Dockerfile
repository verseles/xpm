FROM opensuse/tumbleweed:latest
RUN zypper install -y git curl

# Installs xpm - https://xpm.link
RUN echo "XTAG: $XTAG"
RUN curl -sL "xpm.link?t=$XTAG" | sh

