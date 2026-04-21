from dotenv import load_dotenv
import os
from pathlib import Path

_MODULE_DIR = Path(__file__).resolve().parent
load_dotenv(_MODULE_DIR / ".env")

_raw = os.getenv("CREDENTIALS_FILE", "credentials.json")
_path = Path(_raw)
CREDENTIALS_FILE = str(_path if _path.is_absolute() else _MODULE_DIR / _path)

TAB_HEADERS = {
    "profile": [
        "my_name",
        "my_gender",
        "my_dob",
        "height_cms",
        "current_weight",
        "target_weight",
        "created_at",
    ],
    "vitals": [
        "id",
        "timestamp",
        "wt_kgs",
        "bp_systolic",
        "bp_diastolic",
        "heart_rate_bpm",
    ],
    "mood": [
        "id",
        "timestamp",
        "mood_data",
    ],
    "medication": [
        "id",
        "timestamp",
        "medication_name",
        "dosage",
    ],
}
