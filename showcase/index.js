import { registerRootComponent } from 'expo';
import App from './App';

// Entry untuk Android/iOS. Versi web ada di index.web.js (butuh Skia via CanvasKit).
registerRootComponent(App);
