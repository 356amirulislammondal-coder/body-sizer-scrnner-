# 📏 Body Size Scanner

AI-powered full-body measurement scanner — built with Flutter. Open the app
and start scanning immediately: **no login, no registration, no cloud.**

## Features

- **No account required** — the app is fully usable from first launch.
- **Upload or capture** a full-body photo (Gallery or Camera).
- **On-device pose detection** using Google ML Kit's Pose Detection API
  (the same BlazePose/MediaPipe landmark topology referenced in the spec).
- **10 estimated measurements**: Chest, Waist, Hip, Shoulder Width, Neck,
  Sleeve Length, Arm Length, Inseam Length, Height, Estimated Weight — plus
  derived **BMI** and **Body Shape** (Slim / Athletic / Average / Heavy).
- Every measurement shown in **both centimeters and inches**.
- **Pre-scan instructions** screen (distance, lighting, clothing, posture).
- **Results screen** with photo, all measurements, an **accuracy badge**
  (High / Medium / Low), and:
  - Scan Again
  - Save Report (PDF)
  - Share Report
- **Local-only history** (Hive database) — nothing is ever uploaded.
- **Material Design 3**, blue & white theme, light + dark mode, smooth
  page/state transitions.
- Persistent, unmissable **disclaimer**: all measurements are AI estimates
  for general guidance only — not medical or exact tailoring data.

## Tech Stack

- Flutter 3.22+ / Dart 3.3+
- `google_mlkit_pose_detection` (on-device pose landmarks)
- `tflite_flutter` (optional slot for a custom refinement model)
- `camera` + `image_picker` (capture & gallery)
- `hive` / `hive_flutter` (local database, no cloud)
- `pdf` + `printing` + `share_plus` (PDF export & sharing)
- `provider` (state management)

## Getting Started

See **[SETUP_GUIDE.md](SETUP_GUIDE.md)** for full installation, run, and
APK build instructions.

Quick start:
```bash
flutter create --platforms=android,ios --org com.yourcompany .
flutter pub get
flutter run
```

## ⚠️ Disclaimer

All body measurements produced by this app are **AI-based estimates**
generated from a single 2D photograph and are intended for **general
guidance only**. They are **not** a substitute for measurements taken with
a tape measure by a professional tailor, and are **not** medical or
clinical data. See `lib/core/constants/app_constants.dart` for the full
disclaimer text shown in-app.
