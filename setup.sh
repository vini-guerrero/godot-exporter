#!/usr/bin/env bash

set -e
echo "✔ Setup script triggered successfully."

# Install development and other tools
apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    python \
    python-openssl \
    unzip \
    wget \
    zip \
    curl \
    openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*


GODOT_VERSION="3.3.2"
GODOT_DL_SUBDIR="3.3.2"
GODOT_RELEASE="stable"
EXPORT_NAME="test"
REPO_ROOT=$PWD
ANDROID_HOME="/root/android-sdk"
# PLATFORM_TOOLS = $ANDROID_HOME/platform-tools/
PATH=$PATH:$ANDROID_HOME/tools
PATH=$PATH:$ANDROID_HOME/platform-tools

# Download and install Godot Engine (headless) and export templates
wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip \
&& wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz \
&& pwd \
&& ls \
&& sudo mkdir -p -v ~/.cache \
&& sudo mkdir -p -v ~/.config/godot \
&& sudo mkdir -p -v ~/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE} \
&& unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip \
&& sudo mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64 /usr/local/bin/godot \
&& unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz \
&& sudo mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE} \
&& sudo rm -f Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip 

# Download and install Android SDK, tools, accept licenses
mkdir -p -v /root/android-sdk-installer/cmdline-tools \
&& cd /root/android-sdk-installer/cmdline-tools \
&& curl -fsSLO "https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip" \
&& unzip -q commandlinetools-linux-*.zip \
&& rm commandlinetools-linux-*.zip \
&& mv cmdline-tools latest \
&& mkdir -p -v /root/.android \
&& echo "count=0" > /root/.android/repositories.cfg \
&& yes | /root/android-sdk-installer/cmdline-tools/latest/bin/sdkmanager --licenses \
&& yes | /root/android-sdk-installer/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "build-tools;30.0.3" "platforms;android-29" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;21.4.7075529" \
&& cd /root/ \
&& rm -rf /root/android-sdk-installer \


# Create debug keystore
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore /root/android-sdk/debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 
ls /root/android-sdk/debug.keystore

# Initialize Godot so it creates editor_settings-3.tres file, then add android export section, since it is missing at first
chmod +x /usr/local/bin/godot \
&& sudo apt install $(check-language-support) \
&& sudo dpkg-reconfigure locales

sudo mkdir -v -p ~/.local/share/godot/templates \
&& sudo mv -p /root/.local/share/godot/templates/${GODOT_VERSION}.stable ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
&& sudo mkdir -v -p ~/.config/godot/ \
&& sudo cp /root/.config/godot/editor_settings-3.tres ~/.config/godot/editor_settings-3.tres \


echo 'export/android/adb = "~/usr/local/lib/android/sdk/platform-tools/adb/"' >> ~/.config/godot/editor_settings-3.tres
echo 'export/android/jarsigner = "~/usr/local/lib/android/sdkbuild-tools/jarsigner/"' >> ~/.config/godot/editor_settings-3.tres
# echo 'android/apksigner = "/root/android-sdk/build-tools/apksigner"' >> ~/.config/godot/editor_settings-3.tres
echo 'export/android/debug_keystore = "~/root/android-sdk/debug.keystore"' >> ~/.config/godot/editor_settings-3.tres
echo 'export/android/debug_keystore_user = "androiddebugkey"' >> ~/.config/godot/editor_settings-3.tres
echo 'export/android/debug_keystore_pass = "android"' >> ~/.config/godot/editor_settings-3.tres
echo 'export/android/force_system_user = false' >> ~/.config/godot/editor_settings-3.tres
echo 'export/android/timestamping_authority_url = ""' >> ~/.config/godot/editor_settings-3.tres
echo 'export/android/shutdown_adb_on_exit = true' >> ~/.config/godot/editor_settings-3.tres

echo -e Godot Editor .tres File Settings
cat ~/.config/godot/editor_settings-3.tres
cd /usr/local/lib/android/sdk/platform-tools
pwd
ls

printenv

#!/usr/bin/godot
# godot -e -q
cd $REPO_ROOT/game
mkdir -v -p $REPO_ROOT/build/android
godot --verbose --export-debug "Android" $REPO_ROOT/build/android/$EXPORT_NAME.debug.apk
cd $REPO_ROOT/build/android
ls
pwd

echo -e Godot Engine Export Settings - Godot Version_${GODOT_VERSION} Subversion_${GODOT_DL_SUBDIR} Release_${GODOT_RELEASE}
echo -e https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip
echo -e https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz


