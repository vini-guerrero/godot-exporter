#!/usr/bin/env bash

set -e
echo "\n\n ✔ Environment Setup Script Triggered Successfully. \n\n "

# apt-get update && apt-get install sudo -y && chmod +x setup.sh 
# /bin/bash

apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates git python python-openssl unzip wget zip curl openjdk-8-jdk apksigner nano
# locales-all
rm -rf /var/lib/apt/lists/*

# Environment Variables
if [-z "$ROOT_PATH" ]:
then
    ROOT_PATH="/root"
fi
GODOT_VERSION="3.3.2"
GODOT_DL_SUBDIR="3.3.2"
GODOT_RELEASE="stable"
ANDROID_HOME=${ROOT_PATH}/android-sdk
ADB_PATH=${ROOT_PATH}/android-sdk/platform-tools/adb
DEBUG_KEYSTORE=${ANDROID_HOME}/debug.keystore
TRES_PATH=${ROOT_PATH}/.config/godot/editor_settings-3.tres
EXPORT_NAME="game"
PROJECT_PATH="/game"

echo "\n\n ✔ Environment Variables Set. \n\n"
echo ${GODOT_VERSION} ${GODOT_DL_SUBDIR} ${GODOT_RELEASE}
echo ${ROOT_PATH} ${ANDROID_HOME} ${ADB_PATH} 
echo ${DEBUG_KEYSTORE} ${EXPORT_NAME} ${TRES_PATH}
echo "\n\n"


wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip
wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz

sudo mkdir -p -v ${ROOT_PATH}/.cache && sudo mkdir -p -v ~/.config/godot
sudo mkdir -p -v ${ROOT_PATH}/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}

# Engine
unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip && sudo mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64 /usr/local/bin/godot
# Templates
unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz && sudo mv templates/* ${ROOT_PATH}/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}
# Clean
sudo rm -f Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip

echo "\n\n ✔ Engine & Export Templates Successfully Installed. \n\n"

# Android SDK
sudo mkdir -p -v ${ROOT_PATH}/android-sdk-installer/cmdline-tools && cd ${ROOT_PATH}/android-sdk-installer/cmdline-tools
curl -fsSLO "https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"
unzip -q commandlinetools-linux-*.zip
rm commandlinetools-linux-*.zip
mv cmdline-tools latest
mkdir -p -v ${ROOT_PATH}/.android && echo "count=0" > ${ROOT_PATH}/.android/repositories.cfg
yes | ${ROOT_PATH}/android-sdk-installer/cmdline-tools/latest/bin/sdkmanager --licenses
yes | ${ROOT_PATH}/android-sdk-installer/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "build-tools;30.0.3" "platforms;android-29" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;21.4.7075529"
cd /root && rm -rf ${ROOT_PATH}/android-sdk-installer

echo "\n\n ✔ Android SDK Successfully Installed. \n\n"

# Key Generation
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore /root/android-sdk/debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 
ls /root/android-sdk/debug.keystore

echo "\n\n ✔ Debug Key Generated. \n\n"

# Godot Executable From Path
#!/usr/bin/godot
chmod +x /usr/local/bin/godot && godot -q

echo "\n\n ✔ Godot Editor First Launch. \n\n"

# Delete Default Editor Settings 
sed -i '/export\/android\/adb/d' ${TRES_PATH} \
&& sed -i '/export\/android\/android_sdk_path/d' ${TRES_PATH} \
&& sed -i '/export\/android\/jarsigner/d' ${TRES_PATH} \
&& sed -i '/export\/android\/apksigner/d' ${TRES_PATH} \
&& sed -i '/export\/android\/debug_keystore/d' ${TRES_PATH} \
&& sed -i '/export\/android\/debug_keystore_user/d' ${TRES_PATH} \
&& sed -i '/export\/android\/debug_keystore_pass/d' ${TRES_PATH}

# Set New Editor Settings
sed -i '/\[resource\]/a export\/android\/adb = '"${ADB_PATH}" ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/android_sdk_path = '"${ANDROID_HOME}" ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/jarsigner = "/usr/bin/jarsigner"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/apksigner = "/usr/bin/apksigner"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/debug_keystore = '"${DEBUG_KEYSTORE}" ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/debug_user = "androiddebugkey"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/debug_pass = "android"' ${TRES_PATH}

echo "\n\n ✔ Exporting Android Project \n\n"

cat ${TRES_PATH}
cd ${PROJECT_PATH} && mkdir -v -p build/android
godot --verbose --export-debug "Android" build/android/$EXPORT_NAME.debug.apk

echo "\n\n ✔ Android Project Exported At /game/build/android \n\n"

