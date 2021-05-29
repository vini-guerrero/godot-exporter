FROM ubuntu:20.04

LABEL author="Vinicius Guerrero"

ENV DEBIAN_FRONTEND=noninteractive

COPY . .

RUN ls && pwd

RUN chmod +x /src/setup.sh

ENTRYPOINT ["bash", "/src/setup.sh"]

