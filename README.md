# Godot-Exporter

Godot Engine Automation Pipeline

## Automated Export Pipeline Supports

- Android
- Linux
- MacOS
- Windows
- WebHTML5

## Action Environment Variables

- **GODOT_VERSION:** _"3.3.2" | string_
- **GODOT_RELEASE:** _"stable" | string_
- **EXPORT_NAME:** _"GameFileName" | string_
- **EXPORT_PATH:** _"game" | string_
- **EXPORT_PLATFORMS:** _"Android|Linux|Mac OSX|Windows Desktop|HTML5" | string_
- **EXPORT_MODE:** _"release or debug" | string_
- **PUBLISH_ITCH_IO:** _"true or false" | string_

## Publishing Platform Integration

- **Itch.io:** _(Android|Linux|MacOS|Windows|Web)_

## Environment Example

```
env:
  GODOT_VERSION: 3.3.2
  GODOT_RELEASE: stable
  EXPORT_NAME: export
  EXPORT_PATH: game
  EXPORT_PLATFORMS: Android|Linux|Mac OSX|Windows Desktop|HTML5
  EXPORT_MODE: "release"
  PUBLISH_ITCH_IO: false
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
      - name: Export
        uses: ./
```