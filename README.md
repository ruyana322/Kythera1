# Kythera Flutter
**Video processing app by D4nzxml / JGC**
Konversi total dari Android Kotlin+WebView ke Flutter murni.

---

## Stack

| Layer | Tech |
|-------|------|
| UI | Flutter + Material 3 (no WebView) |
| FFmpeg | `ffmpeg_kit_flutter_min_gpl` ^6.0.3 |
| File picker | `file_picker` ^8.0.0 |
| Permissions | `permission_handler` ^11.3.0 |
| Gallery save | `gallery_saver` ^2.3.2 |

---

## Struktur File

```
lib/
├── main.dart                   ← App entry, Shell (BottomNav + Drawer)
├── theme/
│   └── kythera_theme.dart      ← Color tokens, ThemeData, dekorator
├── widgets/
│   └── kythera_widgets.dart    ← GlassCard, PrimaryButton, DropZone, dll
├── services/
│   ├── ffmpeg_service.dart     ← SEMUA logika FFmpeg (pisah dari UI)
│   └── gallery_service.dart    ← Simpan hasil ke galeri HP
└── screens/
    ├── dashboard_screen.dart
    ├── converter_screen.dart
    ├── compress_screen.dart
    ├── patch_screen.dart
    └── other_screens.dart      ← PhotoEnhance, History, Settings
```

---

## Build (Codespaces / Linux)

```bash
# 1. Install dependencies
flutter pub get

# 2. Build debug APK
flutter build apk --debug

# 3. Build release APK
flutter build apk --release --target-platform android-arm64

# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## FFmpeg Commands — Safeguard `-ignore_unknown`

Semua command FFmpeg di `ffmpeg_service.dart` menggunakan `-ignore_unknown`
sebagai flag wajib sesuai requirement. Flag ini memastikan stream yang tidak
dikenali (misalnya data track aneh dari video sosmed) tidak menyebabkan error fatal.

### Converter
```
-y -ignore_unknown -i <input>
[-vf "scale=W:H:flags=lanczos"]
-c:v <codec> -b:v <N>M
-c:a aac -b:a 192k
-movflags +faststart
<output>
```

### Compress (Two-Pass)
```
# Pass 1:
-y -ignore_unknown -i <input> -c:v libx264 -crf <N> -b:v 0 -pass 1 -an -f mp4 /dev/null

# Pass 2:
-y -ignore_unknown -i <input> -c:v libx264 -crf <N> -b:v 0 -pass 2
[-c:a aac -b:a 128k] [-map_metadata -1]
-movflags +faststart <output>
```

### Patch Metadata (no re-encode)
```
-y -ignore_unknown -i <input>
-c copy
-metadata title="..." -metadata description="..."
-metadata artist="..." -metadata date="..."
-movflags +faststart <output>
```

### Patch Watermark
```
-y -ignore_unknown -i <input>
-vf "drawtext=text='<text>':fontcolor=white@0.6:fontsize=28:x=w-tw-20:y=h-th-20:shadowcolor=black:shadowx=1:shadowy=1"
-c:a copy -movflags +faststart <output>
```

---

## Catatan

- Photo Enhance screen adalah **UI placeholder** — AI upscaling (NCNN Vulkan)
  diimplementasikan terpisah via Kythera Video AI native pipeline.
- Output video disimpan ke `Movies/Kythera` di galeri HP via `gallery_saver`.
- Temp file di `getExternalStorageDirectory()` dihapus otomatis setelah disalin ke galeri.
- `IndexedStack` dipakai untuk navigation agar state tiap screen tidak reset saat pindah tab.
