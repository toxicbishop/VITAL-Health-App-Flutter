from fastapi import APIRouter, HTTPException, Query
from datetime import datetime
import uuid
from ..models import MedicationCreate, MedicationUpdate
from ..sheets import get_worksheet, sheet_to_records, append_row, find_row_by_id, update_row, delete_row

router = APIRouter(prefix="/medication", tags=["Medication"])
TAB = "medication"

@router.get("/")
def get_all_medications(sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    return sheet_to_records(ws)

@router.get("/{record_id}")
def get_medication(record_id: str, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    _, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    return record

@router.post("/", status_code=201)
def create_medication(data: MedicationCreate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    record_id = str(uuid.uuid4())
    now = datetime.utcnow().isoformat()
    append_row(ws, [record_id, now, data.medication_name, data.dosage])
    return {"message": "Medication created", "id": record_id}

@router.put("/{record_id}")
def update_medication(record_id: str, data: MedicationUpdate, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    row_index, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    update_data = {k: v for k, v in data.model_dump().items() if v is not None}
    update_row(ws, row_index, list(update_data.keys()), update_data)
    return {"message": "Medication updated"}

@router.delete("/{record_id}")
def delete_medication(record_id: str, sheet_id: str = Query(...)):
    ws = get_worksheet(sheet_id, TAB)
    row_index, record = find_row_by_id(ws, record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    delete_row(ws, row_index)
    return {"message": "Medication deleted"}
