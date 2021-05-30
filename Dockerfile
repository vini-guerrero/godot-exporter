# Local Docker Image
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
COPY . .
RUN bash /src/install.sh
# RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# RUN sudo apt -y install nodejs 
# RUN chmod +x /src/setup.sh
ENTRYPOINT ["bash", "/src/setup.sh"]

# Docker Hub Image
#FROM viiniiguerrero/godot-exporter
#RUN chmod +x /src/setup.sh
#ENTRYPOINT ["bash", "/src/setup.sh"]
