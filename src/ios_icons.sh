#!/bin/bash
#
# Given a source image, create icons in all sizes needed for an iOS app icon.
# See <https://developer.apple.com/library/ios/qa/qa1686/_index.html> for details.
#
# First (required) argument is path to source file.
#
# Second (optional) argument is the prefix to be used for the output files.
# If not specified, defaults to "app_icon_".
# 
# Third (optional) argument is path to the GraphicsMagick gm executable.
# If not specified, defaults to /usr/local/bin/gm.
#
# Requires GraphicsMagick. ("brew install graphicsmagick" on macOS)

# Source - https://gist.github.com/kristopherjohnson/a4009dd3ea594255c6f1840888194a47

set -e

if [ -z "$1" ]; then
    echo "usage: make-ios-app-icons filename [output-file-prefix] [gm-path]"
    exit 1
fi

sudo apt-get update -y && sudo apt-get install -y graphicsmagick

source_file=$1
output_file_prefix=app_icon_
gm_path=/usr/local/bin/gm

if [ ! -z "$2" ]; then
    output_file_prefix=$2
fi

if [ ! -z "$3" ]; then
    gm_path=$3
fi

if [ ! -e "$gm_path" ]; then
    echo "error: GraphicsMagick executable not found at $gm_path"
    exit 1
fi

generate_size() {
    size=$1
    output_file=$2
    "$gm_path" convert "$source_file" -resize ${size}x${size}\! "$output_file"
}

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
