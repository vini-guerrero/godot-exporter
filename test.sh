#!/usr/bin/env bash

GODOT_VERSION = $GODOT_VERSION
GODOT_DL_SUBDIR = $GODOT_DL_SUBDIR
GODOT_RELEASE = $GODOT_RELEASE

echo "Godot Version: $GODOT_VERSION"
echo "Godot Subdir: $GODOT_DL_SUBDIR"
echo "Godot Release: $GODOT_RELEASE"
echo "https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip"
echo " "
printenv