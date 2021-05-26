#!/usr/bin/env bash

set -e
echo "\n\n ✔ Environment Setup Script Triggered Successfully. \n\n "

# apt-get update && apt-get install sudo -y && chmod +x setup.sh 
# /bin/bash

# Environment Variables
ANDROID_HOME="/root/android-sdk"
TRES_PATH=$ROOT_PATH/.config/godot/editor_settings-3.tres
# env:
    # GODOT_VERSION: 3.2.2
    # GODOT_RELEASE: stable
    # EXPORT_NAME: game
    # ROOT_PATH: /root
    # PROJECT_PATH: /game

# Godot Sub Directory
GODOT_DL_SUBDIR=$GODOT_VERSION

# Download and Install Packages
apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates git python python-openssl unzip wget zip curl openjdk-8-jdk apksigner nano
# locales-all
rm -rf /var/lib/apt/lists/*

# Download & Setup
wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip
wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz
sudo mkdir -p -v $ROOT_PATH/.cache && sudo mkdir -p -v ~/.config/godot
sudo mkdir -p -v $ROOT_PATH/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}

# Engine
unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip && sudo mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64 /usr/local/bin/godot
# Templates
unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz && sudo mv templates/* $ROOT_PATH/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE}
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
# Set New Editor Settings
sed -i '/\[resource\]/a export\/android\/android_sdk_path = "/root/android-sdk"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/adb = "/root/android-sdk/platform-tools/adb"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/jarsigner = "/usr/bin/jarsigner"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/apksigner = "/usr/bin/apksigner"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/debug_keystore = "/root/android-sdk/debug.keystore"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/debug_user = "androiddebugkey"' ${TRES_PATH} \
&& sed -i '/\[resource\]/a export\/android\/debug_pass = "android"' ${TRES_PATH}

cat ${TRES_PATH}
cd ${PROJECT_PATH} && mkdir -v -p build/android
# godot --verbose --export-debug "Android" build/android/$EXPORT_NAME.debug.apk

echo "✔ Android Project Export Setup Ready"