#!/usr/bin/env bash
set -e
echo "\n\n ✔ Publish Script Triggered Successfully. \n\n "

# Itch.io - Butler Integration
curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default \
&& unzip butler.zip \
&& cp butler /usr/bin \
&& chmod +x /usr/bin/butler

# To-Do Integrations

# Gamejolt
# https://github.com/gamejolt/cli

