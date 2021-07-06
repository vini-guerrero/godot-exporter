# Godot-Exporter

Godot Engine Automation Pipeline

[![Alphtech Studio Discord Server](https://badgen.net/discord/members/PrsJvMeVfp)](https://discord.gg/PrsJvMeVfp)

[![GitHub Stars](https://img.shields.io/github/stars/vini-guerrero/godot-exporter.svg?style=social&label=Stars&maxAge=2592000)](https://github.com/vini-guerrero/godot-exporter)
[![GitHub Contributors](https://img.shields.io/github/contributors/vini-guerrero/godot-exporter.svg?style=social&label=Contributors&maxAge=2592000)](https://github.com/vini-guerrero/godot-exporter)

## CI/CD Artifacts Example

![CI/CD](/screenshots/Artifacts.png?raw=true "Artifacts")

## Automated Export Pipeline Supports

- Android
- iOS (XCode Project)
- Linux
- Mac OSX
- Windows Desktop
- HTML5

## Action Environment Variables

- **GODOT_VERSION:** _"3.3.2" | string_
- **GODOT_RELEASE:** _"stable" | string_
- **EXPORT_NAME:** _"GameFileName" | string_
- **EXPORT_PATH:** _"gameDirectory" | string_
- **EXPORT_PLATFORMS:** _"Android|iOS|Linux|Mac OSX|Windows Desktop|HTML5" | string_
- **EXPORT_MODE:** _"release or debug" | string_
- **PUBLISH_ITCH_IO:** _"true or false" | string_

## Publishing Platform Integration

- **Itch.io:** _(Android|iOS|Linux|MacOS|Windows|Web)_ **- Work-In-Progress**

## Environment Example

#### Create action file: 
repository_name/.github/workflows/example.yml

```yml
name: "Example Dispatch Trigger Export"
on:
  workflow_dispatch:
    inputs:
      export_platforms:
        description: "Export Platforms"
        required: true
        default: "Android|iOS|Linux|Mac OSX|Windows Desktop|HTML5"

env:
  GODOT_VERSION: 3.3.2
  GODOT_RELEASE: stable
  EXPORT_NAME: game
  EXPORT_PATH: gameDir
  EXPORT_PLATFORMS: ${{ github.event.inputs.export_platforms }}
  EXPORT_MODE: "debug"
  PUBLISH_ITCH_IO: "false"
  K8S_SECRET_RELEASE_KEYSTORE_BASE64: ${{ secrets.K8S_SECRET_RELEASE_KEYSTORE_BASE64 }}
  K8S_SECRET_RELEASE_KEYSTORE_USER: ${{ secrets.K8S_SECRET_RELEASE_KEYSTORE_USER }}
  K8S_SECRET_RELEASE_KEYSTORE_PASSWORD: ${{ secrets.K8S_SECRET_RELEASE_KEYSTORE_PASSWORD }}

jobs:
  export:
    name: "Godot Project Export"
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Export Game
        uses: vini-guerrero/godot-exporter@master
```
