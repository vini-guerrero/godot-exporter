FROM ubuntu:20.04

LABEL author="Vinicius Guerrero"

# ENV DEBIAN_FRONTEND=noninteractive
# ENV GODOT_VERSION=3.2.2
# ENV EXPORT_NAME=game
# ENV EXPORT_PATH=/game
# ENV ROOT_PATH=/root

COPY setup.sh /src/setup.sh

RUN chmod +x /src/setup.sh

ENTRYPOINT ["sh", "./src/setup.sh"]
