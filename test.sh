#!/usr/bin/env bash

# Usage
# run: |
#           chmod +x ./test.sh && sudo ./test.sh --godot_version $GODOT_VERSION --godot_subdir $GODOT_DL_SUBDIR --godot_release $GODOT_RELEASE

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
