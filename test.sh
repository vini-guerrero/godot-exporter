#!/usr/bin/env bash

echo "✔ Setup script triggered successfully."

# Defaults & Param Fetch
GODOT_VERSION=${godot_version:-3.3.1}
GODOT_DL_SUBDIR=${godot_subdir:-3.3.1}
GODOT_RELEASE=${godot_release:-stable}
while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
done

# Param Validation
echo $GODOT_VERSION $GODOT_DL_SUBDIR $GODOT_RELEASE

# GODOT_HEADLESS_BUILD = "https://downloads.tuxfamily.org/godotengine/3.3.1/Godot_v3.3.1-stable_linux_headless.64.zip"
# GODOT_EXPORT_TEMPLATE = "https://downloads.tuxfamily.org/godotengine/3.3.1/Godot_v3.3.1-stable_export_templates.tpz"

echo "https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip"
echo "wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz"


printenv