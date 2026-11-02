# Flutter UI Showcase

Aplikasi demo Flutter yang memamerkan animasi, gestur, komponen, layout, dan grafik
(tanpa package tambahan, hanya SDK Flutter).

```bash
flutter pub get
flutter run                      # perangkat / emulator
flutter run -d chrome            # pratinjau web
flutter build web --no-web-resources-cdn
```

Tab: Animasi · Gestur · Komponen · Layout · Grafik · **Pro** · **Form** · **Navigasi** · **Beban**. Tema gelap/terang lewat Switch di header.

- **Pro** adalah padanan tab Pro versi React Native (yang di sana butuh Reanimated, Gesture Handler,
  dan Skia): fling, cubit/putar, AnimatedList, dan gooey metaballs — semuanya dari SDK bawaan.
- **Form** berisi form pendaftaran (Form/TextFormField, validator, alur fokus, date picker) dan dialog adaptif Material vs Cupertino.
- **Navigasi** memakai Navigator bersarang: push dengan Hero, route Cupertino, dan modal dari bawah.
- **Beban** berisi uji performa yang sama persis dengan versi React Native (branch `ccr-287aec81-nbw7kd`):
  FPS & waktu frame, daftar 5.000 item, animasi massal, dan kerja berat di UI isolate vs `compute()`.
  Ukur dengan `flutter run --profile` di HP asli; mode debug dan browser tidak mewakili.
