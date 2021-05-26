# Godot-Exporter
Godot Engine Automation Pipeline

## Automated Export Pipeline Supports
- Android
- Linux 
- MacOS
- Windows
- WebHTML5

## Action Environment Variables

- **GODOT_VERSION:** *"3.3.2" | string*
- **GODOT_RELEASE:** *"stable" | string*
- **EXPORT_NAME:** *"GameFileName" | string*
- **EXPORT_PATH:** *"game" | string*
- **EXPORT_RETENTION_DAYS:** *"15" | string*
- **EXPORT_ANDROID:** *"true" | string*
- **EXPORT_LINUX:** *"true" | string*
- **EXPORT_MACOS:** *"true" | string*
- **EXPORT_WINDOWS:** *"true" | string*
- **EXPORT_WEB:** *"true" | string*

## Docker Container Environment Variables

- **DEBIAN_FRONTEND:** *"noninteractive" | string*
- **ROOT_PATH:** *"/github/home" | string*

## Publishing Platform Integration

- **Itch.io:** *(Android|Linux|MacOS|Windows|Web)*
