#!/bin/bash

set -e

sudo apt-get update -y && sudo apt-get install -y zip graphicsmagick
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt -y install nodejs 
cd src/upload_artifacts && npm install && cd ..

wget -O icon.png ${ICON_PATH}
source_file=icon.png
icons_folder="icons"
output_file_prefix=app_icon_
gm_path=/usr/bin/gm

if [ ! -e "$gm_path" ]; then
    echo "error: GraphicsMagick executable not found at $gm_path"
    exit 1
fi

generate_size() {
    size=$1
    output_file=$2
    "$gm_path" convert "$source_file" -resize ${size}x${size}\! "${icons_folder}/$output_file"
}

# Create base Icons Folder
mkdir ${icons_folder}

# iPhone and iPad Settings
generate_size 29           "${output_file_prefix}29.png"
generate_size $((29 * 2))  "${output_file_prefix}29@2x.png"
generate_size $((29 * 3))  "${output_file_prefix}29@3x.png"

# iPhone and iPad Spotlight
generate_size 40           "${output_file_prefix}40.png"
generate_size $((40 * 2))  "${output_file_prefix}40@2x.png"
generate_size $((40 * 3))  "${output_file_prefix}40@3x.png"

# iPhone home screen
generate_size $((60 * 2))  "${output_file_prefix}60@2x.png"
generate_size $((60 * 3))  "${output_file_prefix}60@3x.png"

# iPad home screen
generate_size 76           "${output_file_prefix}76.png"
generate_size $((76 * 2))  "${output_file_prefix}76@2x.png"

# iPad Pro home screen
generate_size 167          "${output_file_prefix}83_5@2x.png"

# iTunes
generate_size 512          "iTunesArtwork"
generate_size $((512 * 2)) "iTunesArtwork@2x"

# Apple Watch Notification Center
generate_size 48           "${output_file_prefix}24@2x.png"
generate_size 55           "${output_file_prefix}27_5@2x.png"

# Apple Watch Short-Look
generate_size $((86 * 2))  "${output_file_prefix}86@2x.png"
generate_size $((98 * 2))  "${output_file_prefix}98@2x.png"


WORKSPACE_PATH="${WORKSPACE_PATH:="/github/workspace"}"
zip -r icons.zip ${icons_folder}
ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Icons" FILES="icons.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js