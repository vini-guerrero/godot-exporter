#!/usr/bin/env bash
set -e

echo -e "✔ Export Script Triggered Successfully."

# Install Export Dependencies
# sudo apt-get update
sudo apt-get install -y -qq apksigner locales
sudo sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo dpkg-reconfigure --frontend=noninteractive locales
sudo update-locale LANG=en_US.UTF-8
LANG=en_US.UTF-8 

# Environment Variables
EXPORT_PLATFORM=$1
GODOT_PATH="${GODOT_PATH:="/usr/local/bin"}"
GODOT_RELEASE="${GODOT_RELEASE:="stable"}"
EXPORT_PATH="${EXPORT_PATH:="game"}"
TRES_PATH="${HOME}/.config/godot/editor_settings-3.tres"
LINK_GODOT="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip"
LINK_TEMPLATES="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz"

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
sudo chmod +x /usr/local/
sudo chmod +x ${ANDROID_HOME}
sudo chmod +x ${EXPORT_PATH}
sudo chmod +x ${GODOT_PATH}/godot && sudo ${GODOT_PATH}/godot -e -q
echo -e "✔ Godot Editor Launched."

if [[ "$EXPORT_PLATFORM" == "Android" ]]
then     
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
fi

# Validate Editor Settings
sudo cat ${TRES_PATH} 
echo -e "✔ Export Path."
cd ${EXPORT_PATH} && mkdir -v -p "build/${EXPORT_PLATFORM}"

if [[ "${EXPORT_PLATFORM}" == "Linux" ]]
then 
    PLATFORM_EXPORT_NAME="Linux"
    EXPORT_NAME="game.x86_64"
elif [[ "${EXPORT_PLATFORM}" == "MacOS" ]]
then
    PLATFORM_EXPORT_NAME="Mac OSX"
    EXPORT_NAME="game.zip"
elif [[ "${EXPORT_PLATFORM}" == "Windows" ]]
then
    PLATFORM_EXPORT_NAME="Windows Desktop"
    EXPORT_NAME="game.exe"
elif [[ "${EXPORT_PLATFORM}" == "iOS" ]]
then
    PLATFORM_EXPORT_NAME="iOS"
    EXPORT_NAME="game.debug.ipa"
elif [[ "${EXPORT_PLATFORM}" == "Android" ]]
then
    PLATFORM_EXPORT_NAME="Android"
    EXPORT_NAME="game.debug.apk"
fi

echo -e "✔ Exporting ${EXPORT_PLATFORM} Version."
sudo godot --verbose --export-debug "${PLATFORM_EXPORT_NAME}" "build/${EXPORT_PLATFORM}/${EXPORT_NAME}"
zip -r ${EXPORT_PLATFORM}.zip build/${EXPORT_PLATFORM}

echo -e "✔ Exported Builds"
pwd && ls -l
