#!/usr/bin/env bash

echo "✔ Setup script triggered successfully."

$GODOT_VERSION = $1;
$GODOT_DL_SUBDIR = $2
$GODOT_RELEASE = $3

echo $GODOT_VERSION
echo $GODOT_DL_SUBDIR
echo $GODOT_RELEASE

# GODOT_HEADLESS_BUILD = "https://downloads.tuxfamily.org/godotengine/3.3.1/Godot_v3.3.1-stable_linux_headless.64.zip"
# GODOT_EXPORT_TEMPLATE = "https://downloads.tuxfamily.org/godotengine/3.3.1/Godot_v3.3.1-stable_export_templates.tpz"

echo "https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip"
echo "wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz"


printenv