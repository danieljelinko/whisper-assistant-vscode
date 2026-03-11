from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from faster_whisper import WhisperModel
import tempfile, os

app = FastAPI(title="Whisper Assistant API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_NAME   = os.getenv("WHISPER_MODEL", "turbo")
COMPUTE_TYPE = "float16" if os.getenv("USE_GPU", "1") == "1" else "int8"
DEVICE       = "cuda"    if os.getenv("USE_GPU", "1") == "1" else "cpu"

whisper_model = WhisperModel(MODEL_NAME, device=DEVICE, compute_type=COMPUTE_TYPE)

@app.post("/v1/audio/transcriptions")
async def transcribe_audio(
    file: UploadFile = File(...),
    model_name: str = Form("whisper-1"),  # kept for OpenAI API compat
    language: str   = Form(None)          # None = auto-detect
):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
        tmp.write(await file.read())
        tmp.flush()
        kwargs = {"vad_filter": True}
        if language: kwargs["language"] = language
        segments, info = whisper_model.transcribe(tmp.name, **kwargs)
        result = [{"id": i, "seek": 0, "start": s.start, "end": s.end,
                   "text": s.text, "tokens": [], "temperature": 0.0}
                  for i, s in enumerate(segments)]
        os.unlink(tmp.name)
    return {"text": " ".join(s["text"] for s in result),
            "segments": result, "language": info.language}

@app.get("/v1/health")
async def health_check(): return {"status": "ok"}

@app.get("/")
async def root(): return {"message": "Whisper Assistant API",
                          "docs": "/docs", "health": "/v1/health",
                          "transcribe": "/v1/audio/transcriptions"}
