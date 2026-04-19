# Project Charter: VITAL Health - Android (v1.0)

## 1. Project Overview
**Project Name:** VITAL Health  
**Owner / Lead Developer:** Pranav  
**Date:** 2026-04-05  

## 2. Project Goal
The primary goal is to develop a premium health tracking app for the **Android** platform. This personal project empowers users to monitor their vital signs, medications, and overall health progress through a secure, intuitive, and modern interface (Flutter).

## 3. Project Scope
### In-Scope:
- **Platform Accessibility:** Seamless experience across Android devices.
- **Health Tracking:** Automated logging of weight (BMI), blood pressure, heart rate, and mood.
- **Intelligence:** Smart health alerts for critical vitals and real-time BMI engine.
- **Medication Management:** Tracking takes, refills, and custom schedules.
- **Analytics:** Real-time trend charts and professional-grade **Clinical PDF Reporting**.
- **Journaling:** Chronological health timeline with free-form notes.
- **Cloud Sync:** Secure backup and multi-device synchronization via Google Sheets and Supabase.
- **Security:** Offline-first data storage (Floor/SQLite) with zero-compromise encryption.

### Out-of-Scope:
- Integration with external wearable hardware (e.g., smartwatches, fitness trackers) in initial release.
- Social media ecosystem features.
- In-app direct telemedicine payments.

## 4. Personal Vision
This application is designed as a sophisticated personal health assistant, prioritizing privacy and clinical-grade data presentation. The vision is to provide a "clinical-but-warm" tool that bridges the gap between patient logs and medical professional reviews.

## 5. Definition of Done
- **Core Feature Delivery:** All primary features (Journal, Trends, Meds) fully functional.
- **Data Integrity:** Zero data loss during offline usage or cloud synchronization.
- **User Interface:** Deployment of the "Espresso & Cream" matte design system.
- **Release Readiness:** All clinical-grade PDF logic verified for sharing.

## 6. Project Constraints & Assumptions
- **Constraint:** Personal development timeline and single-developer resources (Pranav).
- **Constraint:** Deployment targeting modern Android versions.
- **Assumption:** Users have periodic access to local data backup or cloud connectivity.
- **Assumption:** Third-party cloud providers (Google/Supabase) maintain standard uptime.
