# RN UI Showcase

Aplikasi demo (Expo / React Native) yang memamerkan banyak kemampuan UI dan animasi.

```bash
npm install
npx expo start        # scan QR dengan Expo Go
npx expo start --web  # pratinjau di browser
```

Tab: Animasi · Gestur · Komponen · Layout · Grafik · **Pro** · **Beban**. Tema gelap/terang lewat Switch di header.

- Lima tab pertama hanya memakai API inti React Native + `expo-linear-gradient`.
- **Pro** memakai library yang umum di proyek sungguhan: `react-native-reanimated`,
  `react-native-gesture-handler`, dan `@shopify/react-native-skia`.
- **Beban** berisi uji performa yang sama persis dengan versi Flutter (branch `flutter-showcase`):
  FPS meter, daftar 5.000 item, animasi massal, dan simulasi thread sibuk.
  Jalankan di HP asli; hasil di browser tidak mewakili.

`npm install` otomatis menyalin `canvaskit.wasm` ke `public/` (dibutuhkan Skia di web).
