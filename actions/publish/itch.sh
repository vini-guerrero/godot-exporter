#!/usr/bin/env bash
set -e

echo -e "✔ Publish Script Triggered Successfully."

sudo curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
sudo unzip butler.zip && sudo cp butler /usr/bin && sudo chmod 777 /usr/bin/butler

export BUTLER_API_KEY=$ITCH_CREDENTIALS
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
declare -a SUPPORTED_CHANNELS=("Linux" "MacOS" "Windows", "Android")

if [ "$2" == "Linux" ]; then CHANNEL=linux; fi
if [ "$2" == "MacOS" ]; then CHANNEL=mac; fi
if [ "$2" == "Windows" ]; then CHANNEL=win-final; fi
if [ "$2" == "Android" ]; then CHANNEL=android; fi

if [[ ${SUPPORTED_CHANNELS[@]} =~ "${CHANNEL}" ]]; then 
    echo -e "\n ✔ Exporting $1 To Channel ${CHANNEL} \n"
    echo "butler push \"$PACKAGE\" $ITCH_USER/$ITCH_GAME:$CHANNEL ${versionArgument}"
    butler push "$PACKAGE" $ITCH_USER/$ITCH_GAME:$CHANNEL ${versionArgument}  
fi
