FROM ubuntu:20.04

LABEL author="Vinicius Guerrero"

ENV DEBIAN_FRONTEND=noninteractive

COPY /src/setup.sh /src/setup.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT ["sh", "./src/setup.sh"]
