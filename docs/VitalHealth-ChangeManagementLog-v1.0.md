# Change Management Log: VITAL Health - Android (Flutter)

## 1. Document Overview
This log tracks all significant pivots in the project scope, technical stack, or feature set that occurred during the development of VITAL Health by Pranav.

## 2. Change Summary Table
| ID | Title | Date | Description of Change | Impact Assessment |
| :--- | :--- | :--- | :--- | :--- |
| **CR1** | **The Flutter Pivot** | 2026-03-25 | Switch from Native Android (Kotlin) to Flutter for enhanced UI flexibility. | **Architecture:** Significant refactor of UI and Provider logic. Enabled high-quality Android reach. |
| **CR2** | **Full Desktop Cleanout**| 2026-04-03 | Removal of Windows, Linux, and macOS platforms to focus on native mobile reach. | **Optimization:** Reduced repository bloat and focused testing resources on primary mobile users. |
| **CR3** | **Clinical PDF Hub** | 2026-04-04 | Added high-fidelity medical reporting with integrated OS share sheets. | **Scope:** Enhanced clinical utility from basic logging to medical tracking. |
| **CR4** | **Smart Health Intel** | 2026-04-05 | Implemented real-time BMI engine and critical vitals alert banner. | **Features:** Moved from a passive log to an active health monitoring tool. |
| **CR5** | **Android Identity** | 2026-04-05 | Configured Android app identity, splash branding, and store permissions. | **Deployment:** Prepared app for Google Play Store submission. |

## 3. Pivot Rationale (CR1)
The decision to switch to Flutter was made to ensure that Pranav can maintain a single, high-fidelity codebase for Android users. This significantly reduces maintenance overhead while ensuring a pixel-perfect "Matte Aesthetic" across all device types.

## 4. Feature Rationale (CR4)
Adding "Smart Intelligence" was an evolution of the basic vital logging goal. By providing real-time feedback (BMI) and health alerts, the app becomes more valuable as a preventative health tool.
