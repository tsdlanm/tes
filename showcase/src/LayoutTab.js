import React, { useRef, useState } from 'react';
import { View, Text, Animated, Pressable, Easing, Platform } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Section, Pill, useTheme, ND, glow } from './ui';

/* 1. Flexbox playground ---------------------------------------------- */
function Flex() {
  const t = useTheme();
  const [dir, setDir] = useState('row');
  const [just, setJust] = useState('flex-start');
  const [align, setAlign] = useState('flex-start');
  const boxes = [[t.a, 34], [t.c, 52], [t.b, 40]];
  return (
    <View>
      <Text style={{ color: t.sub, fontSize: 11.5, fontWeight: '700', marginBottom: 6 }}>flexDirection</Text>
      <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap' }}>
        {['row', 'column', 'row-reverse'].map((v) => <Pill key={v} label={v} on={dir === v} onPress={() => setDir(v)} />)}
      </View>
      <Text style={{ color: t.sub, fontSize: 11.5, fontWeight: '700', marginTop: 10, marginBottom: 6 }}>justifyContent</Text>
      <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap' }}>
        {['flex-start', 'center', 'space-between', 'space-around'].map((v) => <Pill key={v} label={v} color={t.c} on={just === v} onPress={() => setJust(v)} />)}
      </View>
      <Text style={{ color: t.sub, fontSize: 11.5, fontWeight: '700', marginTop: 10, marginBottom: 6 }}>alignItems</Text>
      <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap' }}>
        {['flex-start', 'center', 'flex-end', 'stretch'].map((v) => <Pill key={v} label={v} color={t.b} on={align === v} onPress={() => setAlign(v)} />)}
      </View>
      <View
        style={{
          marginTop: 14, height: 170, borderRadius: 18, padding: 10, backgroundColor: t.card2,
          flexDirection: dir, justifyContent: just, alignItems: align, borderWidth: 1, borderColor: t.line, borderStyle: 'dashed',
        }}
      >
        {boxes.map(([c, s], i) => (
          <View
            key={i}
            style={{
              backgroundColor: c, borderRadius: 12, alignItems: 'center', justifyContent: 'center',
              width: align === 'stretch' && dir === 'column' ? undefined : s + 10,
              height: align === 'stretch' && dir === 'row' ? undefined : s + 10,
            }}
          >
            <Text style={{ color: '#fff', fontWeight: '800' }}>{i + 1}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

/* 2. Accordion -------------------------------------------------------- */
const FAQ = [
  ['Apa itu React Native?', 'Framework untuk membuat aplikasi iOS & Android dengan JavaScript/React, merender komponen native sungguhan.'],
  ['Apakah bisa jalan di web?', 'Bisa, lewat react-native-web. Halaman pratinjau ini sendiri memakai itu.'],
  ['Bagaimana dengan performa animasi?', 'Dengan useNativeDriver atau Reanimated, animasi dijalankan di thread UI sehingga tetap 60fps.'],
];
function Item({ q, a }) {
  const t = useTheme();
  const [open, setOpen] = useState(false);
  const v = useRef(new Animated.Value(0)).current;
  const toggle = () => {
    Animated.timing(v, { toValue: open ? 0 : 1, duration: 280, easing: Easing.out(Easing.cubic), useNativeDriver: false }).start();
    setOpen(!open);
  };
  return (
    <View style={{ backgroundColor: t.card2, borderRadius: 16, marginBottom: 8, overflow: 'hidden' }}>
      <Pressable onPress={toggle} style={{ flexDirection: 'row', alignItems: 'center', padding: 14 }}>
        <Text style={{ color: t.ink, fontWeight: '700', flex: 1, fontSize: 14.5 }}>{q}</Text>
        <Animated.Text style={{ color: t.a, fontSize: 18, fontWeight: '800', transform: [{ rotate: v.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '135deg'] }) }] }}>
          +
        </Animated.Text>
      </Pressable>
      <Animated.View style={{ maxHeight: v.interpolate({ inputRange: [0, 1], outputRange: [0, 110] }), opacity: v }}>
        <Text style={{ color: t.sub, paddingHorizontal: 14, paddingBottom: 14, lineHeight: 20, fontSize: 13.5 }}>{a}</Text>
      </Animated.View>
    </View>
  );
}
function Accordion() {
  return <View>{FAQ.map(([q, a]) => <Item key={q} q={q} a={a} />)}</View>;
}

/* 3. Transform 3D ----------------------------------------------------- */
const POSES = [
  { rx: 0, ry: 0, rz: 0, s: 1, name: 'Datar' },
  { rx: 25, ry: -35, rz: 0, s: 1, name: 'Perspektif 3D' },
  { rx: 0, ry: 180, rz: 0, s: 1, name: 'Balik (rotateY)' },
  { rx: 0, ry: 0, rz: 12, s: 1.12, name: 'Miring + scale' },
];
function Transform3D() {
  const t = useTheme();
  const [i, setI] = useState(0);
  const v = useRef(new Animated.Value(0)).current;
  const next = () => {
    const n = (i + 1) % POSES.length;
    setI(n);
    Animated.spring(v, { toValue: n, friction: 6, tension: 60, useNativeDriver: ND }).start();
  };
  const r = (k, suf) => v.interpolate({ inputRange: POSES.map((_, x) => x), outputRange: POSES.map((p) => p[k] + suf) });
  return (
    <View style={{ alignItems: 'center' }}>
      <Pressable onPress={next} style={{ height: 190, justifyContent: 'center' }}>
        <Animated.View
          style={[
            { width: 220, height: 130, borderRadius: 24, overflow: 'hidden', backfaceVisibility: 'hidden' },
            glow(t.a, 22),
            {
              transform: [
                { perspective: 800 },
                { rotateX: r('rx', 'deg') },
                { rotateY: r('ry', 'deg') },
                { rotateZ: r('rz', 'deg') },
                { scale: v.interpolate({ inputRange: POSES.map((_, x) => x), outputRange: POSES.map((p) => p.s) }) },
              ],
            },
          ]}
        >
          <LinearGradient colors={[t.a, t.c, t.d]} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={{ flex: 1, padding: 18, justifyContent: 'space-between' }}>
            <Text style={{ color: '#fff', fontWeight: '800', fontSize: 13, letterSpacing: 2 }}>RN CARD</Text>
            <View>
              <Text style={{ color: '#fff', fontSize: 18, fontWeight: '700', letterSpacing: 3 }}>•••• 4242</Text>
              <Text style={{ color: '#ffffffcc', fontSize: 12, marginTop: 4 }}>IBRA REAL</Text>
            </View>
          </LinearGradient>
        </Animated.View>
      </Pressable>
      <Text style={{ color: t.sub, fontSize: 12.5, marginTop: 4 }}>Ketuk kartu · {POSES[i].name}</Text>
    </View>
  );
}

/* 4. Galeri gaya ------------------------------------------------------ */
function Gallery() {
  const t = useTheme();
  const tile = { width: '31%', aspectRatio: 1, alignItems: 'center', justifyContent: 'center' };
  const lbl = (s) => <Text style={{ color: '#fff', fontWeight: '800', fontSize: 11, marginTop: 4 }}>{s}</Text>;
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: '3.5%', rowGap: 12 }}>
      <LinearGradient colors={[t.a, t.b]} style={[tile, { borderRadius: 20 }]}><Text style={{ fontSize: 24 }}>🌈</Text>{lbl('Gradient')}</LinearGradient>
      <View style={[tile, { backgroundColor: t.c, borderRadius: 50 }, glow(t.c, 14)]}><Text style={{ fontSize: 24 }}>💫</Text>{lbl('Glow')}</View>
      <View style={[tile, { borderRadius: 20, borderWidth: 2, borderStyle: 'dashed', borderColor: t.d }]}><Text style={{ fontSize: 24 }}>✂️</Text><Text style={{ color: t.d, fontWeight: '800', fontSize: 11, marginTop: 4 }}>Dashed</Text></View>
      <View style={[tile, { backgroundColor: t.e, borderTopLeftRadius: 40, borderBottomRightRadius: 40, borderRadius: 8 }]}><Text style={{ fontSize: 24 }}>🍃</Text>{lbl('Radius')}</View>
      <View style={[tile, { backgroundColor: t.a, borderRadius: 20, opacity: 0.45 }]}><Text style={{ fontSize: 24 }}>👻</Text>{lbl('Opacity')}</View>
      <View style={[tile, { backgroundColor: t.b, borderRadius: 20, transform: [{ rotate: '-8deg' }, { skewX: '-8deg' }] }]}><Text style={{ fontSize: 24 }}>🌀</Text>{lbl('Skew')}</View>
    </View>
  );
}

export default function LayoutTab() {
  return (
    <>
      <Section title="Flexbox playground" hint="Ubah properti dan lihat hasilnya langsung"><Flex /></Section>
      <Section title="Accordion" hint="maxHeight + opacity + rotate yang di-interpolate dari satu nilai"><Accordion /></Section>
      <Section title="Transform 3D" hint="perspective, rotateX/Y/Z, scale — pose dipindah dengan spring"><Transform3D /></Section>
      <Section title="Galeri gaya" hint="Gradient, shadow/glow, border dashed, radius per sudut, opacity, skew"><Gallery /></Section>
    </>
  );
}
