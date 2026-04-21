import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, Query

from ..models import MoodCreate, MoodUpdate
from ..sheets import (
    append_row,
    delete_row,
    find_row_by_id,
    get_worksheet,
    sheet_to_records,
    update_row,
)

router = APIRouter(prefix="/mood", tags=["Mood"])
TAB = "mood"


@router.get("/")
def get_all_moods(sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    return sheet_to_records(ws)


@router.get("/{record_id}")
def get_mood(record_id: str, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    _, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    return record


@router.post("/", status_code=201)
def create_mood(data: MoodCreate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    record_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc).isoformat()
    append_row(ws, [record_id, now, data.mood_data])
    return {"message": "Mood created", "id": record_id}


@router.put("/{record_id}")
def update_mood(record_id: str, data: MoodUpdate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    row_index, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    update_data = {k: v for k, v in data.model_dump().items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields provided")
    update_row(ws, row_index, update_data)
    return {"message": "Mood updated"}


@router.delete("/{record_id}")
def delete_mood(record_id: str, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    row_index, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    delete_row(ws, row_index)
    return {"message": "Mood deleted"}
