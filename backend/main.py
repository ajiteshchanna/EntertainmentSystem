from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import FileResponse, StreamingResponse
from pathlib import Path
import mimetypes
import os


app = FastAPI(title="LanMedia Server")

MEDIA_DIR = Path("media")

# ----------------------------
# 1️⃣ Health Check
# ----------------------------
@app.get("/")
def health_check():
    return {
        "status": "ok",
        "message": "LanMedia server running"
    }

# ----------------------------
# Helper: detect media type
# ----------------------------
def get_media_type(filename: str):
    if filename.lower().endswith((".mp4", ".mkv", ".avi")):
        return "video"
    elif filename.lower().endswith((".mp3", ".wav", ".aac")):
        return "audio"
    else:
        return "document"

# ----------------------------
# 2️⃣ List Media Files
# ----------------------------
MEDIA_FOLDER = "media"  # jis folder se tum files serve kar rahe ho

@app.get("/api/stream/{filename}")
def stream_file(filename: str):
    file_path = os.path.join(MEDIA_FOLDER, filename)

    if not os.path.exists(file_path):
        return {"error": "File not found"}

    return FileResponse(
        file_path,
        media_type="audio/mpeg"
    )

@app.get("/api/files")
def list_media(request: Request):
    if not MEDIA_DIR.exists():
        return []

    files = []
    media_files = sorted(MEDIA_DIR.iterdir())

    for idx, file in enumerate(media_files):
        if file.is_file():
            files.append({
                "id": str(idx),
                "name": file.name,
                "type": get_media_type(file.name),
                "size": file.stat().st_size,
                "stream_url": str(request.base_url) + f"api/stream/{idx}",
                "thumbnail_url": None
            })

    return files

# ----------------------------
# 3️⃣ Stream Media (Range-friendly)
# ----------------------------
@app.get("/api/stream/{media_id}")
def stream_media(media_id: int, request: Request):
    media_files = sorted(MEDIA_DIR.iterdir())

    try:
        file_path = media_files[media_id]
    except IndexError:
        raise HTTPException(status_code=404, detail="Media not found")

    mime_type, _ = mimetypes.guess_type(file_path)
    return FileResponse(
        file_path,
        media_type=mime_type,
        filename=file_path.name
    )

# ----------------------------
# 4️⃣ Media Metadata (Optional)
# ----------------------------
@app.get("/api/media/{media_id}")
def media_metadata(media_id: int):
    media_files = sorted(MEDIA_DIR.iterdir())

    try:
        file_path = media_files[media_id]
    except IndexError:
        raise HTTPException(status_code=404, detail="Media not found")

    return {
        "id": str(media_id),
        "name": file_path.name,
        "type": get_media_type(file_path.name),
        "size": file_path.stat().st_size,
        "format": file_path.suffix.replace(".", "")
    }
