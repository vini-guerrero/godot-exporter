#!/usr/bin/env bash
set -e

echo -e "✔ Export Script Triggered Successfully."

# Install Export Dependencies
# sudo apt-get update
sudo apt-get install -y -qq locales apksigner
sudo sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo dpkg-reconfigure --frontend=noninteractive locales
sudo update-locale LANG=en_US.UTF-8
LANG=en_US.UTF-8 

# Environment Variables
GODOT_PATH="${GODOT_PATH:="/usr/local/bin"}"
GODOT_RELEASE="${GODOT_RELEASE:="stable"}"
LINK_GODOT="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip"
LINK_TEMPLATES="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz"
TRES_PATH="${HOME}/.config/godot/editor_settings-3.tres"

# Project Variables
EXPORT_PLATFORM=$1
EXPORT_MODE="${EXPORT_MODE:="debug"}"
PROJECT_NAME="${PROJECT_NAME:="game"}"
PROJECT_PATH="${PROJECT_PATH:="game"}"
PROJECT_REPO_PATH="${GITHUB_WORKSPACE}/${PROJECT_PATH}"
IOS_ICONS_PATH="${IOS_ICONS_PATH:="res:\/\/assets\/sprites\/icon\.png"}"

sudo mkdir -p -v /root/.local/share/godot/ .config .cache
sudo mkdir -p -v /root/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}

echo -e "✔ Setup Godot Editor And Export Templates." 

# Engine
wget -q ${LINK_GODOT}
unzip -qq Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip 
sudo mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64 ${GODOT_PATH}/godot

# Templates
wget -q ${LINK_TEMPLATES}
unzip -qq Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz 
sudo mv templates/* /root/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}

# Permissions
echo -e "✔ Godot Editor First Launch." 
sudo chmod +x ${GODOT_PATH}/godot && sudo ${GODOT_PATH}/godot -e -q
echo -e "✔ Godot Editor Launched."


if [[ "$EXPORT_PLATFORM" == "Android" ]]; then 
    # Signers Paths
    JARSIGNER_PATH=$(eval "which jarsigner")
    APKSIGNER_PATH=$(eval "which apksigner")
    echo -e "✔ Jarsigner Path: ${JARSIGNER_PATH} \n✔ ApkSigner Path: ${APKSIGNER_PATH}"
    # Generate Debug Keystore
    sudo keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore /usr/local/lib/android/debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999
    # Set Editor Settings For Android Export
    echo -e "✔ Preparing Android Project Export Setup."  
    sudo sed -i '/\[resource\]/a export\/android\/android_sdk_path = "/usr/local/lib/android/sdk"' ${TRES_PATH} \
    && sudo sed -i '/\[resource\]/a export\/android\/adb = "/usr/local/lib/android/sdk/platform-tools/adb"' ${TRES_PATH} \
    && sudo sed -i '/\[resource\]/a export\/android\/jarsigner = "'"${JARSIGNER_PATH}"'"' ${TRES_PATH} \
    && sudo sed -i '/\[resource\]/a export\/android\/apksigner = "'"${APKSIGNER_PATH}"'"' ${TRES_PATH} \
    && sudo sed -i '/\[resource\]/a export\/android\/debug_keystore = "/usr/local/lib/android/debug.keystore"' ${TRES_PATH} \
    && sudo sed -i '/\[resource\]/a export\/android\/debug_user = "androiddebugkey"' ${TRES_PATH} \
    && sudo sed -i '/\[resource\]/a export\/android\/debug_pass = "android"' ${TRES_PATH}
    # Prepare Release Mode
    if [ "$EXPORT_MODE" == "release" ]; then 
        echo ${K8S_SECRET_RELEASE_KEYSTORE_BASE64} | base64 --decode > /root/release.keystore 
        sudo sed 's@keystore/release[[:space:]]*=[[:space:]]*".*"@keystore/release = "/root/release.keystore"@g' -i ${PROJECT_REPO_PATH}/export_presets.cfg \
        && sudo sed 's@keystore/release_user[[:space:]]*=[[:space:]]*".*"@keystore/release_user="'${K8S_SECRET_RELEASE_KEYSTORE_USER}'"@g' -i ${PROJECT_REPO_PATH}/export_presets.cfg \
        && sudo sed 's@keystore/release_password[[:space:]]*=[[:space:]]*".*"@keystore/release_password="'${K8S_SECRET_RELEASE_KEYSTORE_PASSWORD}'"@g' -i ${PROJECT_REPO_PATH}/export_presets.cfg
    fi
    # Prepare Project Level Settings        
    sudo sed -i 's/keystore\/debug.*/keystore\/debug=""/g' ${PROJECT_PATH}/export_presets.cfg
    echo "✔ Android Project Export Setup Ready"
fi

if [[ "$EXPORT_PLATFORM" == "iOS" ]]; then 
    # Set Editor Settings For iOS Export
    sudo sed -i '/\[rendering\]/a vram_compression\/import_pvrtc=true' ${PROJECT_REPO_PATH}/project.godot \
    && sudo sed -i 's@required_icons/iphone_120x120[[:space:]]*=[[:space:]]*".*"@required_icons/iphone_120x120 = "'${IOS_ICONS_PATH}'"@g' ${PROJECT_REPO_PATH}/export_presets.cfg \
    && sudo sed -i 's@required_icons/ipad_76x76[[:space:]]*=[[:space:]]*".*"@required_icons/ipad_76x76 = "'${IOS_ICONS_PATH}'"@g' ${PROJECT_REPO_PATH}/export_presets.cfg \
    && sudo sed -i 's@required_icons/app_store_1024x1024[[:space:]]*=[[:space:]]*".*"@required_icons/app_store_1024x1024 = "'${IOS_ICONS_PATH}'"@g' ${PROJECT_REPO_PATH}/export_presets.cfg
    echo "✔ iOS Project Export Setup Ready"
fi


# Validate Editor Settings
EXPORT_SETTINGS="${PROJECT_REPO_PATH}/export_settings" 
mkdir -v -p EXPORT_SETTINGS
cp ${PROJECT_REPO_PATH}/export_presets.cfg EXPORT_SETTINGS
cp ${TRES_PATH} EXPORT_SETTINGS
zip -r export_settings.zip EXPORT_SETTINGS 

echo -e "✔ Export Path."
mkdir -v -p "${PROJECT_REPO_PATH}/build/${EXPORT_PLATFORM}" 


# Platform Export
GAME_EXTENSION=""

if [[ "${EXPORT_PLATFORM}" == "Linux" ]]; then 
    PLATFORM_EXPORT_NAME="Linux"
    GAME_EXTENSION=".x86_64"

elif [[ "${EXPORT_PLATFORM}" == "MacOS" ]]; then
    PLATFORM_EXPORT_NAME="Mac OSX"
    GAME_EXTENSION=".zip"
    
elif [[ "${EXPORT_PLATFORM}" == "Windows" ]]; then
    PLATFORM_EXPORT_NAME="Windows Desktop"
    GAME_EXTENSION=".exe"
    
elif [[ "${EXPORT_PLATFORM}" == "HTML5" ]]; then
    PLATFORM_EXPORT_NAME="HTML5"
    PROJECT_NAME="index"
    GAME_EXTENSION=".html"
    
elif [[ "${EXPORT_PLATFORM}" == "iOS" ]]; then
    PLATFORM_EXPORT_NAME="iOS"
    GAME_EXTENSION=".ipa"
    
elif [[ "${EXPORT_PLATFORM}" == "Android" ]]; then
    PLATFORM_EXPORT_NAME="Android"
    GAME_EXTENSION=".apk"
fi

EXPORT_NAME="${PROJECT_NAME}${GAME_EXTENSION}"
EXPORT_PATH=${PROJECT_REPO_PATH}/build/${EXPORT_PLATFORM}/${EXPORT_NAME}

echo -e "✔ Exporting ${EXPORT_PLATFORM} Version."
if [ "$EXPORT_MODE" == "debug" ]; then 
    sudo godot --verbose --path ${PROJECT_REPO_PATH} --export-debug "${PLATFORM_EXPORT_NAME}" "${EXPORT_PATH}"
elif [ "$EXPORT_MODE" == "release" ]; then 
    sudo godot --verbose --path ${PROJECT_REPO_PATH} --export "${PLATFORM_EXPORT_NAME}" "${EXPORT_PATH}"
fi

zip -r ${EXPORT_PLATFORM}.zip ${PROJECT_REPO_PATH}/build/${EXPORT_PLATFORM}
echo -e "✔ Exported Builds"