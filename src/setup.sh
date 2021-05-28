#!/usr/bin/env bash
set -e
echo "\n\n ✔ Environment Setup Script Triggered Successfully. \n\n "

# apt-get update && apt-get install sudo -y && chmod +x setup.sh 
# /bin/bash

# Environment Variables
ANDROID_HOME="/root/android-sdk"
TRES_PATH=$ROOT_PATH/.config/godot/editor_settings-3.tres

# Expected Env Format - EXPORT_PLATFORMS="Android|Linux|MacOS"
IFS="|" read -a GODOT_EXPORT_PLATFORMS <<< $EXPORT_PLATFORMS
echo "✔ Export Platforms: ${GODOT_EXPORT_PLATFORMS[@]} - Total ${#GODOT_EXPORT_PLATFORMS[@]}."

# Download and Install Packages
apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates git python python-openssl unzip wget zip curl openjdk-8-jdk apksigner nano curl dirmngr apt-transport-https lsb-release ca-certificates
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt -y install nodejs 
# locales-all

rm -rf /var/lib/apt/lists/*
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

echo "✔ Engine & Export Templates Successfully Installed."

# Android Export
if [ "${GODOT_EXPORT_PLATFORMS[@]}" == "Android" ]
then 
    # Android SDK
    sudo mkdir -p -v /root/android-sdk-installer/cmdline-tools && cd /root/android-sdk-installer/cmdline-tools
    curl -fsSLO "https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"
    unzip -q commandlinetools-linux-*.zip
    rm commandlinetools-linux-*.zip
    mv cmdline-tools latest
    mkdir -p -v /root/.android && echo "count=0" > /root/.android/repositories.cfg
    yes | /root/android-sdk-installer/cmdline-tools/latest/bin/sdkmanager --licenses
    yes | /root/android-sdk-installer/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "build-tools;30.0.3" "platforms;android-29" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;21.4.7075529"
    cd /root && rm -rf /root/android-sdk-installer    
    echo "✔ Android SDK Successfully Installed."
    # Key Generation
    keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore /root/android-sdk/debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 
    ls /root/android-sdk/debug.keystore
    echo "✔ Debug Key Generated."
fi

# Godot Executable From Path
#!/usr/bin/godot
chmod +x /usr/local/bin/godot && godot -e -q

echo "✔ Godot Editor First Launch."
cat ${TRES_PATH}
# The file is located in src directory
cd .. && cd ${EXPORT_PATH}
mkdir -v -p build/Android 
mkdir -v -p build/Windows
mkdir -v -p build/Linux
mkdir -v -p build/MacOS
mkdir -v -p build/Web

# Android Export
if [ "${GODOT_EXPORT_PLATFORMS[@]}" == "Android" ]
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

    # Debug
    if [ "${ANDROID_RELEASE}" == "false" ]
    then        
        godot --verbose --export-debug "Android" build/Android/${EXPORT_NAME}.debug.apk
    
    # Release
    elif [ "${ANDROID_RELEASE}" == "true" ]
    then
        echo ${K8S_SECRET_RELEASE_KEYSTORE_BASE64} | base64 --decode > /root/release.keystore 
        sed 's@keystore/release[[:space:]]*=[[:space:]]*".*"@keystore/release = "/root/release.keystore"@g' -i export_presets.cfg 
        sed 's@keystore/release_password[[:space:]]*=[[:space:]]*".*"@keystore/release_password="'${K8S_SECRET_RELEASE_KEYSTORE_PASSWORD}'"@g' -i export_presets.cfg
        sed 's@keystore/release_user[[:space:]]*=[[:space:]]*".*"@keystore/release_user="'${K8S_SECRET_RELEASE_KEYSTORE_USER}'"@g' -i export_presets.cfg
        godot --verbose --export "Android" build/Android/${EXPORT_NAME}.release.apk
    fi        

else
    # PC Platforms
    if [ "${GODOT_EXPORT_PLATFORMS[@]}" == "Linux" ]
    then
        godot --verbose --export "${EXPORT_PLATFORM}" build/Linux/${EXPORT_NAME}.x86_64
    elif [ "${GODOT_EXPORT_PLATFORMS[@]}" == "MacOS" ]
    then
        godot --verbose --export "MacOS" build/MacOS/${EXPORT_NAME}.zip
    elif [ "${GODOT_EXPORT_PLATFORMS[@]}" == "Windows" ]
    then
        godot --verbose --export "Windows" build/Windows/${EXPORT_NAME}.exe
    elif [ "${GODOT_EXPORT_PLATFORMS[@]}" == "Web" ]
    then
        godot --verbose --export "Web" build/Web/${EXPORT_NAME}/index.html
    fi
fi


# Prepare Artifact For Upload
zip -r artifact.zip build
mv artifact.zip ${GITHUB_WORKSPACE}/artifact.zip
echo "✔ Export Artifact Available at ${GITHUB_WORKSPACE}/artifact.zip"
cd ${GITHUB_WORKSPACE}/upload_artifacts
npm install
ACTIONS_RUNTIME_TOKEN=$ACTIONS_RUNTIME_TOKEN node index.js
