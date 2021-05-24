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


GODOT_VERSION="3.3.1"
GODOT_DL_SUBDIR="3.3.1"
GODOT_RELEASE="stable"
ANDROID_HOME="/root/android-sdk"

# Download and install Godot Engine (headless) and export templates
wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip \
&& wget https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz \
&& mkdir -v ~/.cache \
&& mkdir -p -v ~/.config/godot \
&& mkdir -p -v ~/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE} \
&& unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip \
&& mv Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64 /usr/local/bin/godot \
&& unzip Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz \
&& mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.${GODOT_RELEASE} \
&& rm -f Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip 


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
&& rm -rf /root/android-sdk-installer \

# echo 'export ANDROID_HOME=/root/android-sdk' >> ~/.bashrc \
&& find / -name jre \
&& ls \
&& pwd


# Create debug keystore
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 \
&& mv debug.keystore /root/android-sdk/debug.keystore


echo -e Godot Engine Export Settings - Godot Version_${GODOT_VERSION} Subversion_${GODOT_DL_SUBDIR} Release_${GODOT_RELEASE}
echo -e https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip
echo -e https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz

printenv
