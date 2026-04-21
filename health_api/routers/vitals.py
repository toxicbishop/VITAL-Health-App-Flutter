import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, Query

from ..models import VitalsCreate, VitalsUpdate
from ..sheets import (
    append_row,
    delete_row,
    find_row_by_id,
    get_worksheet,
    sheet_to_records,
    update_row,
)

router = APIRouter(prefix="/vitals", tags=["Vitals"])
TAB = "vitals"


@router.get("/")
def get_all_vitals(sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    return sheet_to_records(ws)


@router.get("/{record_id}")
def get_vital(record_id: str, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    _, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    return record


@router.post("/", status_code=201)
def create_vital(data: VitalsCreate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    record_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc).isoformat()
    append_row(ws, [record_id, now, data.wt_kgs, data.bp_systolic, data.bp_diastolic, data.heart_rate_bpm])
    return {"message": "Vital created", "id": record_id}


@router.put("/{record_id}")
def update_vital(record_id: str, data: VitalsUpdate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    row_index, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    update_data = {k: v for k, v in data.model_dump().items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields provided")
    update_row(ws, row_index, update_data)
    return {"message": "Vital updated"}


@router.delete("/{record_id}")
def delete_vital(record_id: str, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    row_index, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    delete_row(ws, row_index)
    return {"message": "Vital deleted"}
