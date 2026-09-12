# Safiri Holidays - Security & Secret Management Guide

This document outlines the security architecture and procedures for configuring, building, and deploying the Safiri Holidays Flutter application securely.

---

## 1. Secrets Management Architecture

To prevent API credentials and backend endpoints from being exposed in public code repositories or decompiled binaries, Safiri Holidays utilizes compile-time environment injection (`--dart-define-from-file`).

### How It Works:
* **`secrets.json`** (Ignored by Git): Stores your active environment variables locally. **Never commit this file.**
* **`secrets.example.json`** (Tracked by Git): A template file indicating required keys.
* **`lib/core/services/supabase_service.dart`**: Reads these values at compile-time via `const String.fromEnvironment(...)`.

### Available Environment Variables:
| Variable Name | Description | Example Value |
| :--- | :--- | :--- |
| `API_BASE_URL` | Base URL for the Railway Node.js backend | `https://safiri-holidays-production.up.railway.app` |
| `SUPABASE_PROJECT_URL` | Supabase Cloud project URL | `https://xyzcompany.supabase.co` |
| `SUPABASE_ANON_KEY` | Public client-side anonymous key | *(JWT token from Supabase)* |
| `IS_PRODUCTION` | Flag indicating production environment | `"true"` or `"false"` |
| `LOCAL_API_DOMAIN` | Android Emulator local backend endpoint | `http://10.0.2.2:5000` |
| `WEB_API_DOMAIN` | Local web development endpoint | `http://localhost:5000` |

---

## 2. Running the Application Locally

### Option A: Using VS Code / IDE (Recommended)
Launch configurations are pre-configured in `.vscode/launch.json`.
1. Press `F5` or select **Run -> Start Debugging** from the top menu.
2. Select **Safiri Holidays (Debug with Secrets)**.
3. VS Code automatically passes `--dart-define-from-file=secrets.json`.

### Option B: Using the Command Line
```bash
# Debug Mode
flutter run --dart-define-from-file=secrets.json

# Run on a specific device (e.g. Chrome or Android emulator)
flutter run -d chrome --dart-define-from-file=secrets.json
flutter run -d android --dart-define-from-file=secrets.json
```

---

## 3. Building Obfuscated Release Binaries

When compiling the application for release (APK, App Bundle, or iOS IPA), always enable Flutter's built-in **code obfuscation** to strip symbols and protect reverse engineering:

```bash
# Android App Bundle (Google Play Store)
flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=secrets.json

# Android APK
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=secrets.json

# iOS Release (macOS required)
flutter build ipa --obfuscate --split-debug-info=build/ios/symbols --dart-define-from-file=secrets.json

# Web Production
flutter build web --release --dart-define-from-file=secrets.json
```

> [!TIP]
> Keep the generated `symbols/` directory safe for your release version so you can de-obfuscate crash stack traces using `flutter symbolize`.

---

## 4. Key Rotation Instructions (Action Required)

If your previous API keys were ever committed to a public or shared GitHub/GitLab repository, you must rotate them immediately:

### Rotating Supabase Anon Key:
1. Log in to your [Supabase Dashboard](https://supabase.com/dashboard).
2. Open your Safiri Holidays project.
3. Navigate to **Project Settings** (cog icon on left) -> **API**.
4. Scroll to **JWT Settings** / **API Keys**.
5. Click **Generate New API Secret** or **Reset API Keys**.
6. Copy the new `anon` `public` key and update your local `secrets.json`.

### Railway / Server Secrets:
* Ensure high-privilege keys (e.g., Supabase `service_role` key, payment gateway private API keys, Duffel production API token) are **ONLY** configured as environment variables in the **Railway Dashboard** -> **Variables**.
* High-privilege secrets must **never** be placed in `secrets.json` or client-side Flutter code.

---

## 5. Network Security & Cleartext Traffic

In `android/app/src/main/AndroidManifest.xml`, `android:usesCleartextTraffic="true"` is currently enabled to facilitate local development against `http://10.0.2.2:5000`.

For official Google Play production releases:
1. Create a `network_security_config.xml` in `android/app/src/main/res/xml/` to restrict cleartext HTTP strictly to `localhost` and `10.0.2.2`.
2. Ensure production network communications are 100% strictly enforced over `https://`.
