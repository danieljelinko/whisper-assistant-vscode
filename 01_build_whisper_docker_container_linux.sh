# install docker buildx from 31_install_docker_buildx.sh

# install extension whisper assistant Martin Opensky
sudo apt install sox


# Launch Whisper Docker container
# Prebuilt docker image for mac
#docker run -d -p 4444:4444 --name whisper-assistant martinopensky/whisper-assistant:latest

# Local build for linux — build all model variants (one-time, ~20 min per model)
git clone https://github.com/martin-opensky/whisper-assistant-vscode
cd whisper-assistant-vscode
./build_all_models.sh              # builds base, turbo, large-v3
# Or build a single model:
# ./build_all_models.sh turbo

# Images are tagged as whisper-assistant:<model>
# The launcher script auto-selects the right image based on WHISPER_MODEL env var
docker run -d -p 4444:4444 whisper-assistant:turbo                # cpu
docker run -d -p 4444:4444 --gpus all whisper-assistant:turbo     # gpu support
