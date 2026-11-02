import React, { useEffect, useRef, useState } from 'react';
import { View, Text, Animated, Easing, Pressable } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Section, Btn, useTheme, ND, glow } from './ui';

/* 1. Spring + bounce -------------------------------------------------- */
function SpringDemo() {
  const t = useTheme();
  const sc = useRef(new Animated.Value(1)).current;
  const y = useRef(new Animated.Value(0)).current;
  const press = (to) =>
    Animated.spring(sc, { toValue: to, friction: 3, tension: 170, useNativeDriver: ND }).start();
  const jump = () =>
    Animated.sequence([
      Animated.timing(y, { toValue: -80, duration: 280, easing: Easing.out(Easing.quad), useNativeDriver: ND }),
      Animated.timing(y, { toValue: 0, duration: 800, easing: Easing.bounce, useNativeDriver: ND }),
    ]).start();
  return (
    <View style={{ flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'space-around', height: 150 }}>
      <View style={{ alignItems: 'center' }}>
        <Pressable onPressIn={() => press(0.8)} onPressOut={() => press(1)}>
          <Animated.View
            style={[
              { width: 84, height: 84, borderRadius: 24, backgroundColor: t.a, alignItems: 'center', justifyContent: 'center' },
              glow(t.a), { transform: [{ scale: sc }] },
            ]}
          >
            <Text style={{ fontSize: 30 }}>👆</Text>
          </Animated.View>
        </Pressable>
        <Text style={{ color: t.sub, fontSize: 12, marginTop: 10 }}>Tekan & tahan</Text>
      </View>
      <View style={{ alignItems: 'center' }}>
        <Animated.View
          style={[
            { width: 50, height: 50, borderRadius: 25, backgroundColor: t.d, marginBottom: 24 },
            glow(t.d), { transform: [{ translateY: y }] },
          ]}
        />
        <Btn small label="Lompat" onPress={jump} colors={[t.d, t.c]} />
      </View>
    </View>
  );
}

/* 2. Pulse rings (Animated.loop) -------------------------------------- */
function Ring({ delay, color }) {
  const p = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    const a = Animated.loop(
      Animated.sequence([
        Animated.delay(delay),
        Animated.timing(p, { toValue: 1, duration: 1800, easing: Easing.out(Easing.ease), useNativeDriver: ND }),
      ])
    );
    a.start();
    return () => a.stop();
  }, []);
  return (
    <Animated.View
      style={{
        position: 'absolute', width: 70, height: 70, borderRadius: 35,
        borderWidth: 2, borderColor: color,
        opacity: p.interpolate({ inputRange: [0, 1], outputRange: [0.8, 0] }),
        transform: [{ scale: p.interpolate({ inputRange: [0, 1], outputRange: [1, 3] }) }],
      }}
    />
  );
}
function PulseDemo() {
  const t = useTheme();
  return (
    <View style={{ height: 130, alignItems: 'center', justifyContent: 'center' }}>
      <Ring delay={0} color={t.b} />
      <Ring delay={600} color={t.b} />
      <Ring delay={1200} color={t.b} />
      <View style={[{ width: 62, height: 62, borderRadius: 31, backgroundColor: t.b, alignItems: 'center', justifyContent: 'center' }, glow(t.b)]}>
        <Text style={{ fontSize: 26 }}>📡</Text>
      </View>
    </View>
  );
}

/* 3. Morph: rotate + radius + warna (interpolate) --------------------- */
function MorphDemo() {
  const t = useTheme();
  const m = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    const a = Animated.loop(
      Animated.sequence([
        Animated.timing(m, { toValue: 1, duration: 2200, easing: Easing.inOut(Easing.cubic), useNativeDriver: false }),
        Animated.timing(m, { toValue: 0, duration: 2200, easing: Easing.inOut(Easing.cubic), useNativeDriver: false }),
      ])
    );
    a.start();
    return () => a.stop();
  }, []);
  return (
    <View style={{ height: 130, alignItems: 'center', justifyContent: 'center' }}>
      <Animated.View
        style={{
          width: 80, height: 80,
          borderRadius: m.interpolate({ inputRange: [0, 1], outputRange: [10, 40] }),
          backgroundColor: m.interpolate({ inputRange: [0, 0.5, 1], outputRange: [t.a, t.c, t.d] }),
          transform: [
            { rotate: m.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '270deg'] }) },
            { scale: m.interpolate({ inputRange: [0, 0.5, 1], outputRange: [1, 1.25, 0.9] }) },
          ],
        }}
      />
    </View>
  );
}

/* 4. Stagger bars ----------------------------------------------------- */
const BAR_H = [48, 86, 64, 110, 78, 100, 56, 92];
function StaggerDemo() {
  const t = useTheme();
  const vals = useRef(BAR_H.map(() => new Animated.Value(0))).current;
  const cols = [t.a, t.b, t.c, t.d, t.e];
  const play = () => {
    vals.forEach((v) => v.setValue(0));
    Animated.stagger(
      80,
      vals.map((v) => Animated.spring(v, { toValue: 1, friction: 4, tension: 90, useNativeDriver: false }))
    ).start();
  };
  useEffect(play, []);
  return (
    <View>
      <View style={{ height: 120, flexDirection: 'row', alignItems: 'flex-end', gap: 8 }}>
        {vals.map((v, i) => (
          <Animated.View
            key={i}
            style={{
              flex: 1, borderRadius: 8, backgroundColor: cols[i % cols.length],
              height: v.interpolate({ inputRange: [0, 1], outputRange: [6, BAR_H[i]] }),
              opacity: v.interpolate({ inputRange: [0, 0.3, 1], outputRange: [0.2, 1, 1] }),
            }}
          />
        ))}
      </View>
      <View style={{ marginTop: 14, alignSelf: 'flex-start' }}>
        <Btn small label="Putar ulang" onPress={play} colors={[t.b, t.a]} />
      </View>
    </View>
  );
}

/* 5. Typing dots ------------------------------------------------------ */
function Dot({ i }) {
  const t = useTheme();
  const v = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    const a = Animated.loop(
      Animated.sequence([
        Animated.delay(i * 160),
        Animated.timing(v, { toValue: 1, duration: 320, useNativeDriver: ND }),
        Animated.timing(v, { toValue: 0, duration: 320, useNativeDriver: ND }),
        Animated.delay(480 - i * 160),
      ])
    );
    a.start();
    return () => a.stop();
  }, []);
  return (
    <Animated.View
      style={{
        width: 9, height: 9, borderRadius: 5, backgroundColor: t.sub,
        opacity: v.interpolate({ inputRange: [0, 1], outputRange: [0.35, 1] }),
        transform: [{ translateY: v.interpolate({ inputRange: [0, 1], outputRange: [0, -7] }) }],
      }}
    />
  );
}
function TypingDemo() {
  const t = useTheme();
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
      <View style={{ backgroundColor: t.card2, borderRadius: 18, borderBottomLeftRadius: 4, paddingVertical: 16, paddingHorizontal: 18, flexDirection: 'row', gap: 6 }}>
        <Dot i={0} /><Dot i={1} /><Dot i={2} />
      </View>
      <Text style={{ color: t.sub, fontSize: 13 }}>Sedang mengetik…</Text>
    </View>
  );
}

/* 6. Count-up --------------------------------------------------------- */
function CountDemo() {
  const t = useTheme();
  const v = useRef(new Animated.Value(0)).current;
  const [n, setN] = useState(0);
  useEffect(() => {
    const id = v.addListener(({ value }) => setN(Math.round(value)));
    return () => v.removeListener(id);
  }, []);
  const go = () => {
    v.setValue(0);
    Animated.timing(v, { toValue: 128450, duration: 1600, easing: Easing.out(Easing.exp), useNativeDriver: false }).start();
  };
  useEffect(go, []);
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
      <View>
        <Text style={{ color: t.sub, fontSize: 12, fontWeight: '700' }}>TOTAL SALDO</Text>
        <Text style={{ color: t.ink, fontSize: 32, fontWeight: '800', marginTop: 2 }}>
          Rp {n.toLocaleString('id-ID')}
        </Text>
      </View>
      <Btn small label="Hitung" onPress={go} colors={[t.e, t.b]} />
    </View>
  );
}

/* 7. Skeleton shimmer ------------------------------------------------- */
function Shimmer({ style }) {
  const t = useTheme();
  const [w, setW] = useState(0);
  const x = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    const a = Animated.loop(Animated.timing(x, { toValue: 1, duration: 1300, easing: Easing.linear, useNativeDriver: ND }));
    a.start();
    return () => a.stop();
  }, []);
  return (
    <View onLayout={(e) => setW(e.nativeEvent.layout.width)} style={[{ backgroundColor: t.card2, overflow: 'hidden' }, style]}>
      {w > 0 && (
        <Animated.View
          style={{
            ...StyleSheetFill, width: w,
            transform: [{ translateX: x.interpolate({ inputRange: [0, 1], outputRange: [-w, w] }) }],
          }}
        >
          <LinearGradient
            colors={['transparent', t.name === 'dark' ? '#ffffff22' : '#ffffffcc', 'transparent']}
            start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }} style={{ flex: 1 }}
          />
        </Animated.View>
      )}
    </View>
  );
}
const StyleSheetFill = { position: 'absolute', top: 0, left: 0, bottom: 0 };
function SkeletonDemo() {
  return (
    <View style={{ gap: 14 }}>
      {[0, 1].map((i) => (
        <View key={i} style={{ flexDirection: 'row', gap: 12, alignItems: 'center' }}>
          <Shimmer style={{ width: 54, height: 54, borderRadius: 18 }} />
          <View style={{ flex: 1, gap: 8 }}>
            <Shimmer style={{ height: 14, borderRadius: 7, width: '75%' }} />
            <Shimmer style={{ height: 12, borderRadius: 6, width: '45%' }} />
          </View>
        </View>
      ))}
    </View>
  );
}

export default function AnimTab() {
  return (
    <>
      <Section title="Spring & Bounce" hint="Animated.spring, Animated.sequence, Easing.bounce">
        <SpringDemo />
      </Section>
      <Section title="Pulse berulang" hint="Animated.loop + Animated.delay, native driver">
        <PulseDemo />
      </Section>
      <Section title="Morph bentuk & warna" hint="interpolate untuk rotate, borderRadius, backgroundColor">
        <MorphDemo />
      </Section>
      <Section title="Stagger" hint="Animated.stagger — bar muncul berurutan">
        <StaggerDemo />
      </Section>
      <Section title="Indikator mengetik" hint="Tiga loop dengan delay berbeda">
        <TypingDemo />
      </Section>
      <Section title="Hitung naik" hint="Animated.Value + addListener ke teks">
        <CountDemo />
      </Section>
      <Section title="Skeleton shimmer" hint="LinearGradient bergeser di dalam view overflow hidden">
        <SkeletonDemo />
      </Section>
    </>
  );
}
