# DocWriter

A small cross-platform mobile app (Android + iOS) built with **Flutter**.
Write a document, then **print** it or **save / share it as a PDF**.

## Features

- Write a document with a title and body, saved on the device.
- List, open, and delete your saved documents.
- **Print** — sends the document straight to the system print dialog.
- **Save / Share PDF** — generates a PDF and opens the native share sheet
  (Save to Files, Google Drive, email, WhatsApp, and so on).

## How it works

| Layer | File | Responsibility |
| --- | --- | --- |
| Model | `lib/models/doc.dart` | A single document + JSON (de)serialisation |
| Storage | `lib/services/storage_service.dart` | Reads/writes documents as JSON files in the app documents directory |
| PDF | `lib/services/pdf_service.dart` | Builds a PDF with the `pdf` package; prints/shares it with `printing` |
| UI | `lib/screens/home_screen.dart` | Document list, create, delete |
| UI | `lib/screens/editor_screen.dart` | Title + body editor, save, print, export |

## Getting started

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

```bash
git clone https://github.com/harsh96483517-code/doc-writer.git
cd doc-writer

# This repository ships the Dart source and config.
# Generate the Android/iOS platform folders for your machine:
flutter create .

flutter pub get
flutter run
```

`flutter create .` only adds the missing `android/`, `ios/`, `web/`, etc.
platform folders — it will not overwrite `lib/`, `pubspec.yaml`, or the
`.github/` workflows.

## Build a release APK

```bash
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk
```

## CI / CD

- `.github/workflows/ci.yml` — on every push/PR to `main`: `flutter analyze`
  and `flutter test`.
- `.github/workflows/release.yml` — on a version tag (e.g. `v1.0.0`): builds a
  release APK and attaches it to a GitHub Release.

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Project layout

```
lib/
  main.dart                 # app entry point + theme
  models/doc.dart           # document model
  services/
    storage_service.dart    # local persistence
    pdf_service.dart        # PDF build + print + share
  screens/
    home_screen.dart        # document list
    editor_screen.dart      # editor
test/widget_test.dart       # smoke test
```

## License

MIT
