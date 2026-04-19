# Project Plan: VITAL Health - Android (Flutter)

## 1. Project Motivation
The goal of VITAL Health is to provide a premium, secure, and offline-first health tracking solution for **Android**. The project prioritizes maximum user privacy through local-first storage while delivering high-quality health vitals analytics and professional PDF reporting.

## 2. Project Evolution & Schedule
| Milestone | Status | Key Deliverables |
| :--- | :--- | :--- |
| **Project Initiation** | Completed | Research and Scope Definition |
| **Android Prototype** | Completed | Native Jetpack Compose health log proof-of-concept |
| **Flutter Pivot (v1.0)** | Completed | Migrated to Flutter for enhanced UI flexibility |
| **Phase 4: Clinical Reports**| Completed | Clinical PDF generation and share suite implementation |
| **Phase 5: Intelligence** | Completed | Smart health alerts, BMI Engine, and personal profile persistence |
| **Phase 6: UI Polishing** | Completed | Native Android identity, icon/splash design, and refined branding |
| **Release Candidate** | Active | Final verification of local-to-cloud sync logic |

## 3. Technology Stack
| Layer | Choice |
| :--- | :--- |
| **Framework** | Flutter 3.x (Dart) |
| **Local Database** | Floor (SQLite-based persistence) |
| **Cloud Sync** | Google Sheets & Supabase API |
| **Design System** | Matte Aesthetic (Custom Material 3) |
| **Reporting** | Dart `pdf` and `printing` packages |

## 4. Development Resource
This project is developed and maintained solely by **Pranav**, following an iterative, phase-based engineering workflow. All architecture decisions, UI/UX design, and backend configuration are managed personally to ensure high-fidelity execution.

## 5. Scope & Quality Standards
- **Performance**: Goal of <2s launch time and 60fps scrolling performance.
- **Reliability**: Use of standard database migrations to prevent data loss.
- **Accessibility**: High-contrast matte colors for readability.
- **Privacy Focus**: Core logging remains functional without any network connectivity.
