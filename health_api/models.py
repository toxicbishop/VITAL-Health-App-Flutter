from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field, field_validator


def _validate_dob(v: str) -> str:
    try:
        datetime.strptime(v, "%Y-%m-%d")
    except (TypeError, ValueError):
        raise ValueError("my_dob must be in YYYY-MM-DD format")
    return v


# ── Profile ──────────────────────────────────────────
class ProfileCreate(BaseModel):
    my_name: str = Field(..., min_length=1, max_length=100)
    my_gender: str = Field(..., min_length=1, max_length=20)
    my_dob: str
    height_cms: float = Field(..., gt=0, le=300)
    current_weight: float = Field(..., gt=0, le=500)
    target_weight: float = Field(..., gt=0, le=500)

    @field_validator("my_dob")
    @classmethod
    def _dob(cls, v):
        return _validate_dob(v)


class ProfileUpdate(BaseModel):
    my_name: Optional[str] = Field(None, min_length=1, max_length=100)
    my_gender: Optional[str] = Field(None, min_length=1, max_length=20)
    my_dob: Optional[str] = None
    height_cms: Optional[float] = Field(None, gt=0, le=300)
    current_weight: Optional[float] = Field(None, gt=0, le=500)
    target_weight: Optional[float] = Field(None, gt=0, le=500)

    @field_validator("my_dob")
    @classmethod
    def _dob(cls, v):
        if v is None:
            return v
        return _validate_dob(v)


# ── Vitals ────────────────────────────────────────────
class VitalsCreate(BaseModel):
    wt_kgs: float = Field(..., gt=0, le=500)
    bp_systolic: int = Field(..., ge=40, le=260)
    bp_diastolic: int = Field(..., ge=20, le=200)
    heart_rate_bpm: int = Field(..., ge=20, le=300)


class VitalsUpdate(BaseModel):
    wt_kgs: Optional[float] = Field(None, gt=0, le=500)
    bp_systolic: Optional[int] = Field(None, ge=40, le=260)
    bp_diastolic: Optional[int] = Field(None, ge=20, le=200)
    heart_rate_bpm: Optional[int] = Field(None, ge=20, le=300)


# ── Mood ──────────────────────────────────────────────
class MoodCreate(BaseModel):
    mood_data: str = Field(..., min_length=1, max_length=500)


class MoodUpdate(BaseModel):
    mood_data: Optional[str] = Field(None, min_length=1, max_length=500)


# ── Medication ────────────────────────────────────────
class MedicationCreate(BaseModel):
    medication_name: str = Field(..., min_length=1, max_length=200)
    dosage: str = Field(..., min_length=1, max_length=100)


class MedicationUpdate(BaseModel):
    medication_name: Optional[str] = Field(None, min_length=1, max_length=200)
    dosage: Optional[str] = Field(None, min_length=1, max_length=100)
