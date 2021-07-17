# Godot-Exporter

Godot Engine CI/CD Automation Pipeline 
For <a href="https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions" target="_blank">Public and Private</a> Repositories

[![](https://img.shields.io/badge/GODOT-%23FFFFFF.svg?style=for-the-badge&logo=godot-engine)](https://github.com/vini-guerrero/godot-exporter)
[![](https://img.shields.io/badge/githubactions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/vini-guerrero/godot-exporter)
[![](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://github.com/vini-guerrero/godot-exporter)
[![](https://img.shields.io/badge/javascript-%23323330.svg?style=for-the-badge&logo=javascript&logoColor=%23F7DF1E)](https://github.com/vini-guerrero/godot-exporter)

[![GitHub Stars](https://img.shields.io/github/stars/vini-guerrero/godot-exporter.svg?style=social&label=Stars)](https://github.com/vini-guerrero/godot-exporter)
[![GitHub Contributors](https://img.shields.io/github/contributors/vini-guerrero/godot-exporter.svg?style=social&label=Contributors&maxAge=2592000)](https://github.com/vini-guerrero/godot-exporter)
[![](https://img.shields.io/github/license/vini-guerrero/godot-exporter?style=plastic)](https://github.com/vini-guerrero/godot-exporter)
[![](https://img.shields.io/badge/PRs-welcome-brightgreen)](https://github.com/vini-guerrero/godot-exporter)
[![Alphtech Studio Discord Server](https://badgen.net/discord/members/PrsJvMeVfp)](https://discord.gg/PrsJvMeVfp)

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
