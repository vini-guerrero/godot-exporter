FROM ubuntu:20.04

LABEL author="Vinicius Guerrero"

ENV DEBIAN_FRONTEND=noninteractive

COPY setup.sh /setup.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT ["sh", "./setup.sh"]
