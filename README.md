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

## Export Pipeline Platform Support

- Android
- iOS (XCode Project)
- Linux
- Mac OSX
- Windows Desktop
- HTML5
- UWP/Xbox **(Work-In-Progress)**
- Custom Engine Builds **(Work-In-Progress)**

## Publishing Platform Integration

- **Itch.io:** _(Android|Linux|MacOS|Windows|Web)_

## Action Environment Variables

- **GODOT_VERSION:** _"3.3.2" | string **(required)**_ 
- **PROJECT_NAME:** _"GameFileName" | string **(required)**_ 
- **PROJECT_PATH:** _"gameDirectory" | string **(required)**_ 
- **EXPORT_MODE:** _"debug/release" | string **(optional)**_
- **IOS_ICON_PATH:** _"iconPath" | string **(optional)**_
- **ITCH_GAME:** _"ItchIoGameName" | string **(required for publishing)**_
- **ITCH_USER:** _"ItchIoUserName" | string **(required for publishing)**_

## Action Environment Secrets

- **BUTLER_CREDENTIALS:** _"xxx" | string **(required for publishing)**_
- **K8S_SECRET_RELEASE_KEYSTORE_BASE64:** _"xxx" | string **(required in release mode)**_
- **K8S_SECRET_RELEASE_KEYSTORE_USER:** _"xxx" | string **(required in release mode)**_
- **K8S_SECRET_RELEASE_KEYSTORE_PASSWORD:** _"xxx" | string **(required in release mode)**_

## Environment Example

#### Create action file:

repository_name/.github/workflows/example.yml

```yml
name: "Godot Export Example"
on: [push, workflow_dispatch]

env:
  GODOT_VERSION: 3.3.2
  PROJECT_NAME: godot_exporter
  PROJECT_PATH: game
  EXPORT_MODE: release # If not defined, defaults to debug
  # Required if in release mode
  # K8S_SECRET_RELEASE_KEYSTORE_BASE64: ${{ secrets.K8S_SECRET_RELEASE_KEYSTORE_BASE64 }}
  # K8S_SECRET_RELEASE_KEYSTORE_USER: ${{ secrets.K8S_SECRET_RELEASE_KEYSTORE_USER }}
  # K8S_SECRET_RELEASE_KEYSTORE_PASSWORD: ${{ secrets.K8S_SECRET_RELEASE_KEYSTORE_PASSWORD }}
  IOS_ICON_PATH: "icon_path"
  ITCH_GAME: itchio-game
  ITCH_USER: itchio-user

jobs:
  export:
    name: "Godot Project Export"
    runs-on: ubuntu-latest
    strategy:
      matrix:
        platform: [iOS, Android, Linux, MacOS, Windows, HTML5]
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      # Export Godot Project
      - name: Export ${{ matrix.platform }} Version
        id: export
        uses: vini-guerrero/godot-exporter/actions/export@master
        with:
          platform: ${{ matrix.platform }}

      # Publish Platforms
      - name: Publish Platforms
        uses: vini-guerrero/godot-exporter/actions/publish@master
        with:
          platform: "Itch"
          channel: ${{ matrix.platform }}
          project_path: ${{ steps.export.outputs.artifact-path }}

      # Upload Artifact
      - uses: actions/upload-artifact@v1
        with:
          name: ${{ matrix.platform }}
          path: ${{ steps.export.outputs.artifact-path }}
```
