import React, { useEffect, useRef, useState } from 'react';
import {
  View, Text, Switch, TextInput, Pressable, ScrollView, SectionList, Modal,
  ActivityIndicator, Animated, Easing, Vibration, useWindowDimensions,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Section, Btn, useTheme, ND, glow } from './ui';

/* 1. Switch ----------------------------------------------------------- */
function SwitchDemo() {
  const t = useTheme();
  const [s, setS] = useState({ notif: true, dark: false, sync: true });
  const rows = [
    ['notif', '🔔', 'Notifikasi'],
    ['dark', '🌙', 'Mode hemat daya'],
    ['sync', '☁️', 'Sinkronisasi otomatis'],
  ];
  return (
    <View style={{ gap: 4 }}>
      {rows.map(([k, e, l]) => (
        <View key={k} style={{ flexDirection: 'row', alignItems: 'center', paddingVertical: 8 }}>
          <Text style={{ fontSize: 20, width: 34 }}>{e}</Text>
          <Text style={{ color: t.ink, flex: 1, fontWeight: '600', fontSize: 15 }}>{l}</Text>
          <Switch
            value={s[k]}
            onValueChange={(v) => setS((p) => ({ ...p, [k]: v }))}
            trackColor={{ false: t.card2, true: t.a }}
            thumbColor="#fff" activeThumbColor="#fff"
          />
        </View>
      ))}
    </View>
  );
}

/* 2. Segmented control animasi --------------------------------------- */
function Segmented() {
  const t = useTheme();
  const opts = ['Harian', 'Mingguan', 'Bulanan'];
  const [i, setI] = useState(0);
  const [w, setW] = useState(0);
  const x = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.spring(x, { toValue: i * (w / 3), friction: 7, tension: 120, useNativeDriver: ND }).start();
  }, [i, w]);
  return (
    <View onLayout={(e) => setW(e.nativeEvent.layout.width)} style={{ flexDirection: 'row', backgroundColor: t.card2, borderRadius: 16, padding: 0 }}>
      {w > 0 && (
        <Animated.View
          style={{ position: 'absolute', width: w / 3, height: '100%', padding: 4, transform: [{ translateX: x }] }}
        >
          <LinearGradient colors={[t.a, t.c]} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={{ flex: 1, borderRadius: 12 }} />
        </Animated.View>
      )}
      {opts.map((o, k) => (
        <Pressable key={o} onPress={() => setI(k)} style={{ flex: 1, paddingVertical: 12, alignItems: 'center' }}>
          <Text style={{ color: i === k ? '#fff' : t.sub, fontWeight: '800', fontSize: 13 }}>{o}</Text>
        </Pressable>
      ))}
    </View>
  );
}

/* 3. TextInput -------------------------------------------------------- */
function InputDemo() {
  const t = useTheme();
  const [name, setName] = useState('');
  const [pw, setPw] = useState('');
  const [show, setShow] = useState(false);
  const [bio, setBio] = useState('');
  const f = useRef(new Animated.Value(0)).current;
  const focus = (to) => Animated.timing(f, { toValue: to, duration: 180, useNativeDriver: false }).start();
  const box = {
    borderRadius: 16, paddingHorizontal: 14, backgroundColor: t.card2, flexDirection: 'row', alignItems: 'center', borderWidth: 2,
  };
  const field = { flex: 1, color: t.ink, fontSize: 15, paddingVertical: 13, outlineStyle: 'none' };
  return (
    <View style={{ gap: 12 }}>
      <Animated.View style={[box, { borderColor: f.interpolate({ inputRange: [0, 1], outputRange: ['transparent', t.a] }) }]}>
        <Text style={{ marginRight: 8 }}>👤</Text>
        <TextInput
          value={name} onChangeText={setName} placeholder="Nama lengkap" placeholderTextColor={t.sub}
          style={field} onFocus={() => focus(1)} onBlur={() => focus(0)}
        />
        {name.length > 0 && (
          <Pressable onPress={() => setName('')} hitSlop={10}>
            <Text style={{ color: t.sub, fontSize: 16 }}>✕</Text>
          </Pressable>
        )}
      </Animated.View>
      <View style={[box, { borderColor: 'transparent' }]}>
        <Text style={{ marginRight: 8 }}>🔒</Text>
        <TextInput
          value={pw} onChangeText={setPw} placeholder="Kata sandi" placeholderTextColor={t.sub}
          secureTextEntry={!show} style={field}
        />
        <Pressable onPress={() => setShow((v) => !v)} hitSlop={10}>
          <Text style={{ fontSize: 16 }}>{show ? '🙈' : '👁️'}</Text>
        </Pressable>
      </View>
      <View style={[box, { borderColor: 'transparent', alignItems: 'flex-start' }]}>
        <TextInput
          value={bio} onChangeText={(v) => setBio(v.slice(0, 80))} placeholder="Bio singkat…" placeholderTextColor={t.sub}
          multiline numberOfLines={3} style={[field, { minHeight: 70, textAlignVertical: 'top' }]}
        />
      </View>
      <Text style={{ color: t.sub, fontSize: 12, alignSelf: 'flex-end' }}>{bio.length}/80</Text>
    </View>
  );
}

/* 4. Carousel --------------------------------------------------------- */
const CARDS = [
  { t: 'Senja Pantai', s: 'Bali', c: ['#FF9A8B', '#FF6A88'], e: '🌅' },
  { t: 'Hutan Pagi', s: 'Bogor', c: ['#43E97B', '#38F9D7'], e: '🌲' },
  { t: 'Kota Malam', s: 'Jakarta', c: ['#667EEA', '#764BA2'], e: '🌃' },
  { t: 'Gunung Salju', s: 'Papua', c: ['#4FACFE', '#00F2FE'], e: '🏔️' },
];
function Carousel() {
  const t = useTheme();
  const { width } = useWindowDimensions();
  const cw = Math.min(width, 480) - 36 - 36 - 40; // lebar kartu
  const gap = 12;
  const x = useRef(new Animated.Value(0)).current;
  return (
    <View>
      <Animated.ScrollView
        horizontal showsHorizontalScrollIndicator={false}
        snapToInterval={cw + gap} decelerationRate="fast"
        contentContainerStyle={{ gap }}
        onScroll={Animated.event([{ nativeEvent: { contentOffset: { x } } }], { useNativeDriver: false })}
        scrollEventThrottle={16}
      >
        {CARDS.map((c, i) => {
          const range = [(i - 1) * (cw + gap), i * (cw + gap), (i + 1) * (cw + gap)];
          return (
            <Animated.View
              key={c.t}
              style={{
                width: cw, height: 150,
                transform: [{ scale: x.interpolate({ inputRange: range, outputRange: [0.92, 1, 0.92], extrapolate: 'clamp' }) }],
                opacity: x.interpolate({ inputRange: range, outputRange: [0.6, 1, 0.6], extrapolate: 'clamp' }),
              }}
            >
              <LinearGradient colors={c.c} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={{ flex: 1, borderRadius: 24, padding: 18, justifyContent: 'space-between' }}>
                <Text style={{ fontSize: 40 }}>{c.e}</Text>
                <View>
                  <Text style={{ color: '#fff', fontSize: 20, fontWeight: '800' }}>{c.t}</Text>
                  <Text style={{ color: '#ffffffcc', fontSize: 13, fontWeight: '600' }}>{c.s}</Text>
                </View>
              </LinearGradient>
            </Animated.View>
          );
        })}
      </Animated.ScrollView>
      <View style={{ flexDirection: 'row', justifyContent: 'center', gap: 6, marginTop: 14 }}>
        {CARDS.map((_, i) => {
          const range = [(i - 1) * (cw + gap), i * (cw + gap), (i + 1) * (cw + gap)];
          return (
            <Animated.View
              key={i}
              style={{
                height: 8, borderRadius: 4, backgroundColor: t.a,
                width: x.interpolate({ inputRange: range, outputRange: [8, 24, 8], extrapolate: 'clamp' }),
                opacity: x.interpolate({ inputRange: range, outputRange: [0.35, 1, 0.35], extrapolate: 'clamp' }),
              }}
            />
          );
        })}
      </View>
    </View>
  );
}

/* 5. SectionList ------------------------------------------------------ */
const CONTACTS = [
  { title: 'A', data: ['Adi Pratama', 'Ayu Lestari', 'Andi Wijaya'] },
  { title: 'B', data: ['Bagas Saputra', 'Bunga Citra'] },
  { title: 'D', data: ['Dewi Anggraini', 'Dimas Aryo', 'Dina Mariana'] },
  { title: 'R', data: ['Rangga Putra', 'Rani Oktavia'] },
];
function ListDemo() {
  const t = useTheme();
  const cols = [t.a, t.b, t.c, t.d, t.e];
  return (
    <View style={{ height: 230, borderRadius: 18, overflow: 'hidden', backgroundColor: t.card2 }}>
      <SectionList
        sections={CONTACTS}
        keyExtractor={(i) => i}
        stickySectionHeadersEnabled
        nestedScrollEnabled
        renderSectionHeader={({ section }) => (
          <Text style={{ backgroundColor: t.card2, color: t.a, fontWeight: '800', paddingHorizontal: 14, paddingVertical: 6, fontSize: 12 }}>
            {section.title}
          </Text>
        )}
        renderItem={({ item, index }) => (
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 14, paddingVertical: 8 }}>
            <View style={{ width: 34, height: 34, borderRadius: 17, backgroundColor: cols[(item.length + index) % 5], alignItems: 'center', justifyContent: 'center' }}>
              <Text style={{ color: '#fff', fontWeight: '800' }}>{item[0]}</Text>
            </View>
            <Text style={{ color: t.ink, fontWeight: '600', fontSize: 14.5 }}>{item}</Text>
          </View>
        )}
      />
    </View>
  );
}

/* 6. Rating ----------------------------------------------------------- */
function Star({ on, onPress }) {
  const sc = useRef(new Animated.Value(1)).current;
  const tap = () => {
    onPress();
    Animated.sequence([
      Animated.timing(sc, { toValue: 1.45, duration: 110, useNativeDriver: ND }),
      Animated.spring(sc, { toValue: 1, friction: 3, useNativeDriver: ND }),
    ]).start();
  };
  return (
    <Pressable onPress={tap} hitSlop={4}>
      <Animated.Text style={{ fontSize: 34, opacity: on ? 1 : 0.28, transform: [{ scale: sc }] }}>⭐</Animated.Text>
    </Pressable>
  );
}
function RatingDemo() {
  const t = useTheme();
  const [r, setR] = useState(3);
  const labels = ['', 'Buruk', 'Kurang', 'Cukup', 'Bagus', 'Luar biasa!'];
  return (
    <View style={{ alignItems: 'center', gap: 8 }}>
      <View style={{ flexDirection: 'row', gap: 6 }}>
        {[1, 2, 3, 4, 5].map((n) => (
          <Star key={n} on={n <= r} onPress={() => setR(n)} />
        ))}
      </View>
      <Text style={{ color: t.ink, fontWeight: '800' }}>{labels[r]}</Text>
    </View>
  );
}

/* 7. Loading, modal, toast, getar ------------------------------------ */
function Misc() {
  const t = useTheme();
  const [modal, setModal] = useState(false);
  const [toast, setToast] = useState('');
  const m = useRef(new Animated.Value(0)).current;
  const ty = useRef(new Animated.Value(80)).current;
  useEffect(() => {
    if (modal) {
      m.setValue(0);
      Animated.spring(m, { toValue: 1, friction: 6, tension: 90, useNativeDriver: ND }).start();
    }
  }, [modal]);
  const showToast = (msg) => {
    setToast(msg);
    Animated.sequence([
      Animated.spring(ty, { toValue: 0, useNativeDriver: ND }),
      Animated.delay(1400),
      Animated.timing(ty, { toValue: 80, duration: 220, easing: Easing.in(Easing.quad), useNativeDriver: ND }),
    ]).start();
  };
  return (
    <View style={{ gap: 16 }}>
      <View style={{ flexDirection: 'row', justifyContent: 'space-around', alignItems: 'center' }}>
        <ActivityIndicator size="small" color={t.a} />
        <ActivityIndicator size="large" color={t.b} />
        <ActivityIndicator size="large" color={t.c} />
        <ActivityIndicator size="small" color={t.d} />
      </View>
      <View style={{ flexDirection: 'row', gap: 10, flexWrap: 'wrap' }}>
        <Btn small label="Buka Modal" onPress={() => setModal(true)} />
        <Btn small label="Toast" colors={[t.e, t.b]} onPress={() => showToast('✅ Berhasil disimpan')} />
        <Btn small label="Getar" colors={[t.d, t.c]} onPress={() => { Vibration.vibrate(60); showToast('📳 Getar (perangkat asli)'); }} />
      </View>
      <Animated.View
        style={{
          alignSelf: 'center', backgroundColor: t.ink, borderRadius: 14, paddingVertical: 10, paddingHorizontal: 18,
          opacity: ty.interpolate({ inputRange: [0, 80], outputRange: [1, 0] }),
          transform: [{ translateY: ty }], minHeight: 38,
        }}
      >
        <Text style={{ color: t.bg, fontWeight: '700' }}>{toast || ' '}</Text>
      </Animated.View>

      <Modal visible={modal} transparent animationType="fade" onRequestClose={() => setModal(false)}>
        <Pressable onPress={() => setModal(false)} style={{ flex: 1, backgroundColor: '#000a', alignItems: 'center', justifyContent: 'center', padding: 30 }}>
          <Animated.View
            style={[
              { width: '100%', maxWidth: 340, backgroundColor: t.card, borderRadius: 28, padding: 24, alignItems: 'center' },
              glow(t.a, 24),
              { opacity: m, transform: [{ scale: m.interpolate({ inputRange: [0, 1], outputRange: [0.6, 1] }) }] },
            ]}
          >
            <Text style={{ fontSize: 54 }}>🚀</Text>
            <Text style={{ color: t.ink, fontSize: 20, fontWeight: '800', marginTop: 8 }}>Ini Modal</Text>
            <Text style={{ color: t.sub, textAlign: 'center', marginVertical: 10, lineHeight: 20 }}>
              Komponen Modal bawaan dengan animasi masuk spring buatan sendiri.
            </Text>
            <Btn label="Tutup" onPress={() => setModal(false)} />
          </Animated.View>
        </Pressable>
      </Modal>
    </View>
  );
}

export default function ComponentsTab() {
  return (
    <>
      <Section title="Switch" hint="Switch bawaan dengan warna track kustom"><SwitchDemo /></Section>
      <Section title="Segmented control" hint="Pill bergeser dengan spring + LinearGradient"><Segmented /></Section>
      <Section title="Input teks" hint="Focus ring animasi, tombol hapus, show/hide, multiline"><InputDemo /></Section>
      <Section title="Carousel" hint="ScrollView horizontal + snapToInterval + scroll-driven animation"><Carousel /></Section>
      <Section title="SectionList" hint="Sticky header, virtualisasi"><ListDemo /></Section>
      <Section title="Rating" hint="Bounce per bintang"><RatingDemo /></Section>
      <Section title="Loading, Modal, Toast" hint="ActivityIndicator, Modal, Vibration"><Misc /></Section>
    </>
  );
}
