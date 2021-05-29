FROM ubuntu:20.04

LABEL author="Vinicius Guerrero"

ENV DEBIAN_FRONTEND=noninteractive

ENV ROOT_PATH=/github/home

COPY . /github/workspace/

RUN ls /github/workspace

RUN chmod +x /github/workspace/src/setup.sh

ENTRYPOINT ["bash", "/github/workspace/src/setup.sh"]
