from fastapi import APIRouter, HTTPException, Query
from datetime import datetime
from ..models import ProfileCreate, ProfileUpdate
from ..sheets import get_worksheet, sheet_to_records, update_row

router = APIRouter(prefix="/profile", tags=["Profile"])

TAB = "profile"

@router.get("/")
def get_profile(sheet_id: str = Query(..., description="Google Sheet ID")):
    ws = get_worksheet(sheet_id, TAB)
    records = sheet_to_records(ws)
    if not records:
        raise HTTPException(status_code=404, detail="Profile not found")
    return records[0]

@router.post("/", status_code=201)
def create_profile(data: ProfileCreate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    existing = sheet_to_records(ws)
    if existing:
        raise HTTPException(status_code=400, detail="Profile already exists. Use PUT to update.")
    now = datetime.utcnow().isoformat()
    ws.append_row([
        data.my_name, data.my_gender, data.my_dob,
        data.height_cms, data.current_weight, data.target_weight, now
    ], value_input_option="USER_ENTERED")
    return {"message": "Profile created"}

@router.put("/")
def update_profile(data: ProfileUpdate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    records = sheet_to_records(ws)
    if not records:
        raise HTTPException(status_code=404, detail="Profile not found")
    update_data = {k: v for k, v in data.model_dump().items() if v is not None}
    update_row(ws, 2, list(update_data.keys()), update_data)
    return {"message": "Profile updated"}

@router.delete("/")
def delete_profile(sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    records = sheet_to_records(ws)
    if not records:
        raise HTTPException(status_code=404, detail="Profile not found")
    ws.delete_rows(2)
    return {"message": "Profile deleted"}
