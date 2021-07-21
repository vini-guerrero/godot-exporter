## Legacy Action Environment Example

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
        default: "Linux|Android|Mac OSX|Windows Desktop|HTML5"
        
env:
  GODOT_VERSION: 3.3.2
  GODOT_RELEASE: stable
  EXPORT_NAME: game
  EXPORT_PATH: gameDir
  EXPORT_PLATFORMS: ${{ github.event.inputs.export_platforms }}
  EXPORT_MODE: debug
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
      - name: Export Master
        uses: vini-guerrero/godot-exporter/actions/legacy@dev
```
