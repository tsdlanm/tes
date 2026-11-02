import React, { useRef, useState } from 'react';
import { View, Text, Animated, PanResponder } from 'react-native';
import { Section, Btn, useTheme, dragStyle, glow } from './ui';

/* 1. Drag bebas + spring kembali ------------------------------------- */
function DragDemo() {
  const t = useTheme();
  const pos = useRef(new Animated.ValueXY()).current;
  const sc = useRef(new Animated.Value(1)).current;
  const [dragging, setDragging] = useState(false);
  const pan = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onPanResponderGrant: () => {
        setDragging(true);
        Animated.spring(sc, { toValue: 1.18, useNativeDriver: false }).start();
      },
      onPanResponderMove: Animated.event([null, { dx: pos.x, dy: pos.y }], { useNativeDriver: false }),
      onPanResponderRelease: () => {
        setDragging(false);
        Animated.parallel([
          Animated.spring(pos, { toValue: { x: 0, y: 0 }, friction: 4, tension: 70, useNativeDriver: false }),
          Animated.spring(sc, { toValue: 1, useNativeDriver: false }),
        ]).start();
      },
    })
  ).current;
  return (
    <View style={{ height: 190, borderRadius: 20, backgroundColor: t.card2, alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }}>
      <Text style={{ position: 'absolute', top: 12, color: t.sub, fontSize: 12 }}>
        {dragging ? 'Lepas untuk melihat spring kembali' : 'Seret kartu ke mana saja'}
      </Text>
      <Animated.View
        {...pan.panHandlers}
        style={[
          dragStyle,
          { width: 110, height: 110, borderRadius: 28, backgroundColor: t.c, alignItems: 'center', justifyContent: 'center' },
          glow(t.c),
          { transform: [...pos.getTranslateTransform(), { scale: sc }, { rotate: pos.x.interpolate({ inputRange: [-150, 150], outputRange: ['-18deg', '18deg'] }) }] },
        ]}
      >
        <Text style={{ fontSize: 40 }}>🎈</Text>
      </Animated.View>
    </View>
  );
}

/* 2. Swipe-to-delete -------------------------------------------------- */
function SwipeRow({ emoji, label, sub, onRemove }) {
  const t = useTheme();
  const x = useRef(new Animated.Value(0)).current;
  const h = useRef(new Animated.Value(76)).current;
  const pan = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (_, g) => Math.abs(g.dx) > 8 && Math.abs(g.dx) > Math.abs(g.dy),
      onPanResponderMove: (_, g) => x.setValue(Math.min(0, g.dx)),
      onPanResponderRelease: (_, g) => {
        if (g.dx < -110) {
          Animated.timing(x, { toValue: -600, duration: 200, useNativeDriver: false }).start(() =>
            Animated.timing(h, { toValue: 0, duration: 200, useNativeDriver: false }).start(onRemove)
          );
        } else {
          Animated.spring(x, { toValue: 0, bounciness: 14, useNativeDriver: false }).start();
        }
      },
    })
  ).current;
  return (
    <Animated.View style={{ height: h, overflow: 'hidden' }}>
      <View style={{ height: 68, borderRadius: 18, backgroundColor: '#FF4D6D', justifyContent: 'center', alignItems: 'flex-end', paddingRight: 24 }}>
        <Animated.Text
          style={{
            fontSize: 24,
            opacity: x.interpolate({ inputRange: [-120, -30, 0], outputRange: [1, 0.3, 0], extrapolate: 'clamp' }),
            transform: [{ scale: x.interpolate({ inputRange: [-120, 0], outputRange: [1.2, 0.6], extrapolate: 'clamp' }) }],
          }}
        >
          🗑️
        </Animated.Text>
      </View>
      <Animated.View
        {...pan.panHandlers}
        style={[
          dragStyle,
          {
            position: 'absolute', top: 0, left: 0, right: 0, height: 68, borderRadius: 18,
            backgroundColor: t.card2, flexDirection: 'row', alignItems: 'center', gap: 14, paddingHorizontal: 16,
            borderWidth: 1, borderColor: t.line, transform: [{ translateX: x }],
          },
        ]}
      >
        <Text style={{ fontSize: 26 }}>{emoji}</Text>
        <View>
          <Text style={{ color: t.ink, fontWeight: '800', fontSize: 15 }}>{label}</Text>
          <Text style={{ color: t.sub, fontSize: 12.5, marginTop: 2 }}>{sub}</Text>
        </View>
        <Text style={{ marginLeft: 'auto', color: t.sub, fontSize: 18 }}>‹</Text>
      </Animated.View>
    </Animated.View>
  );
}
const ROWS = [
  { id: 1, emoji: '📩', label: 'Undangan rapat', sub: 'Geser ke kiri untuk menghapus' },
  { id: 2, emoji: '🎵', label: 'Playlist baru', sub: '12 lagu ditambahkan' },
  { id: 3, emoji: '📦', label: 'Paket tiba', sub: 'Diantar kurir pukul 10.30' },
  { id: 4, emoji: '🗓️', label: 'Pengingat ulang tahun', sub: 'Sabtu ini' },
];
function SwipeDemo() {
  const [rows, setRows] = useState(ROWS);
  return (
    <View>
      {rows.map((r) => (
        <SwipeRow key={r.id} {...r} onRemove={() => setRows((p) => p.filter((x) => x.id !== r.id))} />
      ))}
      {rows.length === 0 && (
        <Text style={{ textAlign: 'center', paddingVertical: 20 }}>🎉 Semua bersih!</Text>
      )}
      <View style={{ marginTop: 6, alignSelf: 'flex-start' }}>
        <Btn small label="Isi ulang" onPress={() => setRows(ROWS)} />
      </View>
    </View>
  );
}

/* 3. Slider kustom ---------------------------------------------------- */
function SliderDemo() {
  const t = useTheme();
  const [val, setVal] = useState(0.55);
  const [w, setW] = useState(1);
  const wRef = useRef(1);
  wRef.current = w;
  const start = useRef(0);
  const clamp = (n) => Math.max(0, Math.min(1, n));
  const pan = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: (e) => {
        start.current = clamp(e.nativeEvent.locationX / wRef.current);
        setVal(start.current);
      },
      onPanResponderMove: (_, g) => setVal(clamp(start.current + g.dx / wRef.current)),
    })
  ).current;
  const hue = Math.round(val * 280);
  const color = `hsl(${hue}, 85%, 60%)`;
  return (
    <View>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 16, marginBottom: 14 }}>
        <View style={[{ width: 64, height: 64, borderRadius: 20, backgroundColor: color, alignItems: 'center', justifyContent: 'center' }, glow(color, 12)]}>
          <Text style={{ color: '#fff', fontWeight: '800', fontSize: 16 }}>{Math.round(val * 100)}</Text>
        </View>
        <Text style={{ color: t.sub, flex: 1, fontSize: 13, lineHeight: 19 }}>
          Slider ini digambar dari View biasa dan digerakkan PanResponder.
        </Text>
      </View>
      <View {...pan.panHandlers} onLayout={(e) => setW(e.nativeEvent.layout.width)} style={[dragStyle, { height: 36, justifyContent: 'center' }]}>
        <View style={{ height: 8, borderRadius: 4, backgroundColor: t.card2 }}>
          <View style={{ width: `${val * 100}%`, height: 8, borderRadius: 4, backgroundColor: color }} />
        </View>
        <View
          pointerEvents="none"
          style={{
            position: 'absolute', left: val * w - 14, width: 28, height: 28, borderRadius: 14,
            backgroundColor: '#fff', borderWidth: 4, borderColor: color,
          }}
        />
      </View>
    </View>
  );
}

export default function GestureTab() {
  return (
    <>
      <Section title="Drag & spring" hint="PanResponder + Animated.ValueXY + rotate dari posisi">
        <DragDemo />
      </Section>
      <Section title="Swipe untuk hapus" hint="Geser baris ke kiri lebih dari ±110px lalu lepas">
        <SwipeDemo />
      </Section>
      <Section title="Slider kustom" hint="Warna berubah mengikuti nilai (HSL)">
        <SliderDemo />
      </Section>
    </>
  );
}
