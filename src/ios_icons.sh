#!/bin/bash

set -e

echo -e "\n\n ✔ iOS Icons Script Triggered Successfully. \n\n"

if [ -z "$1" ];
then 
    wget -O icon.png $1
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

    ARTIFACT_NAME="Icons"
    zip -r ${ARTIFACT_NAME}.zip ${icons_folder}
    ACTION_RUNTIME_TOKEN=$ACTION_RUNTIME_TOKEN NAME="${ARTIFACT_NAME}" FILES="${ARTIFACT_NAME}.zip" ROOT_DIR="${WORKSPACE_PATH}" node /upload_artifacts/index.js
fi
