from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, Query

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


@router.put("/")
def upsert_profile(data: ProfileCreate, sheet_id: str = Query(...)):
    """Create-or-update the single profile record. Only one profile per sheet."""
    ws = get_worksheet(sheet_id, TAB)
    records = sheet_to_records(ws)
    now = datetime.now(timezone.utc).isoformat()
    row = [
        data.my_name,
        data.my_gender,
        data.my_dob,
        data.height_cms,
        data.current_weight,
        data.target_weight,
        now,
    ]
    if not records:
        ws.append_row(row, value_input_option="USER_ENTERED")
        return {"message": "Profile created"}
    update_data = data.model_dump()
    update_row(ws, 2, update_data)
    return {"message": "Profile updated"}


@router.patch("/")
def patch_profile(data: ProfileUpdate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    records = sheet_to_records(ws)
    if not records:
        raise HTTPException(status_code=404, detail="Profile not found")
    update_data = {k: v for k, v in data.model_dump().items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields provided")
    update_row(ws, 2, update_data)
    return {"message": "Profile updated"}


@router.delete("/")
def delete_profile(sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    records = sheet_to_records(ws)
    if not records:
        raise HTTPException(status_code=404, detail="Profile not found")
    ws.delete_rows(2)
    return {"message": "Profile deleted"}
