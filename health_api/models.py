from pydantic import BaseModel
from typing import Optional

# ── Profile ──────────────────────────────────────────
class ProfileCreate(BaseModel):
    my_name: str
    my_gender: str
    my_dob: str                  # "YYYY-MM-DD"
    height_cms: float
    current_weight: float
    target_weight: float

class ProfileUpdate(BaseModel):
    my_name: Optional[str] = None
    my_gender: Optional[str] = None
    my_dob: Optional[str] = None
    height_cms: Optional[float] = None
    current_weight: Optional[float] = None
    target_weight: Optional[float] = None

# ── Vitals ────────────────────────────────────────────
class VitalsCreate(BaseModel):
    wt_kgs: float
    bp_systolic: int
    bp_diastolic: int
    heart_rate_bpm: int

class VitalsUpdate(BaseModel):
    wt_kgs: Optional[float] = None
    bp_systolic: Optional[int] = None
    bp_diastolic: Optional[int] = None
    heart_rate_bpm: Optional[int] = None

# ── Mood ──────────────────────────────────────────────
class MoodCreate(BaseModel):
    mood_data: str

class MoodUpdate(BaseModel):
    mood_data: Optional[str] = None

# ── Medication ────────────────────────────────────────
class MedicationCreate(BaseModel):
    medication_name: str
    dosage: str

class MedicationUpdate(BaseModel):
    medication_name: Optional[str] = None
    dosage: Optional[str] = None
