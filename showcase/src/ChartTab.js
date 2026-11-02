import React, { useEffect, useRef, useState } from 'react';
import { View, Text, Animated, Easing, Pressable } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Section, Pill, useTheme, glow } from './ui';

const DATA = {
  Minggu: { labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'], v: [42, 68, 55, 90, 76, 110, 84] },
  Bulan: { labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'], v: [180, 240, 210, 320, 290, 410, 360] },
};

/* Bar chart ----------------------------------------------------------- */
function BarChart({ range }) {
  const t = useTheme();
  const d = DATA[range];
  const max = Math.max(...d.v);
  const anim = useRef(d.v.map(() => new Animated.Value(0))).current;
  const [sel, setSel] = useState(5);
  useEffect(() => {
    Animated.stagger(
      55,
      anim.map((a, i) => Animated.spring(a, { toValue: d.v[i] / max, friction: 6, tension: 80, useNativeDriver: false }))
    ).start();
  }, [range]);
  return (
    <View>
      <View style={{ flexDirection: 'row', alignItems: 'flex-end', height: 150, gap: 9 }}>
        {anim.map((a, i) => (
          <Pressable key={i} onPress={() => setSel(i)} style={{ flex: 1, height: '100%', justifyContent: 'flex-end' }}>
            {sel === i && (
              <Text style={{ color: t.ink, fontSize: 11, fontWeight: '800', textAlign: 'center', marginBottom: 4 }}>{d.v[i]}</Text>
            )}
            <Animated.View style={{ height: a.interpolate({ inputRange: [0, 1], outputRange: [0, 118] }), borderRadius: 10, overflow: 'hidden', opacity: sel === i ? 1 : 0.55 }}>
              <LinearGradient colors={sel === i ? [t.c, t.a] : [t.a, t.a]} style={{ flex: 1 }} />
            </Animated.View>
          </Pressable>
        ))}
      </View>
      <View style={{ flexDirection: 'row', gap: 9, marginTop: 8 }}>
        {d.labels.map((l, i) => (
          <Text key={l} style={{ flex: 1, textAlign: 'center', color: sel === i ? t.ink : t.sub, fontSize: 11.5, fontWeight: '700' }}>{l}</Text>
        ))}
      </View>
    </View>
  );
}

/* Line chart yang digambar dari View ---------------------------------- */
const LINE = [0.3, 0.55, 0.42, 0.7, 0.62, 0.9, 0.78, 0.95];
function LineChart() {
  const t = useTheme();
  const [w, setW] = useState(0);
  const H = 130;
  const reveal = useRef(new Animated.Value(0)).current;
  const play = () => {
    reveal.setValue(0);
    Animated.timing(reveal, { toValue: 1, duration: 1400, easing: Easing.inOut(Easing.cubic), useNativeDriver: false }).start();
  };
  useEffect(() => { if (w) play(); }, [w]);
  const pts = LINE.map((v, i) => [(i / (LINE.length - 1)) * (w - 12) + 6, H - 10 - v * (H - 24)]);
  return (
    <View>
      <View onLayout={(e) => setW(e.nativeEvent.layout.width)} style={{ height: H, justifyContent: 'center' }}>
        {[0.25, 0.5, 0.75].map((g) => (
          <View key={g} style={{ position: 'absolute', left: 0, right: 0, top: H * g, height: 1, backgroundColor: t.line }} />
        ))}
        {w > 0 && (
          <Animated.View style={{ position: 'absolute', left: 0, top: 0, height: H, overflow: 'hidden', width: reveal.interpolate({ inputRange: [0, 1], outputRange: [0, w] }) }}>
            <View style={{ width: w, height: H }}>
              {pts.slice(1).map(([x2, y2], i) => {
                const [x1, y1] = pts[i];
                const len = Math.hypot(x2 - x1, y2 - y1);
                const ang = Math.atan2(y2 - y1, x2 - x1);
                return (
                  <View
                    key={i}
                    style={{
                      position: 'absolute', left: (x1 + x2) / 2 - len / 2, top: (y1 + y2) / 2 - 1.5,
                      width: len, height: 3, borderRadius: 2, backgroundColor: t.b, transform: [{ rotate: `${ang}rad` }],
                    }}
                  />
                );
              })}
              {pts.map(([x, y], i) => (
                <View
                  key={i}
                  style={[{ position: 'absolute', left: x - 6, top: y - 6, width: 12, height: 12, borderRadius: 6, backgroundColor: t.card, borderWidth: 3, borderColor: t.b }, glow(t.b, 8)]}
                />
              ))}
            </View>
          </Animated.View>
        )}
      </View>
      <Pressable onPress={play} style={{ alignSelf: 'flex-start', marginTop: 10 }}>
        <Text style={{ color: t.b, fontWeight: '800', fontSize: 13 }}>↻ Gambar ulang</Text>
      </Pressable>
    </View>
  );
}

/* Progress rows ------------------------------------------------------- */
function Progress() {
  const t = useTheme();
  const rows = [
    ['Kerja', 0.82, t.a, '💼'], ['Olahraga', 0.55, t.e, '🏃'], ['Belajar', 0.68, t.b, '📚'], ['Tidur', 0.9, t.c, '😴'],
  ];
  const vals = useRef(rows.map(() => new Animated.Value(0))).current;
  useEffect(() => {
    Animated.stagger(120, vals.map((v, i) => Animated.timing(v, { toValue: rows[i][1], duration: 1000, easing: Easing.out(Easing.cubic), useNativeDriver: false }))).start();
  }, []);
  return (
    <View style={{ gap: 14 }}>
      {rows.map(([l, , c, e], i) => (
        <View key={l}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginBottom: 6 }}>
            <Text style={{ color: t.ink, fontWeight: '700' }}>{e} {l}</Text>
            <Text style={{ color: t.sub, fontWeight: '700' }}>{Math.round(rows[i][1] * 100)}%</Text>
          </View>
          <View style={{ height: 10, borderRadius: 5, backgroundColor: t.card2, overflow: 'hidden' }}>
            <Animated.View style={{ height: '100%', borderRadius: 5, backgroundColor: c, width: vals[i].interpolate({ inputRange: [0, 1], outputRange: ['0%', '100%'] }) }} />
          </View>
        </View>
      ))}
    </View>
  );
}

/* Stat tiles ---------------------------------------------------------- */
function Stats() {
  const t = useTheme();
  const items = [['Pengguna', '12,4K', '+8%', t.a], ['Pendapatan', '$3,2K', '+14%', t.e], ['Sesi', '48,9K', '-2%', t.c], ['Rating', '4.8', '+0.2', t.d]];
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 10 }}>
      {items.map(([l, v, d, c]) => (
        <View key={l} style={{ width: '48%', backgroundColor: t.card2, borderRadius: 18, padding: 14, borderLeftWidth: 4, borderLeftColor: c }}>
          <Text style={{ color: t.sub, fontSize: 12, fontWeight: '700' }}>{l}</Text>
          <Text style={{ color: t.ink, fontSize: 24, fontWeight: '800', marginTop: 2 }}>{v}</Text>
          <Text style={{ color: d.startsWith('-') ? t.c : t.e, fontSize: 12, fontWeight: '800', marginTop: 2 }}>{d.startsWith('-') ? '▼' : '▲'} {d}</Text>
        </View>
      ))}
    </View>
  );
}

export default function ChartTab() {
  const [range, setRange] = useState('Minggu');
  return (
    <>
      <Section title="Ringkasan" hint="Kartu statistik dengan flexWrap"><Stats /></Section>
      <Section title="Grafik batang" hint="Ketuk batang · ganti rentang untuk animasi data baru">
        <View style={{ flexDirection: 'row', gap: 8, marginBottom: 14 }}>
          {Object.keys(DATA).map((k) => <Pill key={k} label={k} on={range === k} onPress={() => setRange(k)} />)}
        </View>
        <BarChart range={range} />
      </Section>
      <Section title="Grafik garis" hint="Digambar tanpa library: View + rotate + clip reveal"><LineChart /></Section>
      <Section title="Progres aktivitas" hint="Lebar persentase di-interpolate"><Progress /></Section>
    </>
  );
}
