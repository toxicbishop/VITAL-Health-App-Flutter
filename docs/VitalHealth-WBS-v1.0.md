# Work Breakdown Structure (WBS): VITAL Health - Android (Flutter)

## 1.0 Project Foundation
- **1.1 Conceptual Design:** Define medical UI/UX "Clinical-but-Warm" theme.
- **1.2 Technical Research:** Evaluate Flutter & Floor vs. Native Jetpack Compose.
- **1.3 Scope Configuration:** Finalize initial feature set and health tracking goals.

## 2.0 Engineering & Logic
- **2.1 Core Framework (Flutter):**
    - 2.1.1 5-Tab Navigation Shell (Home, Journal, Trends, Meds, Settings).
    - 2.1.2 Dark/Light Matte Theme injection via Material 3.
- **2.2 Local Persistence (Floor/SQLite):**
    - 2.2.1 Health Entity & DAO Design (Weight, BP, HR, Mood).
    - 2.2.2 Medication Schedule & Goal Tracking tables.
- **2.3 Cloud Intelligence:**
    - 2.3.1 Google Sheets API integration for health logging backup.
    - 2.3.2 Supabase Auth & Real-time Sync logic.

## 3.0 Clinical Features (Phase 4 & 5)
- **3.1 High-Fidelity Reporting:**
    - 3.1.1 Clinical PDF layouts for medical review.
    - 3.1.2 Native Share Intent integration for document distribution.
- **3.2 Health Intelligence:**
    - 3.2.1 Smart Alert Engine (BP/Heart Rate threshold warnings).
    - 3.2.2 BMI Analytics & Dynamic Health Banner.
    - 3.2.3 Persistent User Profile (Height, Age, Gender).

## 4.0 Platform Polish
- **4.1 Android Identity:** Vector branding and adaptive icon sets.

## 5.0 Quality & Closure
- **5.1 Functional Verification:** Comprehensive UAT for all health logic.
- **5.2 Repository Maintenance:** Clean-up of desktop platform remnants.
- **5.3 Release Execution:** Preparation of deployment-ready branches.
