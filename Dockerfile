FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

# Python + system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip git ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir fastapi uvicorn python-multipart faster-whisper

WORKDIR /app

# Pre-download default model so first startup is fast
ARG WHISPER_MODEL=turbo
RUN python3 -c "from faster_whisper import WhisperModel; WhisperModel('${WHISPER_MODEL}', device='cpu', compute_type='int8')"

COPY main.py .

ENV WHISPER_MODEL=${WHISPER_MODEL}

# Model cache lives here; mount as volume to persist across containers
VOLUME /root/.cache/huggingface

EXPOSE 4444

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "4444"]
