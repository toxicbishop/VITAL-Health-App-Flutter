from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import medication, mood, profile, vitals

app = FastAPI(
    title="Health Tracker API",
    description="CRUD API backed by Google Sheets. Pass `sheet_id` as a query param to target any user's sheet.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(profile.router)
app.include_router(vitals.router)
app.include_router(mood.router)
app.include_router(medication.router)


@app.get("/")
def root():
    return {"message": "Health Tracker API is running", "docs": "/docs"}


@app.get("/health")
def health():
    return {"status": "ok"}
