# install docker buildx from 31_install_docker_buildx.sh

# install extension whisper assistant Martin Opensky
sudo apt install sox


# Launch Whisper Docker container
# Prebuilt docker image for mac
#docker run -d -p 4444:4444 --name whisper-assistant martinopensky/whisper-assistant:latest

# Local build for linux
git clone https://github.com/martin-opensky/whisper-assistant-vscode
cd whisper-assistant-vscode
DOCKER_BUILDKIT=1 docker build -t whisper-assistant-local .

docker run -d -p 4444:4444 whisper-assistant-local # cpu
docker run -d -p 4444:4444 --gpus all whisper-assistant-local # gpu support