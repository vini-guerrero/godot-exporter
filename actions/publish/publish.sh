#!/usr/bin/env bash
set -e

echo -e "✔ Publish Script Triggered Successfully."

sudo curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
sudo unzip butler.zip && sudo cp butler /usr/bin && sudo chmod 777 /usr/bin/butler

export BUTLER_API_KEY=$BUTLER_CREDENTIALS
versionArgument=""

if [ "$VERSION" != "" ]
then
    versionArgument="--userversion ${VERSION}"
elif [ "$VERSION_FILE" != "" ]
then
    versionArgument="--userversion-file ${VERSION_FILE}"
fi

PACKAGE=$1
CHANNEL=""

if [ "$2" == "Linux" ]; then CHANNEL=linux; fi
if [ "$2" == "MacOS" ]; then CHANNEL=mac; fi
if [ "$2" == "Windows" ]; then CHANNEL=windows; fi
if [ "$2" == "Android" ]; then CHANNEL=android; fi

echo "butler push \"$PACKAGE\" $ITCH_USER/$ITCH_GAME:$CHANNEL ${versionArgument}"
butler push "$PACKAGE" $ITCH_USER/$ITCH_GAME:$CHANNEL ${versionArgument}
