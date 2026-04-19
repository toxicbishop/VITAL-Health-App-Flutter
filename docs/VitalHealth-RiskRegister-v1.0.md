# Risk Register: VITAL Health - Android (Flutter)

## 1. Risk Identification & Mitigation Matrix (Personal Project)

| ID | Risk Description | Severity | Probability | Mitigation Strategy | Status |
| :-- | :--- | :--- | :--- | :--- | :--- |
| **R1** | **Platform Synchronization (Sync Lag)** | Medium | High | Use sync-flags in the database to track local vs. cloud state. | **Managed** |
| **R2** | **Build Environment Configuration** | Low | Low | Maintain local environment setup and Android Studio configuration. | **Managed** |
| **R3** | **Data Loss During Pivot** | High | Low | Use Git branching (reflog recovery) to ensure no commits are lost during refactors. | **Mitigated** |
| **R4** | **API Breaking Changes (Google/Supabase)** | Medium | Low | Periodic audit of package dependencies (`flutter pub outdated`). | **Managed** |
| **R5** | **Store Metadata Requirements** | Medium | Medium | Pre-verification of privacy strings and icons for Play Store readiness. | **Active** |
| **R6** | **Feature Complexity (PDF logic bugs)** | Medium | Medium | Unit testing of the `PdfService` and manual layout verification. | **Managed** |

## 2. Risk Tracking Summary
*Last updated: 2026-04-05*

Current focus is on **R2 (Build Environment)** and **R5 (Store Readiness)** as the core development features (PDF, Alerts, BMI) are now 100% complete and verified locally.

## 3. Contingency Plan
In the event of a significant technical blocker (e.g., cloud sync failure), development will pivot to **local-only backup (CSV/JSON)** to ensure the user never loses their health data, maintaining the "offline-first" promise.
