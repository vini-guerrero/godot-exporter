#!/usr/bin/env bash

echo 'GODOT_VERSION='${{ env.GODOT_VERSION }} >> .env
echo 'GODOT_DL_SUBDIR='${{ env.GODOT_DL_SUBDIR }} >> .env
echo 'GODOT_RELEASE='${{ env.GODOT_RELEASE }} >> .env

echo "Godot Version: $GODOT_VERSION"
echo "Godot Subdir: $GODOT_DL_SUBDIR"
echo "Godot Release: $GODOT_RELEASE"
echo " "
printenv