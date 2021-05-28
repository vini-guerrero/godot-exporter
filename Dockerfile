FROM ubuntu:20.04

LABEL author="Vinicius Guerrero"

ENV DEBIAN_FRONTEND=noninteractive

ENV ROOT_PATH=/github/home

COPY . .

RUN pwd && ls

RUN chmod +x ./src/setup.sh

ENTRYPOINT ["bash", "./src/setup.sh"]

