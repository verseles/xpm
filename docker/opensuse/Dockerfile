FROM opensuse/tumbleweed:latest
RUN zypper install -y git curl

# Installs xpm - https://xpm.link
ARG CACHEBUST=$(date +%Y%m%d%H) # bust cache every hour

RUN curl -sL "xpm.link?cache=${CACHEBUST}" | sh

