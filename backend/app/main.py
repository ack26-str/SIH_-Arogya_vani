from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import DatabaseService
from app.routers import conversations, documents, patients, sessions, consent


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup: initialize DB + create upload dir. Shutdown: close DB."""
    # Startup
    await DatabaseService.initialize()
    Path(settings.UPLOAD_DIR).mkdir(parents=True, exist_ok=True)
    print(f"📁 Upload directory: {settings.UPLOAD_DIR}")
    yield
    # Shutdown
    await DatabaseService.close()


app = FastAPI(
    title="AarogyaVani API",
    description="Backend API for the Multilingual Clinical Intake System (SIH26047)",
    version="2.0.0",
    lifespan=lifespan,
)

# Configure CORS for Flutter app communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register all routers
app.include_router(patients.router)
app.include_router(sessions.router)
app.include_router(consent.router)
app.include_router(conversations.router)
app.include_router(documents.router)


@app.get("/")
def read_root():
    return {
        "status": "ok",
        "app": "AarogyaVani",
        "version": "2.0.0",
        "problem_id": "SIH26047",
        "organization": "All India Institute of Ayurveda, Ministry of Ayush",
        "message": "Multilingual Clinical Intake System — API is running",
    }


@app.get("/api/health")
def health_check():
    return {"status": "healthy", "database": "sqlite", "version": "2.0.0"}
