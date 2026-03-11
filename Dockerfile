FROM python:3.10.13-slim

RUN apt-get update --fix-missing && apt-get install -y \
    git ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.cache/pip \
    for i in {1..3}; do \
        pip install fastapi uvicorn python-multipart faster-whisper && break || sleep 15; \
    done

WORKDIR /app

# Pre-download default model (turbo); override at runtime via WHISPER_MODEL env var
ARG WHISPER_MODEL=turbo
RUN python -c "from faster_whisper import WhisperModel; WhisperModel('${WHISPER_MODEL}', device='cpu', compute_type='int8')"

COPY main.py .

ENV WHISPER_MODEL=turbo
ENV USE_GPU=1

EXPOSE 4444

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "4444"]
