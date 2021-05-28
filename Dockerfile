FROM ubuntu:20.04 AS exporter

LABEL author="Vinicius Guerrero"

ENV DEBIAN_FRONTEND=noninteractive

# ENV GODOT_VERSION=3.2.2
# ENV EXPORT_NAME=game
# ENV EXPORT_PATH=/game
# ENV ROOT_PATH=/root

# COPY setup.sh /src/setup.sh

COPY . .

RUN chmod +x ./src/setup.sh

RUN bash ./src/setup.sh

FROM node:12
COPY --from=exporter artifact.zip .
COPY upload_artifacts .
RUN npm install
ENTRYPOINT node index.js