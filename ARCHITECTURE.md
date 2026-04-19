# System Architecture (Simplified Edition)

This document provides a detailed overview of the architectural design for the Vital Health application, following the constraints of the Project Requirement Document (PRD).

## System Overview

The system is designed to provide a highly reliable, low-overhead solution for personal health logging. It minimizes the complexity of the tech stack by utilizing a direct client-to-spreadsheet communication model via Google Apps Script.

### Architectural Tiers

#### 1. Presentation Tier (Mobile Client)
The frontend is built using the Flutter framework with a Material 3 design system. It is responsible for:
- capturing user metrics (Weight/Blood Pressure).
- Managing local configuration (User Name/Script Endpoint).
- Providing a responsive interface for light and dark modes.

#### 2. Logic Tier (Google Apps Script)
The logic tier eliminates the need for dedicated server hosting. It is implemented as a script bound to the user's Google account and deployed as a Web App. Its responsibilities include:
- Receiving payloads via HTTP POST.
- Parsing and validating health data structures.
- Appending data rows to the persistence tier.

#### 3. Persistence Tier (Google Sheets)
The storage mechanism uses Google Sheets. This choice ensures:
- Immediate data visibility for the user.
- Built-in historical versioning.
- Ease of export into various formats (CSV, PDF, Excel).

## Data Flow and Sequence

The following steps outline the lifecycle of a health log entry:

1.  **Input Collection**: The user selects one of the three primary logging options on the home screen and enters the required values.
2.  **Serialization**: The application converts the input into a standardized JSON payload, including type flags and ISO-8601 timestamps.
3.  **Transmission**: The client transmits the payload to the configured Google Apps Script endpoint via an HTTP POST request.
4.  **Processing**: The Google Apps Script receives the request, identifies the active spreadsheet, and appends a formatted row to the "Logs" sheet.
5.  **Response**: A JSON success status is returned to the mobile client, which then updates the user interface to confirm the operation.

## Reliability and Maintenance
By removing complex layers such as a dedicated database server or third-party authentication services, the system remains highly resilient and easy to maintain over long durations without configuration changes.
