import gspread
from google.oauth2.service_account import Credentials
from .config import CREDENTIALS_FILE

SCOPES = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
]

def get_sheet_client():
    creds = Credentials.from_service_account_file(CREDENTIALS_FILE, scopes=SCOPES)
    return gspread.authorize(creds)

def get_worksheet(sheet_id: str, tab_name: str):
    client = get_sheet_client()
    spreadsheet = client.open_by_key(sheet_id)
    return spreadsheet.worksheet(tab_name)

def sheet_to_records(worksheet) -> list[dict]:
    return worksheet.get_all_records()

def append_row(worksheet, row: list):
    worksheet.append_row(row, value_input_option="USER_ENTERED")

def find_row_by_id(worksheet, record_id: str) -> tuple[int, dict | None]:
    """Returns (row_index, record). Row index is 1-based (row 1 = header)."""
    records = worksheet.get_all_records()
    for i, record in enumerate(records, start=2):  # data starts at row 2
        if str(record.get("id")) == str(record_id):
            return i, record
    return -1, None

def update_row(worksheet, row_index: int, headers: list[str], data: dict):
    """Update specific cells in a row based on headers."""
    all_values = worksheet.row_values(1)  # get header row
    for col_index, header in enumerate(all_values, start=1):
        if header in data:
            worksheet.update_cell(row_index, col_index, data[header])

def delete_row(worksheet, row_index: int):
    worksheet.delete_rows(row_index)
