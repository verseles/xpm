FROM ubuntu:latest
RUN apt update
RUN apt install -y curl git jq

# Installs xpm - https://xpm.link
# Download the latest release info from GitHub and extract the tag name
ARG LATEST_TAG=$(curl -sL -H 'Cache-Control: no-cache' https://api.github.com/repos/verseles/xpm/releases/latest | jq -r '.tag_name')

# Use the tag name as a cache busting value
RUN curl -sL "xpm.link?v=${LATEST_TAG}" | sh
