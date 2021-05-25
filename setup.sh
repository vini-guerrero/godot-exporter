#!/usr/bin/env bash

set -e
echo "✔ Environment Setup Script Triggered Successfully."

# apt-get update && apt-get install sudo -y && chmod +x setup.sh 
# /bin/bash

apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates git python python-openssl unzip wget zip curl openjdk-8-jdk apksigner nano
# locales-all
rm -rf /var/lib/apt/lists/*

GODOT_VERSION="3.3.2"
GODOT_DL_SUBDIR="3.3.2"
GODOT_RELEASE="stable"
ANDROID_HOME="/root/android-sdk"
EXPORT_NAME="game"

wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip
wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz

sudo mkdir -p -v ~/.cache && sudo mkdir -p -v ~/.config/godot
sudo mkdir -p -v ~/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}

# Engine
unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip && sudo mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64 /usr/local/bin/godot
# Templates
unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz && sudo mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}
# Clean
sudo rm -f Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip

echo "✔ Engine & Export Templates Successfully Installed."

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

# Godot Executable From Path
#!/usr/bin/godot
chmod +x /usr/local/bin/godot && godot -q

echo "✔ Godot Editor First Launch."

# Delete Default Editor Settings 
sed -i '/export\/android\/adb/d' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/export\/android\/android_sdk_path/d' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/export\/android\/jarsigner/d' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/export\/android\/apksigner/d' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/export\/android\/debug_keystore/d' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/export\/android\/debug_keystore_user/d' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/export\/android\/debug_keystore_pass/d' /root/.config/godot/editor_settings-3.tres
# Set New Editor Settings
sed -i '/\[resource\]/a export\/android\/adb = "/root/android-sdk/platform-tools/adb"' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/\[resource\]/a export\/android\/android_sdk_path = "/root/android-sdk"' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/\[resource\]/a export\/android\/jarsigner = "/usr/bin/jarsigner"' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/\[resource\]/a export\/android\/apksigner = "/usr/bin/apksigner"' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/\[resource\]/a export\/android\/debug_keystore = "/root/android-sdk/debug.keystore"' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/\[resource\]/a export\/android\/debug_user = "androiddebugkey"' /root/.config/godot/editor_settings-3.tres \
&& sed -i '/\[resource\]/a export\/android\/debug_pass = "android"' /root/.config/godot/editor_settings-3.tres

echo "✔ Exporting Android Project"

cat /root/.config/godot/editor_settings-3.tres
cd /game && mkdir -v -p build/android
godot --verbose --export-debug "Android" build/android/$EXPORT_NAME.debug.apk

echo "✔ Android Project Exported At"