import gspread
from fastapi import HTTPException
from google.oauth2.service_account import Credentials
from gspread.exceptions import APIError, SpreadsheetNotFound, WorksheetNotFound

from .config import CREDENTIALS_FILE, TAB_HEADERS

SCOPES = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
]

_client = None


def get_sheet_client():
    global _client
    if _client is None:
        creds = Credentials.from_service_account_file(CREDENTIALS_FILE, scopes=SCOPES)
        _client = gspread.authorize(creds)
    return _client


def _validate_sheet_id(sheet_id: str):
    if not sheet_id or len(sheet_id) < 20:
        raise HTTPException(status_code=400, detail="Invalid sheet_id")


def get_worksheet(sheet_id: str, tab_name: str):
    _validate_sheet_id(sheet_id)
    if tab_name not in TAB_HEADERS:
        raise HTTPException(status_code=400, detail=f"Unknown tab: {tab_name}")
    client = get_sheet_client()
    try:
        spreadsheet = client.open_by_key(sheet_id)
    except SpreadsheetNotFound:
        raise HTTPException(status_code=404, detail="Spreadsheet not found")
    except APIError as e:
        raise HTTPException(status_code=502, detail=f"Google Sheets API error: {e}")
    headers = TAB_HEADERS[tab_name]
    try:
        ws = spreadsheet.worksheet(tab_name)
    except WorksheetNotFound:
        ws = spreadsheet.add_worksheet(title=tab_name, rows=1000, cols=len(headers))
        ws.update("A1", [headers], value_input_option="USER_ENTERED")
        return ws
    existing = ws.row_values(1)
    if existing != headers:
        ws.update("A1", [headers], value_input_option="USER_ENTERED")
    return ws


def sheet_to_records(worksheet) -> list[dict]:
    return worksheet.get_all_records()


def append_row(worksheet, row: list):
    worksheet.append_row(row, value_input_option="USER_ENTERED")


def find_row_by_id(worksheet, record_id: str) -> tuple[int, dict | None]:
    records = worksheet.get_all_records()
    for i, record in enumerate(records, start=2):
        if str(record.get("id")) == str(record_id):
            return i, record
    return -1, None


def update_row(worksheet, row_index: int, data: dict):
    headers = worksheet.row_values(1)
    updates = []
    for col_index, header in enumerate(headers, start=1):
        if header in data:
            updates.append({
                "range": gspread.utils.rowcol_to_a1(row_index, col_index),
                "values": [[data[header]]],
            })
    if updates:
        worksheet.batch_update(updates, value_input_option="USER_ENTERED")


def delete_row(worksheet, row_index: int):
    worksheet.delete_rows(row_index)
