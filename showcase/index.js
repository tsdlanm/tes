import { Platform } from 'react-native';
import { registerRootComponent } from 'expo';

// Di web, Skia butuh CanvasKit (WebAssembly) dimuat dulu sebelum App dirender.
if (Platform.OS === 'web') {
  const { LoadSkiaWeb } = require('@shopify/react-native-skia/lib/module/web');
  LoadSkiaWeb({ locateFile: (file) => `/${file}` }).then(() => {
    registerRootComponent(require('./App').default);
  });
} else {
  registerRootComponent(require('./App').default);
}
