# Body Size Scanner — Setup & Build Guide

A complete step-by-step guide to get this Flutter project running and to
produce a signed/unsigned APK.

---

## 1. Prerequisites

Install these before doing anything else:

| Tool | Minimum Version | Notes |
|---|---|---|
| Flutter SDK | 3.22+ (Dart 3.3+) | https://docs.flutter.dev/get-started/install |
| Android Studio | Latest | For Android SDK, emulator, and platform tools |
| Android SDK | API 34 (compile), min API 23 | Installed via Android Studio SDK Manager |
| JDK | 17 | Required by current Android Gradle Plugin |
| A physical Android device or emulator | Android 6.0 (API 23)+ | A **real device** is strongly recommended — pose detection is much easier to test with an actual camera and a person standing in frame |

Verify your setup:

```bash
flutter doctor -v
```

Fix anything marked with a red ✗ before continuing (especially Android
toolchain and licenses — run `flutter doctor --android-licenses` and accept
all).

---

## 2. Get the project onto your machine

1. Unzip the delivered `body_size_scanner` project folder anywhere on disk.
2. Open a terminal inside the project root (the folder containing
   `pubspec.yaml`).

---

## 3. Regenerate the native Android/iOS scaffolding

This deliverable ships the **Dart/Flutter source code, the Android manifest,
and the Gradle config that differ from Flutter's defaults** (permissions,
minSdk, ProGuard rules, FileProvider). To generate the remaining standard
platform boilerplate (Gradle wrapper files, `MainActivity.kt`, app icons,
iOS `Runner.xcodeproj`, etc.) that Flutter normally scaffolds for you, run:

```bash
flutter create --platforms=android,ios --org com.yourcompany .
```

Run this **from inside the project root**, using `.` (current directory) —
this merges standard platform files into the existing project without
touching your `lib/`, `pubspec.yaml`, or the custom `AndroidManifest.xml` /
`build.gradle` files already provided (Flutter will ask before overwriting
anything that already exists; answer **N** if prompted about files listed
in section 8 below, since custom versions are already included).

> If you'd rather start totally fresh: run `flutter create` into an empty
> folder first, then copy this project's `lib/`, `pubspec.yaml`, and the
> Android files listed in section 8 on top of it.

---

## 4. Install dependencies

```bash
flutter pub get
```

This downloads all packages listed in `pubspec.yaml`, including:
- `google_mlkit_pose_detection` (on-device pose/body landmark detection)
- `camera` / `image_picker` (capture & gallery)
- `hive` / `hive_flutter` (local database — scan history, settings)
- `pdf` / `printing` / `share_plus` (Save Report / Share Report)

---

## 5. (Optional) Regenerate Hive adapters

The Hive `TypeAdapter` files (`lib/models/body_measurement.g.dart`) are
already included and hand-verified to match the model, so this step is
**optional** — only needed if you modify any `@HiveField` in
`body_measurement.dart`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 6. Run the app in debug mode

With a device connected (`flutter devices` to confirm it's detected):

```bash
flutter run
```

On first launch, grant the Camera and Photos/Media permission prompts —
these are required for the "Capture Photo" and "Upload from Gallery"
buttons to work.

---

## 7. Build a release APK

### Quick unsigned/debug-signed APK (fastest — good for personal testing)

```bash
flutter build apk --release
```

Output location:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Split APKs per architecture (smaller download size)

```bash
flutter build apk --split-per-abi --release
```

Produces `app-armeabi-v7a-release.apk`, `app-arm64-v8a-release.apk`, and
`app-x86_64-release.apk` in the same output folder.

### Properly signed release APK (required before publishing to Play Store)

1. Generate a keystore (one-time):
   ```bash
   keytool -genkey -v -keystore ~/body-size-scanner-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties`:
   ```properties
   storePassword=<your password>
   keyPassword=<your password>
   keyAlias=upload
   storeFile=/absolute/path/to/body-size-scanner-key.jks
   ```
3. Update `android/app/build.gradle`'s `signingConfigs` to read from
   `key.properties` and reference it in `buildTypes.release.signingConfig`
   (standard Flutter signing setup — see the official guide:
   https://docs.flutter.dev/deployment/android#signing-the-app).
4. Build:
   ```bash
   flutter build apk --release
   ```

### App Bundle for Play Store (recommended distribution format)

```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 8. Files in this delivery that intentionally differ from Flutter defaults

Keep these when merging with a fresh `flutter create` scaffold:

- `android/app/src/main/AndroidManifest.xml` — camera/media permissions, no
  INTERNET permission, ML Kit pose model preload, FileProvider config.
- `android/app/src/main/res/xml/file_paths.xml` — FileProvider paths for
  sharing photos/PDFs.
- `android/app/build.gradle` — `minSdkVersion 23`, Java 17, ProGuard rules
  enabled.
- `android/app/proguard-rules.pro` — keeps ML Kit/TFLite/Hive classes from
  being stripped in release builds.
- Everything under `lib/`.
- `pubspec.yaml`.

---

## 9. Project structure reference

```
lib/
  main.dart                        # entry point, provider wiring, Hive init
  app.dart                         # MaterialApp, theme mode
  core/
    constants/app_constants.dart   # disclaimer text, instructions, anthro ratios
    theme/app_colors.dart          # blue & white brand palette
    theme/app_theme.dart           # Material 3 light/dark ThemeData
    utils/unit_converter.dart      # cm↔inch, kg↔lb formatting
  models/
    body_measurement.dart          # Hive model: all measurements + metadata
    body_measurement.g.dart        # Hive TypeAdapters
  services/
    pose_detection_service.dart    # ML Kit pose landmark wrapper
    measurement_estimation_service.dart  # landmarks -> cm measurements + BMI/shape
    image_service.dart             # camera/gallery capture + local file persistence
    local_storage_service.dart     # Hive CRUD for scan history
    pdf_export_service.dart        # PDF report generation + share
  providers/
    scan_provider.dart             # orchestrates the scan pipeline
    theme_provider.dart            # light/dark/system persistence
  screens/
    splash_screen.dart
    home_screen.dart
    instructions_screen.dart
    scan_screen.dart
    processing_screen.dart
    results_screen.dart
    history_screen.dart
    settings_screen.dart
  widgets/
    gradient_button.dart
    disclaimer_banner.dart
    accuracy_badge.dart
    measurement_card.dart
    body_shape_indicator.dart
```

---

## 10. Known limitations (by design of single-photo 2D estimation)

- **No login/cloud** means there's no server-side ground truth to validate
  against — accuracy depends heavily on the user entering their real height
  and following the on-screen posture/lighting instructions.
- Circumferential measurements (chest/waist/hip/neck) cannot be directly
  observed from one frontal photo; they're derived from measured frontal
  width + population-average depth ratios (documented in
  `measurement_estimation_service.dart`). A future improvement would add a
  **second, side-profile photo** to measure body depth directly and remove
  this assumption.
- Weight and BMI are volume-proxy estimates, not medical-grade
  bioimpedance or DEXA measurements.
- All of this is why the app surfaces an explicit **High/Medium/Low
  accuracy badge** and a persistent disclaimer — see `AppConstants.disclaimerFull`.
