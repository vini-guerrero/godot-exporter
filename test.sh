#!/usr/bin/env bash

echo "✔ Setup script triggered successfully."

BIG=$1
echo $BIG

GODOT_HEADLESS_BUILD = "https://downloads.tuxfamily.org/godotengine/3.3.1/Godot_v3.3.1-stable_linux_headless.64.zip"
GODOT_EXPORT_TEMPLATE = "https://downloads.tuxfamily.org/godotengine/3.3.1/Godot_v3.3.1-stable_export_templates.tpz"

echo "https://downloads.tuxfamily.org/godotengine/$2/Godot_v$1-$3_linux_headless.64.zip"
echo "wget https://downloads.tuxfamily.org/godotengine/$2/Godot_v$1-$3_export_templates.tpz"


printenv