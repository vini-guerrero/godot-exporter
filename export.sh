#!/usr/bin/env bash

echo "✔ Export script triggered successfully."

ENV GODOT_VERSION "3.3.1"

mkdir -v -p ~/.local/share/godot/templates
mv /root/.local/share/godot/templates/${GODOT_VERSION}.stable ~/.local/share/godot/templates/${GODOT_VERSION}.stable
mkdir -v -p ~/.config/godot/
cp /root/.config/godot/editor_settings-3.tres ~/.config/godot/editor_settings-3.tres
echo 'export/android/debug_keystore = "/root/android-sdk/debug.keystore"' >> ~/.config/godot/editor_settings-3.tres
echo 'export/android/android_sdk_path = "/root/android-sdk"' >> ~/.config/godot/editor_settings-3.tres

