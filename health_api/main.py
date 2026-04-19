from fastapi import FastAPI
from .routers import profile, vitals, mood, medication

app = FastAPI(
    title="Health Tracker API",
    description="CRUD API backed by Google Sheets. Pass `sheet_id` as a query param to target any user's sheet.",
    version="1.0.0"
)

app.include_router(profile.router)
app.include_router(vitals.router)
app.include_router(mood.router)
app.include_router(medication.router)

@app.get("/")
def root():
    return {"message": "Health Tracker API is running!!"}
