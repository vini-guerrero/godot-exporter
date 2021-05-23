#!/usr/bin/env bash


echo "Godot Version: $GODOT_VERSION"
echo "Godot Subdir: $GODOT_DL_SUBDIR"
echo "Godot Release: $GODOT_RELEASE"

echo 'GODOT_VERSION='${{ env.GODOT_VERSION }} >> .env 
echo 'GODOT_DL_SUBDIR='${{ env.GODOT_DL_SUBDIR }} >> .env 
echo 'GODOT_RELEASE='${{ env.GODOT_RELEASE }} >> .env 

echo "https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip"
echo " "
printenv