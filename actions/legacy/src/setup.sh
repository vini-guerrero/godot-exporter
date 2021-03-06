#!/usr/bin/env bash
set -e
echo "\n\n ✔ Environment Setup Script Triggered Successfully. \n\n "


# Environment Variables
ROOT_PATH="${ROOT_PATH:="/github/home"}"
WORKSPACE_PATH="${WORKSPACE_PATH:="/github/workspace"}"
TRES_PATH=${ROOT_PATH}/.config/godot/editor_settings-3.tres


# Expected Env Format - EXPORT_PLATFORMS="Android|Linux|MacOS"
IFS="|" read -a GODOT_EXPORT_PLATFORMS <<< $EXPORT_PLATFORMS
echo "✔ Export Platforms: ${GODOT_EXPORT_PLATFORMS[@]} - Total ${#GODOT_EXPORT_PLATFORMS[@]}."

if [ -z "${GODOT_VERSION}" ]
then
    echo -e "Godot version env variable doesn't exist, using latest godot"
    GODOT_VERSION=$(curl https://godotexporterapi.andreamiele.repl.co/api/godot-version)
fi

if [ "${GODOT_RELEASE}" == "stable" ]
then
    LINK_GODOT="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip"
    LINK_TEMPLATES="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
elif [ "${GODOT_RELEASE}" == "mono" ]
then
    echo "::error::Mono version of Godot Engine is not supported yet"
    exit 1
else #using subdirectory
    LINK_GODOT="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/${GODOT_RELEASE}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip"
    LINK_TEMPLATES="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/${GODOT_RELEASE}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz"
fi

# Download & Setup
wget ${LINK_GODOT}
wget ${LINK_TEMPLATES}
sudo mkdir -p -v $ROOT_PATH/.cache && sudo mkdir -p -v $ROOT_PATH/.config/godot
sudo mkdir -p -v $ROOT_PATH/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}

# Engine
unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip && sudo mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64 /usr/local/bin/godot
# Templates
unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz && sudo mv templates/* $ROOT_PATH/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}
# Clean
sudo rm -f Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip


# Godot Executable From Path
echo "✔ Godot Editor First Launch."
cd / && chmod +x /usr/local/bin/godot && godot -e -q
echo "✔ Godot Editor Launched."


# Move To Export Path
cd ${WORKSPACE_PATH}/${EXPORT_PATH} && ls


# iOS Icons Generation
if [[ ! -z "${IOS_ICON_PATH}" ]]
then 
    echo "✔ iOS Icons Generator Started."    
    wget -O icon.png ${IOS_ICON_PATH}
    source_file=icon.png
    icons_folder="icons"
    ICONS_ARTIFACT_NAME="Icons"
    output_file_prefix=app_icon_
    gm_path=/usr/bin/gm
    
    generate_size() {
        size=$1
        output_file=$2
        "$gm_path" convert "$source_file" -resize ${size}x${size}\! "${icons_folder}/$output_file"
    }
    # Create base Icons Folder
    mkdir ${icons_folder}

    # Optional Icons Export Session 
    generate_size 20           "${output_file_prefix}20x20.png"
    generate_size 29           "${output_file_prefix}29x29.png"
    generate_size 40           "${output_file_prefix}40x40.png"
    generate_size 58           "${output_file_prefix}58x58.png"
    generate_size 60           "${output_file_prefix}60x60.png"
    generate_size 76           "${output_file_prefix}76x76.png"
    generate_size 80           "${output_file_prefix}80x80.png"
    generate_size 87           "${output_file_prefix}87x87.png"
    generate_size 120          "${output_file_prefix}120x120.png"
    generate_size 152          "${output_file_prefix}152x152.png"
    generate_size 167          "${output_file_prefix}1670x167.png"
    generate_size 180          "${output_file_prefix}180x180.png"
    generate_size 1024         "${output_file_prefix}1024x1024.png"

    # Upload Icons as Artifact
    zip -r ${ICONS_ARTIFACT_NAME}.zip ${icons_folder}
    ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="${ICONS_ARTIFACT_NAME}" FILES="${ICONS_ARTIFACT_NAME}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js
fi


# Prepare Android Export
if [[ ${GODOT_EXPORT_PLATFORMS[@]} =~ "Android" ]]
then 
    # Set Editor Settings For Android Export
    sed -i '/\[resource\]/a export\/android\/android_sdk_path = "/root/android-sdk"' ${TRES_PATH} \
    && sed -i '/\[resource\]/a export\/android\/adb = "/root/android-sdk/platform-tools/adb"' ${TRES_PATH} \
    && sed -i '/\[resource\]/a export\/android\/jarsigner = "/usr/bin/jarsigner"' ${TRES_PATH} \
    && sed -i '/\[resource\]/a export\/android\/apksigner = "/usr/bin/apksigner"' ${TRES_PATH} \
    && sed -i '/\[resource\]/a export\/android\/debug_keystore = "/root/android-sdk/debug.keystore"' ${TRES_PATH} \
    && sed -i '/\[resource\]/a export\/android\/debug_user = "androiddebugkey"' ${TRES_PATH} \
    && sed -i '/\[resource\]/a export\/android\/debug_pass = "android"' ${TRES_PATH}
    echo "✔ Android Project Export Setup Ready"    
fi


# Prepare iOS Export
if [[ ${GODOT_EXPORT_PLATFORMS[@]} =~ "iOS" ]]
then 
    # Set Editor Settings For iOS Export
    ICON_PATH="res:\/\/assets\/sprites\/icon\.png"
    sed -i '/\[rendering\]/a vram_compression\/import_pvrtc=true' ${WORKSPACE_PATH}/${EXPORT_PATH}/project.godot \
    && sed -i 's@required_icons/iphone_120x120[[:space:]]*=[[:space:]]*".*"@required_icons/iphone_120x120 = "'${ICON_PATH}'"@g' ${WORKSPACE_PATH}/${EXPORT_PATH}/export_presets.cfg \
    && sed -i 's@required_icons/ipad_76x76[[:space:]]*=[[:space:]]*".*"@required_icons/ipad_76x76 = "'${ICON_PATH}'"@g' ${WORKSPACE_PATH}/${EXPORT_PATH}/export_presets.cfg \
    && sed -i 's@required_icons/app_store_1024x1024[[:space:]]*=[[:space:]]*".*"@required_icons/app_store_1024x1024 = "'${ICON_PATH}'"@g' ${WORKSPACE_PATH}/${EXPORT_PATH}/export_presets.cfg \
    #&& sed -i '/\required_icons/\iphone_180x180="'${ICON_PATH}'"' ${WORKSPACE_PATH}/${EXPORT_PATH}/export_presets.cfg \
    #&& sed -i '/\required_icons/\ipad_152x152="'${ICON_PATH}'"' ${WORKSPACE_PATH}/${EXPORT_PATH}/export_presets.cfg \
    #&& sed -i '/\required_icons/\ipad_167x167="'${ICON_PATH}'"' ${WORKSPACE_PATH}/${EXPORT_PATH}/export_presets.cfg \
    #&& sed -i '/\required_icons/\spotlight_40x40="'${ICON_PATH}'"' ${WORKSPACE_PATH}/${EXPORT_PATH}/export_presets.cfg \
    #&& sed -i '/\required_icons/\spotlight_80x80="'${ICON_PATH}'"' ${WORKSPACE_PATH}/${EXPORT_PATH}/export_presets.cfg
    echo "✔ iOS Project Export Setup Ready"
fi


# Validate Editor Settings
cat ${TRES_PATH}


# Export Platforms  
for platform in "${GODOT_EXPORT_PLATFORMS[@]}"
do
    echo "✔ Exporting ${platform} Platform"
    mkdir -v -p "build/${platform}"
    
    if [[ $platform == "Linux" ]]
    then                
        godot --verbose --export "${platform}" "build/${platform}/${EXPORT_NAME}.x86_64"
        zip -r "${platform}.zip" build/${platform}
        ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Linux" FILES="${platform}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js
    elif [[ $platform == "Mac OSX" ]]
    then
        godot --verbose --export "${platform}" "build/${platform}/${EXPORT_NAME}.zip"
        zip -r "${platform}.zip" "build/${platform}"
        ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Mac OSX" FILES="${platform}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js
    elif [[ $platform == "Windows Desktop" ]]
    then
        godot --verbose --export "${platform}" "build/${platform}/${EXPORT_NAME}.exe"
        zip -r "${platform}.zip" "build/${platform}"
        ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Windows Desktop" FILES="${platform}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js
    elif [[ $platform == "HTML5" ]]
    then
        godot --verbose --export "${platform}" "build/${platform}/index.html"
        zip -r "${platform}.zip" build/${platform}
        ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="HTML5" FILES="${platform}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js
    elif [[ $platform == "Android" ]]

    then
        # Debug
  
      if [ ${EXPORT_MODE} == "debug" ]
        then        
            godot --verbose --export-debug "Android" "build/${platform}/${EXPORT_NAME}.debug.apk"
            zip -r ${platform}.zip build/${platform}
            ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Android" FILES="${platform}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js

        # Release
        elif [ ${EXPORT_MODE} == "release" ]
        then
            echo ${K8S_SECRET_RELEASE_KEYSTORE_BASE64} | base64 --decode > /root/release.keystore 
            sed 's@keystore/release[[:space:]]*=[[:space:]]*".*"@keystore/release = "/root/release.keystore"@g' -i export_presets.cfg 
            sed 's@keystore/release_password[[:space:]]*=[[:space:]]*".*"@keystore/release_password="'${K8S_SECRET_RELEASE_KEYSTORE_PASSWORD}'"@g' -i export_presets.cfg
            sed 's@keystore/release_user[[:space:]]*=[[:space:]]*".*"@keystore/release_user="'${K8S_SECRET_RELEASE_KEYSTORE_USER}'"@g' -i export_presets.cfg
            godot --verbose --export "Android" "build/${platform}/${EXPORT_NAME}.release.apk"
            zip -r ${platform}.zip build/${platform}
            ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Android" FILES="${platform}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js
        fi        
    elif [[ $platform == "iOS" ]]
    then
        # Debug
        if [ ${EXPORT_MODE} == "debug" ]
        then        
            echo "✔ Exporting iOS Debug XCodeProj"
            godot --verbose --export-debug "iOS" "build/${platform}/${EXPORT_NAME}.debug.ipa"
            zip -r ${platform}.zip build/${platform}
            ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="iOS" FILES="${platform}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js
    
        # Release
        elif [ ${EXPORT_MODE} == "release" ]
        then
            echo "✔ Exporting iOS Release XCodeProj"
            godot --verbose --export "iOS" "build/${platform}/${EXPORT_NAME}.release.ipa"
            zip -r ${platform}.zip build/${platform}
            ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="iOS" FILES="${platform}.zip" ROOT_DIR="${WORKSPACE_PATH}/" node /upload_artifacts/index.js
        fi
    fi
done
