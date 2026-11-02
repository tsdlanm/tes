import React, { memo, useEffect, useMemo, useRef, useState } from 'react';
import { View, Text, FlatList, Animated as RNAnimated, Easing as RNEasing, Platform } from 'react-native';
import Animated, {
  useSharedValue, useAnimatedStyle, useFrameCallback, withRepeat, withTiming, Easing, cancelAnimation,
} from 'react-native-reanimated';
import { scheduleOnRN } from 'react-native-worklets';
import { Section, Pill, Btn, useTheme } from './ui';

const fpsColor = (f) => (f >= 50 ? '#34D399' : f >= 30 ? '#FBBF24' : '#FF4D6D');

/* FPS meter: UI thread (useFrameCallback) dan JS thread (requestAnimationFrame) */
function FpsMeter() {
  const t = useTheme();
  const [ui, setUi] = useState(0);
  const [js, setJs] = useState(0);
  const uiFps = useSharedValue(0);
  const frames = useSharedValue(0);
  const last = useSharedValue(0);

  useFrameCallback((f) => {
    frames.value += 1;
    if (last.value === 0) last.value = f.timestamp;
    const dt = f.timestamp - last.value;
    if (dt >= 500) {
      uiFps.value = (frames.value * 1000) / dt;
      frames.value = 0;
      last.value = f.timestamp;
      scheduleOnRN(setUi, Math.round(uiFps.value));
    }
  });

  useEffect(() => {
    let n = 0, l = performance.now(), id;
    const loop = (now) => {
      n++;
      if (now - l >= 500) {
        setJs(Math.round((n * 1000) / (now - l)));
        n = 0;
        l = now;
      }
      id = requestAnimationFrame(loop);
    };
    id = requestAnimationFrame(loop);
    return () => cancelAnimationFrame(id);
  }, []);

  // Bar ini di-update langsung dari UI thread, tetap bergerak walau JS sibuk.
  const uiBar = useAnimatedStyle(() => ({
    width: `${Math.min(100, (uiFps.value / 60) * 100)}%`,
    backgroundColor: uiFps.value >= 50 ? '#34D399' : uiFps.value >= 30 ? '#FBBF24' : '#FF4D6D',
  }));

  const Meter = ({ label, value, bar }) => (
    <View style={{ flex: 1, backgroundColor: t.card2, borderRadius: 16, padding: 12 }}>
      <Text style={{ color: t.sub, fontSize: 11.5, fontWeight: '800' }}>{label}</Text>
      <Text style={{ color: fpsColor(value), fontSize: 30, fontWeight: '800' }}>
        {value}<Text style={{ fontSize: 13, color: t.sub }}> fps</Text>
      </Text>
      <View style={{ height: 6, borderRadius: 3, backgroundColor: t.line, overflow: 'hidden', marginTop: 4 }}>
        {bar || <View style={{ height: 6, width: `${Math.min(100, (value / 60) * 100)}%`, backgroundColor: fpsColor(value) }} />}
      </View>
    </View>
  );

  return (
    <View style={{ flexDirection: 'row', gap: 10 }}>
      <Meter label="UI THREAD" value={ui} bar={<Animated.View style={[{ height: 6 }, uiBar]} />} />
      <Meter label="JS THREAD" value={js} />
    </View>
  );
}

/* Daftar 5.000 item ---------------------------------------------------- */
const NAMES = ['Adi', 'Ayu', 'Bagas', 'Bunga', 'Citra', 'Dewi', 'Dimas', 'Eka', 'Fajar', 'Gita', 'Hana', 'Indra', 'Joko', 'Kirana', 'Lukman', 'Maya', 'Nanda', 'Oki', 'Putri', 'Rangga'];
const COLORS = ['#7C5CFF', '#22D3EE', '#FF6B9A', '#FBBF24', '#34D399'];
const ROW_H = 64;

const Row = memo(function Row({ item }) {
  const t = useTheme();
  return (
    <View style={{ height: ROW_H, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 12, gap: 12, borderBottomWidth: 1, borderBottomColor: t.line }}>
      <View style={{ width: 40, height: 40, borderRadius: 20, backgroundColor: item.color, alignItems: 'center', justifyContent: 'center' }}>
        <Text style={{ color: '#fff', fontWeight: '800' }}>{item.name[0]}</Text>
      </View>
      <View style={{ flex: 1 }}>
        <Text style={{ color: t.ink, fontWeight: '700', fontSize: 14.5 }} numberOfLines={1}>{item.name}</Text>
        <Text style={{ color: t.sub, fontSize: 12 }}>Transaksi #{item.id + 1}</Text>
      </View>
      <View style={{ alignItems: 'flex-end' }}>
        <Text style={{ color: item.in ? '#34D399' : t.ink, fontWeight: '800', fontSize: 14 }}>
          {item.in ? '+' : '−'}Rp {item.amount.toLocaleString('id-ID')}
        </Text>
        <View style={{ backgroundColor: item.color + '33', borderRadius: 8, paddingHorizontal: 6, paddingVertical: 1, marginTop: 3 }}>
          <Text style={{ color: item.color, fontSize: 10, fontWeight: '800' }}>{item.tag}</Text>
        </View>
      </View>
    </View>
  );
});

function BigList() {
  const t = useTheme();
  const ref = useRef(null);
  const data = useMemo(
    () =>
      Array.from({ length: 5000 }, (_, i) => ({
        id: i,
        name: `${NAMES[i % NAMES.length]} ${NAMES[(i * 7) % NAMES.length]}`,
        color: COLORS[i % COLORS.length],
        amount: ((i * 7919) % 990) * 1000 + 10000,
        in: i % 3 === 0,
        tag: ['Belanja', 'Gaji', 'Transfer', 'Tagihan'][i % 4],
      })),
    []
  );
  return (
    <View>
      <View style={{ height: 380, borderRadius: 18, overflow: 'hidden', backgroundColor: t.card2 }}>
        <FlatList
          ref={ref}
          data={data}
          keyExtractor={(i) => String(i.id)}
          renderItem={({ item }) => <Row item={item} />}
          getItemLayout={(_, i) => ({ length: ROW_H, offset: ROW_H * i, index: i })}
          initialNumToRender={12}
          windowSize={7}
          maxToRenderPerBatch={20}
          removeClippedSubviews={Platform.OS !== 'web'}
          nestedScrollEnabled
        />
      </View>
      <View style={{ flexDirection: 'row', gap: 10, marginTop: 12 }}>
        <Btn small label="Lompat ke #4000" onPress={() => ref.current?.scrollToIndex({ index: 3999, animated: true })} />
        <Btn small label="Ke atas" colors={[t.b, t.a]} onPress={() => ref.current?.scrollToOffset({ offset: 0, animated: true })} />
      </View>
    </View>
  );
}

/* Animasi massal ------------------------------------------------------- */
const BOX = 16;

const ReaBox = memo(function ReaBox({ i, p }) {
  const phase = (i * 0.137) % 1;
  const style = useAnimatedStyle(() => {
    const v = (p.value + phase) % 1;
    return {
      transform: [{ rotate: `${v * 360}deg` }, { scale: 0.7 + 0.4 * Math.sin(v * Math.PI) }],
    };
  });
  return <Animated.View style={[{ width: BOX, height: BOX, margin: 3, borderRadius: 5, backgroundColor: COLORS[i % 5] }, style]} />;
});

function ReaGrid({ n }) {
  const p = useSharedValue(0);
  useEffect(() => {
    p.value = withRepeat(withTiming(1, { duration: 1600, easing: Easing.linear }), -1, false);
    return () => cancelAnimation(p);
  }, []);
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
      {Array.from({ length: n }, (_, i) => <ReaBox key={i} i={i} p={p} />)}
    </View>
  );
}

function JsGrid({ n }) {
  const p = useRef(new RNAnimated.Value(0)).current;
  useEffect(() => {
    const a = RNAnimated.loop(RNAnimated.timing(p, { toValue: 1, duration: 1600, easing: RNEasing.linear, useNativeDriver: false }));
    a.start();
    return () => a.stop();
  }, []);
  const boxes = useMemo(
    () =>
      Array.from({ length: n }, (_, i) => {
        const v = RNAnimated.modulo(RNAnimated.add(p, (i * 0.137) % 1), 1);
        return (
          <RNAnimated.View
            key={i}
            style={{
              width: BOX, height: BOX, margin: 3, borderRadius: 5, backgroundColor: COLORS[i % 5],
              transform: [
                { rotate: v.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '360deg'] }) },
                { scale: v.interpolate({ inputRange: [0, 0.5, 1], outputRange: [0.7, 1.1, 0.7] }) },
              ],
            }}
          />
        );
      }),
    [n]
  );
  return <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>{boxes}</View>;
}

function MassAnim() {
  const t = useTheme();
  const [n, setN] = useState(200);
  const [mode, setMode] = useState('rea');
  return (
    <View>
      <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap' }}>
        {[50, 200, 500, 1000].map((c) => <Pill key={c} label={`${c} kotak`} on={n === c} onPress={() => setN(c)} />)}
      </View>
      <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap', marginTop: 8 }}>
        <Pill label="Reanimated (UI thread)" color={t.e} on={mode === 'rea'} onPress={() => setMode('rea')} />
        <Pill label="Animated (JS thread)" color={t.c} on={mode === 'js'} onPress={() => setMode('js')} />
      </View>
      <View style={{ marginTop: 12, borderRadius: 16, backgroundColor: t.card2, padding: 6, minHeight: 60 }}>
        {mode === 'rea' ? <ReaGrid key={`r${n}`} n={n} /> : <JsGrid key={`j${n}`} n={n} />}
      </View>
    </View>
  );
}

/* Thread sibuk --------------------------------------------------------- */
function BusyThread() {
  const t = useTheme();
  const [busy, setBusy] = useState(false);
  useEffect(() => {
    if (!busy) return;
    const id = setInterval(() => {
      const end = performance.now() + 120;
      while (performance.now() < end) { /* sengaja memblokir JS thread */ }
    }, 250);
    return () => clearInterval(id);
  }, [busy]);
  return (
    <View style={{ gap: 10 }}>
      <Text style={{ color: t.sub, fontSize: 13, lineHeight: 19 }}>
        Memblokir JS thread 120ms setiap 250ms, meniru kerja berat seperti parsing JSON besar.
        Perhatikan FPS dan kotak-kotak di atas.
      </Text>
      <Btn
        small
        label={busy ? '⏹ Hentikan beban' : '▶ Sibukkan JS thread'}
        colors={busy ? ['#FF4D6D', '#FF6B9A'] : [t.d, t.c]}
        onPress={() => setBusy((b) => !b)}
      />
    </View>
  );
}

export default function StressTab() {
  const t = useTheme();
  return (
    <>
      <View style={{ backgroundColor: t.card2, borderRadius: 18, padding: 14, marginBottom: 16 }}>
        <Text style={{ color: t.ink, fontWeight: '800' }}>🔥 Uji beban — sama persis dengan versi Flutter</Text>
        <Text style={{ color: t.sub, fontSize: 12.5, lineHeight: 19, marginTop: 4 }}>
          Jalankan di HP asli (Expo Go / build release). Di browser semua berjalan di satu thread, jadi hasilnya tidak mewakili.
        </Text>
      </View>
      <Section title="FPS" hint="UI thread: useFrameCallback (Reanimated) · JS thread: requestAnimationFrame"><FpsMeter /></Section>
      <Section title="Daftar 5.000 item" hint="FlatList tervirtualisasi, baris memo, getItemLayout"><BigList /></Section>
      <Section title="Animasi massal" hint="Bandingkan Reanimated vs Animated dengan jumlah kotak berbeda"><MassAnim /></Section>
      <Section title="Thread sibuk" hint="Animasi Reanimated tetap jalan; Animated (JS) ikut tersendat"><BusyThread /></Section>
    </>
  );
}
