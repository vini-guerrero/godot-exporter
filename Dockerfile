FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

COPY . .

# RUN apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates git python python-openssl unzip wget zip curl openjdk-8-jdk apksigner nano curl dirmngr apt-transport-https lsb-release ca-certificates

# RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

# RUN sudo apt -y install nodejs 

# RUN chmod +x /src/setup.sh

ENTRYPOINT ["bash", "/src/setup.sh"]

