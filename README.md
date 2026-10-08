# DocWriter

A small cross-platform mobile app (Android + iOS) built with **Flutter**.
Write a document **or a formal letter**, then **print** it or **save / share it
as a PDF**. Documents can be written in **Hindi (Devanagari)** as well as English.

## Features

- Two templates: a **blank document** and a **letter**.
- **Hindi / Devanagari support** — the PDF embeds Noto Sans Devanagari, so Hindi
  text renders as real glyphs instead of blank boxes.
- **Print** — sends the document straight to the system print dialog.
- **Save / Share PDF** — generates a PDF and opens the native share sheet
  (Save to Files, Google Drive, email, WhatsApp, and so on).
- Documents are stored on the device and can be reopened or deleted.

## The letter template

A letter has dedicated fields, laid out as a formal letter in the PDF:

- Your name and address (top)
- Date (right-aligned, filled automatically)
- Recipient name and address
- Subject
- Salutation (defaults to "Dear Sir/Madam,")
- Body
- Closing (defaults to "Yours sincerely,")
- Your name again, as the signature block

## Hindi / Devanagari support

The PDF engine's built-in fonts contain no Devanagari glyphs, so the app bundles
Unicode fonts in `assets/fonts/`:

| File | Purpose |
| --- | --- |
| `NotoSans-Regular.ttf` / `NotoSans-Bold.ttf` | Base Latin font |
| `NotoSansDevanagari-Regular.ttf` / `NotoSansDevanagari-Bold.ttf` | Devanagari fallback |

`PdfService` registers Devanagari as a **font fallback**, so any Hindi characters
in a document are rendered with the right font automatically — no extra work for
the user.

> Note: on-screen typing of Hindi works out of the box (Flutter uses the system
> keyboard and text engine). For the **PDF**, complex-script shaping in the pure
> Dart `pdf` engine can be imperfect for some conjuncts and vowel signs, so give
> Hindi PDF output a quick visual check on your target devices.

## How it works

| Layer | File | Responsibility |
| --- | --- | --- |
| Model | `lib/models/doc.dart` | A document/letter + JSON (de)serialisation |
| Storage | `lib/services/storage_service.dart` | Reads/writes documents as JSON files in the app documents directory |
| PDF | `lib/services/pdf_service.dart` | Embeds fonts, builds the PDF, prints/shares it |
| UI | `lib/screens/home_screen.dart` | Document list, create (document or letter), delete |
| UI | `lib/screens/editor_screen.dart` | Editor: plain form or letter form, save, print, export |

## Getting started

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

```bash
git clone https://github.com/harsh96483517-code/doc-writer.git
cd doc-writer

# This repository ships the Dart source, config, and fonts.
# Generate the Android/iOS platform folders for your machine:
flutter create .

flutter pub get
flutter run
```

`flutter create .` only adds the missing `android/`, `ios/`, `web/`, etc.
platform folders — it will not overwrite `lib/`, `assets/`, `pubspec.yaml`, or
the `.github/` workflows.

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
git tag v1.1.0
git push origin v1.1.0
```

## Project layout

```
assets/fonts/               # bundled Noto Sans + Noto Sans Devanagari
lib/
  main.dart                 # app entry point + theme
  models/doc.dart           # document / letter model
  services/
    storage_service.dart    # local persistence
    pdf_service.dart        # fonts + PDF build + print + share
  screens/
    home_screen.dart        # document list
    editor_screen.dart      # editor (plain + letter)
test/widget_test.dart       # smoke test
```

## License

MIT
