mkdir -p ~/.docker/cli-plugins
cd ~/.docker/cli-plugins

# download https://github.com/docker/buildx/releases/download/v0.23.0/buildx-v0.23.0.linux-amd64
curl -L https://github.com/docker/buildx/releases/download/v0.23.0/buildx-v0.23.0.linux-amd64 -o docker-buildx

chmod +x docker-buildx

docker buildx version

