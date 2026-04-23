<div align="center">

# Vital Health Application

**A comprehensive health tracking system built with Flutter**

[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-red.svg)](LICENSE)

</div>

---

## Overview

VITAL is a streamlined health tracker built with Flutter and backed by Google Apps Script + Google Sheets. It started as an ultra-lightweight "Mom's Health Tracker" (weight & BP only) and has evolved into a full-featured multi-tab dashboard with journal, medication management, trends analytics, and more — while keeping a zero-server, zero-OAuth architecture.

## Screenshots

| Dashboard | Trends | Meds |
| :---: | :---: | :---: |
| <img src="assets/Dashboard.png" width="250" alt="App Dashboard" /> | <img src="assets/Trends.png" width="250" alt="Health Trends" /> | <img src="assets/Meds.png" width="250" alt="Medication Tracking" /> |

| Journal | Settings |
| :---: | :---: |
| <img src="assets/Journal.png" width="250" alt="Health Journal" /> | <img src="assets/Settings.png" width="250" alt="App Settings" /> |

---

## Features

### Core Health Tracking

| Feature | Description |
| :--- | :--- |
| **Weight Logging** | Record daily weight in kilograms with timestamped entries, persisted to Google Sheets. |
| **Blood Pressure** | Log systolic/diastolic readings with clinical status indicators (Normal / Elevated / High). |
| **Heart Rate** | Track BPM readings with range validation (40–220 bpm) and trend analysis. |
| **Combined Logging** | Simultaneously record weight and blood pressure in a single action. |

### Well-Being & Lifestyle

| Feature | Description |
| :--- | :--- |
| **Mood Tracking** | Icon-based mood logging (Great to Bad) with optional notes. |
| **Medication Management** | Add, track, and mark prescriptions as taken via a dedicated Meds tab. |
| **Journal** | Personal health journal with full CRUD — titles, body text, timestamps, and local persistence via SharedPreferences. |
| **Appointments** | Track upcoming doctor visits with name, date, and notes. |

### Analytics & Insights

| Feature | Description |
| :--- | :--- |
| **Trends Dashboard** | Visualize weight, BP, and heart rate trends over Week / Month / Year periods. |
| **Mini Bar Charts** | Inline sparkline-style weight trend visualization. |
| **Health Insights** | Auto-generated pattern analysis — BP time-of-day patterns, weight direction, HR trends. |
| **Monthly Summary** | 30-day aggregate report with averages, ranges, and mood distribution. |
| **BP Alerts** | Proactive warning when systolic readings ≥ 130 appear in recent logs. |

### System Characteristics

| Characteristic | Description |
| :--- | :--- |
| **Cream Design System** | Warm, earthy palette (cream/tan/black) inspired by premium health apps. |
| **5-Tab Navigation** | Home · Meds · Trends · Journal · Settings — bottom navigation. |
| **Serverless Backend** | Google Apps Script Web App — no servers, no OAuth, no infrastructure. |
| **Transparent Storage** | All vitals persisted in a Google Sheets spreadsheet for immediate access. |
| **Local Journal** | Journal entries stored locally via SharedPreferences with JSON serialization. |
| **Reset with Confirmation** | Destructive actions require explicit confirmation dialogs. |

---

## Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Language** | Dart 3.x |
| **Framework** | Flutter (Material 3) |
| **State Management** | Provider (3 providers: AppConfig, HealthData, Journal) |
| **HTTP Client** | `http` package |
| **Configuration** | `shared_preferences` |
| **Typography** | Google Fonts (Playfair Display + Inter) |
| **Backend** | Google Apps Script (Web App) |
| **Storage** | Google Sheets (vitals) + SharedPreferences (journal, config) |

---

## Architecture

<img src="assets/Arcitecture.png" width="250" alt="System Architecture" />

VITAL follows a 3-tier architecture designed for simplicity, privacy, and zero infrastructure costs. This structure ensures a clear separation between the user interface, the communication layer, and the data storage.

### Presentation Tier (Mobile Client)
The frontend is built with Flutter and follows a Provider-based state management pattern. It is organized into three main layers:
- **Screens and UI**: Responsive Material 3 components utilizing the Cream Design System.
- **Providers**: Manage the application state, including health data synchronization, journal entries, and configuration settings.
- **Theme and Core**: Centralized styling using Google Fonts and robust validation logic for health metrics.

### Logic Tier (Middle Layer)
The middle layer consists of a Google Apps Script Web App. This serves as a secure bridge between the mobile application and the database. It handles:
- Incoming HTTP POST requests from the client.
- Data formatting and validation before storage.
- Retrieval of historical logs for trend analysis.

### Data Tier (Storage)
VITAL utilizes a hybrid storage approach to balance performance and accessibility:
- **Cloud Storage**: Google Sheets acts as the primary database for vitals (Weight, Blood Pressure, Heart Rate). This allows users to access their raw data directly through a spreadsheet.
- **Local Storage**: SharedPreferences is used for the personal journal and application configuration, ensuring that private notes and settings remain on the device.

### File Structure
The project follows a modular directory structure:
- **lib/core/**: Core utilities, theme definitions, and health validators.
- **lib/data/**: Data models and the API client for backend communication.
- **lib/presentation/**: UI screens and state management providers.
- **main.dart**: The application entry point and provider initialization.

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Google Account for spreadsheet hosting

### Configuration

1.  **Backend Setup**: Deploy the `google_apps_script.js` file found in the root directory as a Google Apps Script Web App.
2.  **App Setup**: Launch the application and enter your name and the Web App URL during the onboarding process.
3.  **Permissions**: Ensure the Web App deployment is configured to allow access to the target spreadsheet.

### Build and Run

```bash
flutter pub get
flutter run
```

---

## Design Principles

- **Cream Palette**: Warm, earthy aesthetic — `#F5F3EC` background, `#FAF8F2` cards, `#DBD5C4` accents — for reduced visual fatigue.
- **Typography**: Playfair Display (headings) + Inter (body) via Google Fonts for a premium feel.
- **Confirmation Dialogs**: Destructive actions (delete, reset) always require explicit confirmation.
- **Progressive Disclosure**: Initial vital logging dialog on dashboard launch, deeper features in dedicated tabs.

---

## License

This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.
