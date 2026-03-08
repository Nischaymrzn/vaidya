# Vaidya.ai Mobile Application

Vaidya.ai is a health companion app that helps people keep medical information in one place, follow daily health patterns, and access AI-assisted guidance when they need faster clarity.

This project is built in Flutter and currently includes health records, vitals and symptom tracking, family health views, analytics dashboards, AI risk analysis, voice-assisted consultation, emergency fall alerts, and premium report downloads.

---

## 1. Non-Technical Overview

### 1.1 Background of the Proposed App

Many people have health data scattered across paper reports, chats, and different hospital systems. This creates delayed decisions, repeated tests, and poor continuity of care.

Vaidya.ai is proposed as a single mobile space where users can:

- Keep core health records organized
- Track trends (vitals, symptoms, medications)
- Get AI-supported risk and prediction insights
- Share context with family and care teams
- Respond faster during emergency situations

### 1.2 Aim

To provide a practical, everyday health management app that combines record-keeping, trend monitoring, and AI-assisted interpretation in one secure mobile experience.

### 1.3 Objectives

- Centralize health records and history in a single app
- Support preventive care through trend visibility and analytics
- Offer faster triage support with AI predictions and guided chat
- Improve family-level care coordination
- Enable offline-first continuity where connectivity is limited
- Introduce a sustainable premium model without blocking core tracking

### 1.4 Target Users

- Individuals managing chronic or recurring conditions
- Families monitoring children, elderly members, or dependents
- Users who need quick interpretation of symptoms and records
- Users in regions where continuity of digital medical records is limited

---

## 2. Application Features (User-Facing)

### 2.1 Core Experience

- Account onboarding and authentication (email/password + Google)
- Personalized dashboard with health score, risk factors, medication/allergy snapshot, symptom activity, and AI quick action
- Multi-tab navigation (`Home`, `Records`, `Intelligence`, `Analytics`, `Profile`)

### 2.2 Health Records

- Create, edit, delete medical records
- Store documents and structured fields
- AI scan of uploaded medical images (`/ai-scan`)
- Manage medications, allergies, immunizations
- Offline operation with pending sync queue for record create/update/delete

### 2.3 Vitals and Symptoms

- Log and edit vitals readings (heart rate, blood pressure, glucose, BMI, etc.)
- Trend cards and detail views
- Symptom logging with status and severity history
- Symptom anomaly/tracker support and frequency charts

### 2.4 Health Intelligence

- AI chat (`Vaidya.ai`) with contextual message history
- Risk assessment generation and insights
- Disease-specific prediction modules:
  - Diabetes
  - Heart disease
  - Tuberculosis
  - Brain tumor (image-based)
- PDF report generation and sharing for predictions and risk analysis

### 2.5 Family Health

- Create/join family groups
- Invite and manage members
- Member-level records and family-level summaries/insights
- Critical member awareness and coordination interface

### 2.6 Analytics

- 12-month analytics summary
- Encounter trends, condition/procedure distributions
- Medication and immunization timelines
- Allergy severity and provider network views

### 2.7 Profile and Device Utilities

- Personal info and password/security screens
- Theme control (light/dark/system + auto-lux mode)
- Sensor demo for ambient light and accelerometer stream
- Premium plan status and upgrade flow

### 2.8 Safety Feature

- Fall detection using accelerometer, user accelerometer, and gyroscope signals
- 10-second user confirmation countdown
- Emergency email drafting with GPS location when no response

## 3. Design Pattern and Architectural Pattern (Important)

### 3.1 Design Pattern: MVVM

#### What MVVM Means

MVVM separates UI from business logic:

- **View**: screens/widgets
- **ViewModel**: state transitions + interaction orchestration
- **Model**: data/entities returned from domain/data layers

#### MVVM in This Project

Examples:

- View: `lib/features/vitals/presentation/pages/vitals_screen.dart`
- ViewModel: `lib/features/vitals/presentation/view_model/vitals_viewmodel.dart`
- State model: `lib/features/vitals/presentation/state/vitals_state.dart`
- Domain model/entity: `lib/features/vitals/domain/entities/vital_entity.dart`

This pattern repeats across features (`auth`, `symptoms`, `records`, `analytics`, `intelligence`, `profile`, `family_health`).

#### Comprehensive Evaluation of MVVM Usage

Strengths in this app:

- Clear separation of rendering and logic
- Predictable async states (`initial/loading/loaded/error`)
- Easier testing of behavior in ViewModels (test coverage exists)
- Reusable widgets remain dumb and state-independent

Tradeoffs observed:

- Some screens still own transient UI logic and can become large
- A few flows mix UI decisions with business concerns (normal in evolving apps)

Overall, MVVM is implemented consistently and is appropriate for this multi-feature Flutter app.

### 3.2 Architectural Pattern: Clean Architecture

#### Why Clean Architecture Was Used

Because this app has many modules, multiple APIs, and local caching. Clean Architecture prevents feature coupling and keeps domain logic stable even if API/storage changes.

#### Layering Used in This Codebase

- **Presentation**: pages, widgets, view models, states
- **Domain**: entities, repository contracts, use cases
- **Data**: repository implementations, local/remote datasources, API/Hive models
- **Core**: shared services (API client, storage, sensors, connectivity, errors)

Typical flow:
`View -> ViewModel -> UseCase -> Repository Interface -> Repository Impl -> Remote/Local DataSource -> API/Hive`

#### Evidence in Project Structure

- `lib/features/<feature>/presentation/...`
- `lib/features/<feature>/domain/...`
- `lib/features/<feature>/data/...`
- `lib/core/...`

#### Evaluation of Clean Architecture Here

Strong points:

- Offline-first behavior is cleanly isolated in repositories
- Remote/local switching is standardized with `NetworkInfo`
- Use cases keep ViewModels thin and testable

Complexity cost:

- More files/classes per feature
- Requires discipline to avoid shortcuts across layers

For this app scale and roadmap, this architecture is justified.

---

## 4. State Management

### 4.1 What State Management Is

State management controls how UI reacts when data changes (loading, success, error, user actions, form input, stream updates).

### 4.2 State Management Used in This App

The project uses **Riverpod** (`flutter_riverpod`) as the primary state management solution.

Used patterns include:

- `Provider` for dependency injection
- `NotifierProvider` for feature ViewModels
- Immutable state objects with `copyWith`

Examples:

- `authViewModelProvider`
- `vitalsViewModelProvider`
- `symptomsViewModelProvider`
- `profileViewModelProvider`
- `predictionViewModelProvider`
- `fallDetectionViewModelProvider`

### 4.3 Why Riverpod Fits This System

- Works well with Clean Architecture dependency chains
- Reduces global singleton coupling
- Improves testability and modularity
- Handles async/UI state cleanly across many features

---

## 5. Sensors and APIs

### 5.1 Third-Party/External APIs Used

1. **Backend REST API (core business API)**

- Auth, dashboard, records, vitals, symptoms, analytics, family, AI, payments
- Implemented through `Dio` with retry, auth interceptor, timeout handling
- Endpoint constants in `lib/core/api/api_endpoints.dart`

2. **Google Authentication API**

- Google mobile token flow and backend verification
- Supports webview/deep-link callback logic for auth flows

3. **Stripe Checkout (payment)**

- Checkout session creation and payment status polling through backend payment endpoints
- In-app checkout completion supported via deep links (`vaidya://payment/...`)

4. **AI/Prediction APIs (backend-hosted services)**

- Risk assessment generation
- AI chat
- Disease prediction endpoints
- Medical image AI scan

### 5.2 Sensors and Device Capabilities Used

- **Accelerometer + User Accelerometer + Gyroscope**: fall detection algorithm
- **Ambient Light Sensor**: auto-lux theme switching
- **GPS Location**: emergency alert location context
- **Microphone + Speech Recognition**: voice consult input
- **Text-to-Speech**: spoken AI replies in consult mode

### 5.3 External/User-Created API Enhancements (Recommended)

To further improve the app:

- FHIR/HL7 connectors for hospital EMR integration
- Wearable APIs (Apple HealthKit / Google Health Connect / Fitbit)
- User-created webhook/API ingestion for home IoT devices (BP monitor, glucometer)

---

## 6. Data and Security

### 6.1 What Data the App Stores

The app handles:

- Account/session profile data (ID, email, role, plan)
- Health records, medications, allergies, immunizations
- Vitals and symptom history
- AI risk and prediction results
- Family group and member summaries
- Notifications and dashboard analytics caches
- Premium/payment status metadata

### 6.2 How Data Is Stored

Local storage:

- `SharedPreferences`: session flags, user metadata, token, theme mode
- `Hive` + feature cache box: cached module payloads and offline data
- Per-user scoped cache keys (`u:<userId>:<key>`) to reduce account mixing

Remote storage:

- Backend API system accessed via authenticated `Bearer` token requests
- Remote endpoints used as primary source when online

### 6.3 Data Persistence Strategy

- Read-through caching from remote to local
- Offline fallback reads for key features
- Offline create/update/delete for records with pending operation queue and later sync
- Similar offline patterns for vitals, symptoms, analytics, intelligence summaries

### 6.4 Security Mechanisms Currently Implemented

- Authorization header injection via API interceptor
- Token cleanup on `401`
- Input validation in forms and controlled payload builders
- Permission-gated access for location/mic/storage as needed

### 6.5 Security Risks and Improvements (Critical Evaluation)

Current implementation details reveal production hardening tasks:

- `android:usesCleartextTraffic="true"` and iOS `NSAllowsArbitraryLoads=true` allow non-HTTPS traffic for current development setup
- Auth token is currently in `SharedPreferences` (functional but not strongest option)

Recommended production upgrades:

- Enforce HTTPS-only transport and strict ATS/network security config
- Move token/session secrets to `flutter_secure_storage`
- Add certificate pinning for sensitive API domains
- Add local-at-rest encryption for health caches with key rotation policy

### 6.6 Ethical Considerations (Brief)

- Health data is highly sensitive; explicit consent and purpose limitation are essential
- AI predictions should be assistive, not definitive diagnosis
- Users should understand uncertainty/risk scores and seek clinical confirmation
- Family access must be permission-based and revocable
- Data minimization and retention policy should be transparent

---

## 7. Cloud Computing and Big Data Significance in This App

Cloud computing and big-data style aggregation are significant for this app's business value because:

1. **Cross-feature intelligence needs centralized processing**

- Risk generation combines vitals, symptoms, records, medications, allergies, and immunizations
- This is difficult to compute robustly on-device alone

2. **Scalability and continuous model evolution**

- Prediction endpoints can be improved server-side without forcing full client redesign
- Supports iterative accuracy and feature rollout

3. **Unified analytics for engagement and outcomes**

- Dashboard and analytics summaries depend on aggregated longitudinal data
- Enables trend-based value rather than one-time utility

4. **Family-level and account-level coordination**

- Multi-member family health functions benefit from cloud-backed data consistency

5. **Business sustainability**

- Premium intelligence/report services are naturally cloud-delivered and measurable

### Sustained Argument

For a health app with AI-assisted predictions, cloud-backed data aggregation is not optional convenience; it is a structural requirement for consistency, personalization, and monetizable advanced features. The current API-rich architecture in Vaidya.ai already aligns with this direction.

---

## 8. Technical Stack Summary

- **Framework**: Flutter (Dart)
- **State management**: Riverpod
- **Architecture**: Clean Architecture + MVVM at presentation level
- **Networking**: Dio + retry + connectivity checks
- **Local persistence**: Hive + SharedPreferences
- **Authentication**: Email/password + Google sign-in flow
- **Payments**: Stripe checkout session flow via backend
- **Charts/UI**: fl_chart, svg, lottie
- **Sensors/Device**: sensors_plus, light_sensor, geolocator, speech_to_text, flutter_tts
- **Testing**: Unit and widget tests across core and feature modules

---

## 9. API Configuration and Running Locally

Default emulator run:

```bash
flutter run
```

Default base URL is read from `API_BASE_URL` with fallback:

```text
http://192.168.1.2:5000/v1/api
```

Override with full URL:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/v1/api
```

Physical device example:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.4:5000/v1/api
```

---

## 10. Current Limitations and Practical Next Steps

Known in-app placeholders (already visible in UI):

- Notification settings (coming soon)
- Health preferences (coming soon)
- Contact support flow (coming soon)
- Delete account flow (not enabled yet)

Recommended roadmap priorities:

- Production-grade security hardening (HTTPS-only, secure token storage)
- Consent/privacy policy screens and data export/delete controls
- Expanded premium catalog beyond report downloads
- Wearable and clinical API integrations for stronger data continuity

---

## 11. Disclaimer

Vaidya.ai provides AI-assisted health support and record management. It does not replace professional medical diagnosis or emergency care.
