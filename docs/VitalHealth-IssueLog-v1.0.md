# Issue Log: VITAL Health - Android (Flutter)

## 1. Issue Tracking Table (Personal Project)
| ID | Issue Description | Severity | Date Identified | Status | Resolution |
| :-- | :--- | :--- | :--- | :--- | :--- |
| **I1** | **Supabase Auth Configuration** | Medium | 2026-03-25 | **Resolved** | Updated `AndroidManifest.xml` with correct redirect schemes. |
| **I2** | **Project Bloat (Desktop Folders)**| Medium | 2026-04-03 | **Resolved** | Permanently purged `linux`, `macos`, and `windows` directories. |
| **I3** | **PDF Layout Alignment Logic** | High | 2026-04-04 | **Resolved** | Refactored `PdfService` to use flexible layouts for clinical data tables. |
| **I4** | **Branch Deletion Accident** | Critical | 2026-04-05 | **Resolved** | Successful recovery of 4 PRs via `git reflog` reset. |
| **I5** | **Android Permission Strings** | Medium | 2026-04-05 | **Resolved** | Added necessary permission markers to `AndroidManifest.xml` for Notifications and Camera. |

## 2. Recovery Detail (I4)
During final branch merging, the feature branch was accidentally deleted while on `main`. By using the Git Reflog, the exact commit hash `11d30bc` was identified and the branch was restored without any loss of code.

## 3. Resolution Focus (I3)
The original PDF export logic struggled with multi-column alignment. This was resolved by implementing a custom widget-based layout system in `pdf_service.dart` that handles dynamic medical data sets gracefully.
