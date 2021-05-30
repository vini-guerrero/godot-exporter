#!/usr/bin/env bash
set -e
echo "\n\n ✔ Environment Setup Script Triggered Successfully. \n\n "

# apt-get update && apt-get install sudo -y && chmod +x setup.sh 
# /bin/bash


# Environment Variables
ROOT_PATH="${ROOT_PATH:="/github/home"}"
ANDROID_SDK_VERSION="6858069"
ANDROID_HOME="/root/android-sdk"
TRES_PATH=${ROOT_PATH}/.config/godot/editor_settings-3.tres
# Expected Env Format - EXPORT_PLATFORMS="Android|Linux|MacOS"
IFS="|" read -a GODOT_EXPORT_PLATFORMS <<< $EXPORT_PLATFORMS
echo "✔ Export Platforms: ${GODOT_EXPORT_PLATFORMS[@]} - Total ${#GODOT_EXPORT_PLATFORMS[@]}."


# Download and Install Packages
# apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates git python python-openssl unzip wget zip curl openjdk-8-jdk apksigner nano curl dirmngr apt-transport-https lsb-release ca-certificates graphicsmagick
# curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# sudo apt -y install nodejs 
# locales-all


#rm -rf /var/lib/apt/lists/*
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
#!/usr/bin/godot
chmod +x /usr/local/bin/godot && godot -e -q


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
    echo "✔ iOS Project Export Setup Ready"
fi



# Upload Artifact Setup Requirements
mv /src/upload_artifacts /upload_artifacts
cd /upload_artifacts
npm install


# Validate Editor Settings
cat ${TRES_PATH} && cd /github/workspace && cd ${EXPORT_PATH} && ls


# Export Platforms  
for platform in "${GODOT_EXPORT_PLATFORMS[@]}"
do
    echo "✔ Exporting ${platform} Platform"
    mkdir -v -p "build/${platform}"
    
    if [[ $platform == "Linux" ]]
    then                
        godot --verbose --export "${platform}" "build/${platform}/${EXPORT_NAME}.x86_64"
        zip -r "${platform}.zip" build/${platform}
        ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Linux" FILES="${platform}.zip" ROOT_DIR="/github/workspace/" node /upload_artifacts/index.js
    elif [[ $platform == "Mac OSX" ]]
    then
        godot --verbose --export "${platform}" "build/${platform}/${EXPORT_NAME}.zip"
        zip -r "${platform}.zip" "build/${platform}"
        ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Mac OSX" FILES="${platform}.zip" ROOT_DIR="/github/workspace/" node /upload_artifacts/index.js
    elif [[ $platform == "Windows Desktop" ]]
    then
        godot --verbose --export "${platform}" "build/${platform}/${EXPORT_NAME}.exe"
        zip -r "${platform}.zip" "build/${platform}"
        ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Windows Desktop" FILES="${platform}.zip" ROOT_DIR="/github/workspace/" node /upload_artifacts/index.js
    elif [[ $platform == "HTML5" ]]
    then
        godot --verbose --export "${platform}" "build/${platform}/index.html"
        zip -r "${platform}.zip" build/${platform}
        ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="HTML5" FILES="${platform}.zip" ROOT_DIR="/github/workspace/" node /upload_artifacts/index.js
    elif [[ $platform == "Android" ]]
    then
        # Debug
        if [ ${EXPORT_MODE} == "debug" ]
        then        
            godot --verbose --export-debug "Android" "build/${platform}/${EXPORT_NAME}.debug.apk"
            zip -r ${platform}.zip build/${platform}
            ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Android" FILES="${platform}.zip" ROOT_DIR="/github/workspace/" node /upload_artifacts/index.js

        # Release
        elif [ ${EXPORT_MODE} == "release" ]
        then
            echo ${K8S_SECRET_RELEASE_KEYSTORE_BASE64} | base64 --decode > /root/release.keystore 
            sed 's@keystore/release[[:space:]]*=[[:space:]]*".*"@keystore/release = "/root/release.keystore"@g' -i export_presets.cfg 
            sed 's@keystore/release_password[[:space:]]*=[[:space:]]*".*"@keystore/release_password="'${K8S_SECRET_RELEASE_KEYSTORE_PASSWORD}'"@g' -i export_presets.cfg
            sed 's@keystore/release_user[[:space:]]*=[[:space:]]*".*"@keystore/release_user="'${K8S_SECRET_RELEASE_KEYSTORE_USER}'"@g' -i export_presets.cfg
            godot --verbose --export "Android" "build/${platform}/${EXPORT_NAME}.release.apk"
            zip -r ${platform}.zip build/${platform}
            ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="Android" FILES="${platform}.zip" ROOT_DIR="/github/workspace/" node /upload_artifacts/index.js
        fi        
    elif [[ $platform == "iOS" ]]
    then
        # Debug
        if [ ${EXPORT_MODE} == "debug" ]
        then        
            echo "✔ Exporting iOS Debug XCodeProj"
            godot --verbose --export-debug "iOS" "build/${platform}/${EXPORT_NAME}.debug.ipa"
            zip -r ${platform}.zip build/${platform}
            ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="iOS" FILES="${platform}.zip" ROOT_DIR="/github/workspace/" node /upload_artifacts/index.js
    
        # Release
        elif [ ${EXPORT_MODE} == "release" ]
        then
            echo "✔ Exporting iOS Release XCodeProj"
            godot --verbose --export "iOS" "build/${platform}/${EXPORT_NAME}.release.ipa"
            zip -r ${platform}.zip build/${platform}
            ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN NAME="iOS" FILES="${platform}.zip" ROOT_DIR="/github/workspace/" node /upload_artifacts/index.js
        fi
    fi
done


