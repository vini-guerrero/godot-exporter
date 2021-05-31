# Local Docker Image
FROM ubuntu:bionic
ENV DEBIAN_FRONTEND=noninteractive
COPY . .
RUN chmod +x /src/install.sh && bash /src/install.sh
RUN chmod +x /src/setup.sh
ENTRYPOINT ["bash", "/src/setup.sh"]

# Docker Hub Image
# FROM viiniiguerrero/godot-exporter
# RUN chmod +x /src/install.sh && bash /src/install.sh
# RUN chmod +x /src/setup.sh
# ENTRYPOINT ["bash", "/src/setup.sh"]
