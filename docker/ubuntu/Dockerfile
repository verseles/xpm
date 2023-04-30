FROM ubuntu:latest
RUN apt update
RUN apt install -y curl git

# Installs xpm - https://xpm.link
RUN echo "XTAG: $XTAG"
RUN curl -sL "xpm.link?t=$XTAG" | sh
