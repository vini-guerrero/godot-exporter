#!/usr/bin/env bash
set -e
echo "\n\n ✔ Install Script Triggered Successfully. \n\n "


ANDROID_HOME="/root/android-sdk"
USE_BUTLER="false"


# Download and Install Packages
apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates curl git python python-openssl unzip wget zip openjdk-8-jdk apksigner dirmngr apt-transport-https lsb-release # graphicsmagick
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt -y install nodejs 
# locales-all
rm -rf /var/lib/apt/lists/*


# Android SDK Export Dependencies
sudo mkdir -p -v /root/android-sdk-installer/cmdline-tools && cd /root/android-sdk-installer/cmdline-tools
wget "https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"
# curl -fsSLO "https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"
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


# Upload Artifact Setup Requirements
echo "✔ Preparing Artifact Uploader."
mv /src/upload_artifacts /upload_artifacts
cd /upload_artifacts
npm install
echo "✔ Artifact Uploader Installed."


# Itch.io - Butler Integration
if [[ ${USE_BUTLER} == "true" ]]
then  
  curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default \
  && unzip butler.zip \
  && cp butler /usr/bin \
  && chmod +x /usr/bin/butler  
fi
