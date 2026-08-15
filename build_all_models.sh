#!/usr/bin/env bash
set -euo pipefail

# Build tagged Docker images for each Whisper model size
# Usage: ./build_all_models.sh [model...]
# Default: builds base, turbo, large-v3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODELS=("${@:-base turbo large-v3}")
if [ $# -eq 0 ]; then MODELS=(base turbo large-v3); fi

for model in "${MODELS[@]}"; do
    echo "━━━ Building whisper-assistant:${model} ━━━"
    DOCKER_BUILDKIT=1 docker build \
        --build-arg WHISPER_MODEL="$model" \
        -t "whisper-assistant:${model}" .
    echo "✓ whisper-assistant:${model} built"
    echo ""
done

echo "Done. Available images:"
docker images whisper-assistant --format "  {{.Repository}}:{{.Tag}}\t{{.Size}}"
