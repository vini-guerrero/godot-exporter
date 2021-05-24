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

echo -e Godot Engine Export Settings - Godot Version_${GODOT_VERSION} Subversion_${GODOT_DL_SUBDIR} Release_${GODOT_RELEASE}
echo -e https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_linux_headless.64.zip
echo -e https://downloads.tuxfamily.org/godotengine/${GODOT_DL_SUBDIR}/Godot_v${GODOT_VERSION}-${GODOT_RELEASE}_export_templates.tpz

printenv