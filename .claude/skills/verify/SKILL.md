---
name: verify
description: How to build, run, and observe the KneaYerng backend (Laravel) and mobile app (Flutter) on this machine to verify changes end-to-end.
---

# Verifying changes in this repo

## Backend (Laravel, `backend/`)

- `backend/.env` points at a **local MySQL** (127.0.0.1, db_ky_servicercenter) that is up and has real-ish data (~11 products). Safe to query/serve locally.
- Start: `cd backend && php artisan serve --port=8010` (port 8000 is often taken by the user's own serve session).
- Drive the API with curl against `http://127.0.0.1:8010/api/...`.
- Quick DB inspection/mutation: `php artisan tinker --execute="..."`. If you mutate rows for a test, revert them afterward.
- Production is the tracked `backend/.env.docker` deploy (see memory); local `php artisan serve` never touches it.

## Mobile app (Flutter, `app_ky_service_center/`)

- `flutter analyze <files>` works; full builds:
  - **Windows desktop build FAILS** on this machine: MSB3491 path-length (MAX_PATH 260) error in `flutter_local_notifications_windows` because the repo path is long. Don't bother.
  - **Chrome/web runs** but backend CORS only allows `https://kneayerng.seavminh.com` origins, and the app start flow needs a tap ("Skip" on onboarding) that headless Chrome can't do. Also avoid visible Chrome — it opens on the user's desktop.
  - **Android device is the reliable surface.** A physical phone is usually attached (check `flutter devices`). adb lives at `C:/Users/Asus/AppData/Local/Android/Sdk/platform-tools/adb.exe` (not on PATH in Git Bash).
- Recipe for pointing the device app at a local backend:
  1. `flutter build apk --debug` then `adb install -r build/app/outputs/flutter-apk/app-debug.apk` (package `com.kneayerng.app_ky_service_center`; debug keystore matches the dev install already on the phone).
  2. `--dart-define=API_BASE_URL=...` did NOT reliably bake into the APK here. Instead inject the app's runtime pref via run-as (debug build):
     add `<string name="flutter.api_base_url">http://127.0.0.1:8010/api</string>` into `shared_prefs/FlutterSharedPreferences.xml`, with `adb shell run-as com.kneayerng.app_ky_service_center ...` and sed.
  3. `adb reverse tcp:8010 tcp:8010` so the phone's 127.0.0.1:8010 reaches the host.
  4. Launch: `adb shell am start -n com.kneayerng.app_ky_service_center/.MainActivity`.
  5. Observe: `adb exec-out screencap -p > shot.png`, logs via `adb logcat -d -s flutter` (ApiService prints "Using server URL -> ..." and cache-key lines that reveal which requests ran).
  6. **Cleanup is mandatory**: remove the injected `flutter.api_base_url` pref (or the user's app is left pointing at a dead localhost server), `adb reverse --remove tcp:8010`, and stop the artisan serve.
- Gotchas: the phone may lock (Bouncer) mid-session — you cannot bypass the PIN; capture what you need early. App start flow: valid token → home, else onboarding (has a Skip → home). ApiService caches responses in SharedPreferences; cache keys include the fetch params.
