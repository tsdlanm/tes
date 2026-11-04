import { registerRootComponent } from 'expo';
import { LoadSkiaWeb } from '@shopify/react-native-skia/lib/module/web';
import App from './App';

// Di web, Skia butuh CanvasKit (WebAssembly) dimuat dulu sebelum App dirender.
// File ini hanya dipakai bundler web, jadi `canvaskit.js` (yang memakai `fs`)
// tidak ikut ke bundle Android/iOS.
LoadSkiaWeb({ locateFile: (file) => `/${file}` }).then(() => registerRootComponent(App));
