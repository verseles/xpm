FROM ubuntu:latest
RUN apt update
RUN apt install -y curl git jq

# Installs xpm - https://xpm.link
# Download the latest release info from GitHub and extract the tag name
ARG NO_CACHE=$(cat /proc/sys/kernel/random/uuid)
ARG LATEST_TAG=$(curl -sL https://api.github.com/repos/verseles/xpm/releases/latest?$NO_CACHE | jq -r '.tag_name')

# Use the tag name as a cache busting value
RUN curl -sL "xpm.link?v=${LATEST_TAG}" | sh
