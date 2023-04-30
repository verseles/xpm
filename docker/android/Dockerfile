FROM termux/termux-docker:latest
RUN pkg update
RUN pkg install -y curl git 

# Installs xpm - https://xpm.link
RUN echo "XTAG: $XTAG"
RUN curl -sL "xpm.link?t=$XTAG" | sh
