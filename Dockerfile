FROM ubuntu:20.04

LABEL author="Vinicius Guerrero"

ENV DEBIAN_FRONTEND=noninteractive

COPY . .

ENTRYPOINT ["sh", "./docker.sh"]

# RUN printenv
