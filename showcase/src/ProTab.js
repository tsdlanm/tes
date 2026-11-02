import React, { useEffect, useMemo, useRef, useState } from 'react';
import { View, Text, Pressable } from 'react-native';
import Animated, {
  useSharedValue, useAnimatedStyle, useDerivedValue, withSpring, withDecay, withTiming,
  Easing, ZoomIn, ZoomOut, LinearTransition,
} from 'react-native-reanimated';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import {
  Canvas, Circle, Group, Blur, ColorMatrix, Paint, BackdropBlur, Fill, RoundedRect,
  LinearGradient, Path, Skia, useClock, vec, rect, rrect,
} from '@shopify/react-native-skia';
import { Section, Btn, useTheme, glow, dragStyle } from './ui';

/* 1. Pan + fling (withDecay) + double-tap reset — semua di UI thread --- */
function FlingDemo() {
  const t = useTheme();
  const [w, setW] = useState(300);
  const H = 210, S = 90;
  const bx = Math.max(0, (w - S) / 2), by = (H - S) / 2;
  const x = useSharedValue(0), y = useSharedValue(0);
  const sx = useSharedValue(0), sy = useSharedValue(0), sc = useSharedValue(1);

  const pan = Gesture.Pan()
    .onBegin(() => {
      sx.value = x.value;
      sy.value = y.value;
      sc.value = withSpring(1.12);
    })
    .onUpdate((e) => {
      x.value = sx.value + e.translationX;
      y.value = sy.value + e.translationY;
    })
    .onEnd((e) => {
      x.value = withDecay({ velocity: e.velocityX, clamp: [-bx, bx], rubberBandEffect: true });
      y.value = withDecay({ velocity: e.velocityY, clamp: [-by, by], rubberBandEffect: true });
    })
    .onFinalize(() => {
      sc.value = withSpring(1);
    });
  const reset = Gesture.Tap().numberOfTaps(2).onEnd(() => {
    x.value = withSpring(0);
    y.value = withSpring(0);
  });

  const style = useAnimatedStyle(() => ({
    transform: [
      { translateX: x.value }, { translateY: y.value },
      { scale: sc.value }, { rotate: `${x.value / 8}deg` },
    ],
  }));

  return (
    <View
      onLayout={(e) => setW(e.nativeEvent.layout.width)}
      style={{ height: H, borderRadius: 20, backgroundColor: t.card2, alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }}
    >
      <Text style={{ position: 'absolute', top: 12, color: t.sub, fontSize: 12 }}>Lempar kartunya · ketuk 2x untuk kembali</Text>
      <GestureDetector gesture={Gesture.Exclusive(reset, pan)}>
        <Animated.View
          style={[
            dragStyle,
            { width: S, height: S, borderRadius: 26, backgroundColor: t.a, alignItems: 'center', justifyContent: 'center' },
            glow(t.a), style,
          ]}
        >
          <Text style={{ fontSize: 36 }}>🥏</Text>
        </Animated.View>
      </GestureDetector>
    </View>
  );
}

/* 2. Pinch + rotate + pan bersamaan ------------------------------------ */
function PinchDemo() {
  const t = useTheme();
  const scale = useSharedValue(1), savedS = useSharedValue(1);
  const rot = useSharedValue(0), savedR = useSharedValue(0);
  const tx = useSharedValue(0), ty = useSharedValue(0), stx = useSharedValue(0), sty = useSharedValue(0);

  const pinch = Gesture.Pinch()
    .onUpdate((e) => { scale.value = Math.min(3, Math.max(0.5, savedS.value * e.scale)); })
    .onEnd(() => { savedS.value = scale.value; });
  const rotate = Gesture.Rotation()
    .onUpdate((e) => { rot.value = savedR.value + e.rotation; })
    .onEnd(() => { savedR.value = rot.value; });
  const pan = Gesture.Pan()
    .onBegin(() => { stx.value = tx.value; sty.value = ty.value; })
    .onUpdate((e) => { tx.value = stx.value + e.translationX; ty.value = sty.value + e.translationY; });
  const reset = Gesture.Tap().numberOfTaps(2).onEnd(() => {
    scale.value = withSpring(1); savedS.value = 1;
    rot.value = withSpring(0); savedR.value = 0;
    tx.value = withSpring(0); ty.value = withSpring(0);
  });

  const style = useAnimatedStyle(() => ({
    transform: [
      { translateX: tx.value }, { translateY: ty.value },
      { scale: scale.value }, { rotate: `${rot.value}rad` },
    ],
  }));

  return (
    <View style={{ height: 220, borderRadius: 20, backgroundColor: t.card2, alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }}>
      <Text style={{ position: 'absolute', top: 12, color: t.sub, fontSize: 12 }}>Di HP: cubit & putar dengan dua jari</Text>
      <GestureDetector gesture={Gesture.Race(reset, Gesture.Simultaneous(pinch, rotate, pan))}>
        <Animated.View style={[dragStyle, { width: 150, height: 100, borderRadius: 22, overflow: 'hidden' }, glow(t.c), style]}>
          <View style={{ flex: 1, backgroundColor: t.c, alignItems: 'center', justifyContent: 'center' }}>
            <Text style={{ fontSize: 38 }}>🖼️</Text>
          </View>
        </Animated.View>
      </GestureDetector>
    </View>
  );
}

/* 3. Layout animation (entering / exiting / layout) -------------------- */
function LayoutAnimDemo() {
  const t = useTheme();
  const [items, setItems] = useState([1, 2, 3, 4, 5]);
  const next = useRef(6);
  const cols = [t.a, t.b, t.c, t.d, t.e];
  const add = () =>
    setItems((p) => {
      const at = Math.floor(Math.random() * (p.length + 1));
      return [...p.slice(0, at), next.current++, ...p.slice(at)];
    });
  const shuffle = () => setItems((p) => [...p].sort(() => Math.random() - 0.5));
  return (
    <View>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8, minHeight: 90 }}>
        {items.map((i) => (
          <Animated.View key={i} entering={ZoomIn.springify()} exiting={ZoomOut} layout={LinearTransition.springify()}>
            <Pressable
              onPress={() => setItems((p) => p.filter((x) => x !== i))}
              style={{ backgroundColor: cols[i % 5], paddingVertical: 10, paddingHorizontal: 14, borderRadius: 14 }}
            >
              <Text style={{ color: '#fff', fontWeight: '800' }}>#{i} ✕</Text>
            </Pressable>
          </Animated.View>
        ))}
      </View>
      <View style={{ flexDirection: 'row', gap: 10, marginTop: 14 }}>
        <Btn small label="Tambah" onPress={add} />
        <Btn small label="Acak" colors={[t.b, t.a]} onPress={shuffle} />
      </View>
    </View>
  );
}

/* 4. Skia: gooey metaballs + blob yang bisa diseret -------------------- */
const GOOEY = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 18, -7];
function GooeyDemo() {
  const t = useTheme();
  const [w, setW] = useState(0);
  const H = 220;
  const clock = useClock();
  const px = useSharedValue(150), py = useSharedValue(H / 2);
  useEffect(() => {
    if (w) { px.value = w * 0.75; py.value = H / 2; }
  }, [w]);
  const c1x = useDerivedValue(() => w / 2 + Math.cos(clock.value / 900) * w * 0.28);
  const c1y = useDerivedValue(() => H / 2 + Math.sin(clock.value / 700) * 50);
  const c2x = useDerivedValue(() => w / 2 + Math.sin(clock.value / 1100) * w * 0.3);
  const c2y = useDerivedValue(() => H / 2 + Math.cos(clock.value / 800) * 55);
  const c3x = useDerivedValue(() => w / 2 + Math.cos(clock.value / 1300 + 2) * w * 0.2);
  const c3y = useDerivedValue(() => H / 2 + Math.sin(clock.value / 600 + 1) * 40);
  const pan = Gesture.Pan().onChange((e) => {
    px.value += e.changeX;
    py.value += e.changeY;
  });
  return (
    <GestureDetector gesture={pan}>
      <View
        onLayout={(e) => setW(e.nativeEvent.layout.width)}
        style={[dragStyle, { height: H, borderRadius: 20, overflow: 'hidden', backgroundColor: t.card2 }]}
      >
        {w > 0 && (
          <Canvas style={{ width: w, height: H }}>
            <Group layer={<Paint><Blur blur={14} /><ColorMatrix matrix={GOOEY} /></Paint>}>
              <Circle cx={c1x} cy={c1y} r={36} color={t.a} />
              <Circle cx={c2x} cy={c2y} r={30} color={t.b} />
              <Circle cx={c3x} cy={c3y} r={26} color={t.e} />
              <Circle cx={px} cy={py} r={42} color={t.c} />
            </Group>
          </Canvas>
        )}
        <Text pointerEvents="none" style={{ position: 'absolute', top: 12, alignSelf: 'center', color: t.sub, fontSize: 12 }}>
          Seret di area ini untuk menggerakkan blob pink
        </Text>
      </View>
    </GestureDetector>
  );
}

/* 5. Skia: glass (BackdropBlur) di atas latar bergerak ----------------- */
function GlassDemo() {
  const [w, setW] = useState(0);
  const H = 190;
  const clock = useClock();
  const ax = useDerivedValue(() => w * 0.3 + Math.sin(clock.value / 1000) * 60);
  const bx = useDerivedValue(() => w * 0.7 + Math.cos(clock.value / 1200) * 60);
  const cy = useDerivedValue(() => H / 2 + Math.sin(clock.value / 800) * 50);
  const card = useMemo(() => rrect(rect(w / 2 - 120, H / 2 - 52, 240, 104), 20, 20), [w]);
  return (
    <View onLayout={(e) => setW(e.nativeEvent.layout.width)} style={{ height: H, borderRadius: 22, overflow: 'hidden' }}>
      {w > 0 && (
        <Canvas style={{ width: w, height: H }}>
          <Fill color="#1B1446" />
          <Circle cx={ax} cy={50} r={60} color="#FF6B9A" />
          <Circle cx={bx} cy={H - 40} r={70} color="#22D3EE" />
          <Circle cx={w / 2} cy={cy} r={34} color="#FBBF24" />
          <BackdropBlur blur={14} clip={card}>
            <Fill color="rgba(255,255,255,0.14)" />
          </BackdropBlur>
          <RoundedRect rect={card} color="rgba(255,255,255,0.4)" style="stroke" strokeWidth={1} />
        </Canvas>
      )}
      <View pointerEvents="none" style={{ position: 'absolute', top: 0, bottom: 0, left: 0, right: 0, alignItems: 'center', justifyContent: 'center' }}>
        <Text style={{ color: '#fff', fontSize: 18, fontWeight: '800' }}>Kaca buram ✨</Text>
        <Text style={{ color: '#ffffffbb', fontSize: 12.5, marginTop: 4 }}>BackdropBlur dari Skia</Text>
      </View>
    </View>
  );
}

/* 6. Skia: grafik garis Bezier yang digambar bertahap ------------------ */
const LINE = [0.3, 0.55, 0.42, 0.7, 0.62, 0.9, 0.78, 0.95];
function SkiaLine() {
  const t = useTheme();
  const [w, setW] = useState(0);
  const [k, setK] = useState(0);
  const H = 150;
  const progress = useSharedValue(0);
  const { line, area } = useMemo(() => {
    const pts = LINE.map((v, i) => [8 + (i / (LINE.length - 1)) * (w - 16), H - 12 - v * (H - 28)]);
    // Skia 2: SkPath tidak bisa diubah, jadi dibangun lewat PathBuilder.
    const b = Skia.PathBuilder.Make();
    b.moveTo(pts[0][0], pts[0][1]);
    for (let i = 0; i < pts.length - 1; i++) {
      const [ax, ay] = pts[i], [bx, by] = pts[i + 1];
      const mx = (ax + bx) / 2;
      b.cubicTo(mx, ay, mx, by, bx, by);
    }
    const line = b.build();
    b.lineTo(pts[pts.length - 1][0], H);
    b.lineTo(pts[0][0], H);
    b.close();
    return { line, area: b.detach() };
  }, [w]);
  useEffect(() => {
    if (!w) return;
    progress.value = 0;
    progress.value = withTiming(1, { duration: 1700, easing: Easing.inOut(Easing.cubic) });
  }, [w, k]);
  return (
    <View>
      <View onLayout={(e) => setW(e.nativeEvent.layout.width)} style={{ height: H }}>
        {w > 0 && (
          <Canvas style={{ width: w, height: H }}>
            {[0.25, 0.5, 0.75].map((g) => (
              <Path key={g} path={`M 0 ${H * g} L ${w} ${H * g}`} color={t.line} style="stroke" strokeWidth={1} />
            ))}
            <Path path={area} opacity={progress}>
              <LinearGradient start={vec(0, 0)} end={vec(0, H)} colors={[t.b + '66', t.b + '00']} />
            </Path>
            <Path path={line} color={t.b} style="stroke" strokeWidth={3.5} strokeCap="round" end={progress} />
          </Canvas>
        )}
      </View>
      <Pressable onPress={() => setK((n) => n + 1)} style={{ alignSelf: 'flex-start', marginTop: 10 }}>
        <Text style={{ color: t.b, fontWeight: '800', fontSize: 13 }}>↻ Gambar ulang</Text>
      </Pressable>
    </View>
  );
}

export default function ProTab() {
  const t = useTheme();
  return (
    <>
      <View style={{ backgroundColor: t.card2, borderRadius: 18, padding: 14, marginBottom: 16 }}>
        <Text style={{ color: t.ink, fontWeight: '800' }}>⚡ Library yang dipakai proyek RN sungguhan</Text>
        <Text style={{ color: t.sub, fontSize: 12.5, lineHeight: 19, marginTop: 4 }}>
          react-native-reanimated, react-native-gesture-handler, dan @shopify/react-native-skia.
          Di HP, animasi & gestur di tab ini berjalan di UI thread, bukan di JS thread.
        </Text>
      </View>
      <Section title="Lempar (fling)" hint="Gesture.Pan + withDecay + rubber band — momentum seperti iOS"><FlingDemo /></Section>
      <Section title="Cubit, putar, geser" hint="Gesture.Simultaneous(Pinch, Rotation, Pan)"><PinchDemo /></Section>
      <Section title="Layout animation" hint="entering / exiting / layout — item lain bergeser otomatis"><LayoutAnimDemo /></Section>
      <Section title="Gooey metaballs (Skia)" hint="Blur + ColorMatrix pada layer, posisi dari useClock"><GooeyDemo /></Section>
      <Section title="Glassmorphism (Skia)" hint="BackdropBlur di atas lingkaran yang bergerak"><GlassDemo /></Section>
      <Section title="Grafik garis (Skia)" hint="Path Bezier + gradient, prop `end` dianimasikan Reanimated"><SkiaLine /></Section>
    </>
  );
}
