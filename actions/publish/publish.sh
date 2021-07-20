#!/usr/bin/env bash
set -e

echo -e "✔ Publish Script Triggered Successfully."

curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
unzip butler.zip && cp butler /usr/bin && chmod +x /usr/bin/butler
