import React, { useEffect, useRef, useState } from 'react';
import { View, Text, Pressable, Animated, Switch, SafeAreaView, Easing, KeyboardAvoidingView, Platform, ScrollView as RNScrollView } from 'react-native';
import { GestureHandlerRootView, ScrollView } from 'react-native-gesture-handler';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';
import { THEMES, ThemeCtx, ND } from './src/ui';
import AnimTab from './src/AnimTab';
import GestureTab from './src/GestureTab';
import ComponentsTab from './src/ComponentsTab';
import LayoutTab from './src/LayoutTab';
import ChartTab from './src/ChartTab';
import ProTab from './src/ProTab';
import StressTab from './src/StressTab';
import FormTab from './src/FormTab';
import NavTab from './src/NavTab';

const TABS = [
  { key: 'anim', label: 'Animasi', icon: '✨', C: AnimTab },
  { key: 'gesture', label: 'Gestur', icon: '👆', C: GestureTab },
  { key: 'comp', label: 'Komponen', icon: '🧩', C: ComponentsTab },
  { key: 'layout', label: 'Layout', icon: '📐', C: LayoutTab },
  { key: 'chart', label: 'Grafik', icon: '📈', C: ChartTab },
  { key: 'pro', label: 'Pro', icon: '⚡', C: ProTab },
  { key: 'form', label: 'Form', icon: '📝', C: FormTab },
  { key: 'nav', label: 'Navigasi', icon: '🧭', C: NavTab },
  { key: 'stress', label: 'Beban', icon: '🔥', C: StressTab },
];

const ITEM_W = 76;

function TabBar({ index, onChange, t }) {
  const x = useRef(new Animated.Value(0)).current;
  const sc = useRef(null);
  useEffect(() => {
    Animated.spring(x, { toValue: index * ITEM_W, friction: 8, tension: 110, useNativeDriver: ND }).start();
    sc.current?.scrollTo({ x: Math.max(0, index * ITEM_W - 120), animated: true });
  }, [index]);
  return (
    <View style={{ backgroundColor: t.card, borderRadius: 26, marginHorizontal: 14, marginBottom: 12, borderWidth: 1, borderColor: t.line, overflow: 'hidden' }}>
      <RNScrollView ref={sc} horizontal showsHorizontalScrollIndicator={false}>
        <View style={{ flexDirection: 'row' }}>
          <Animated.View style={{ position: 'absolute', width: ITEM_W, height: '100%', padding: 5, transform: [{ translateX: x }] }}>
            <LinearGradient colors={[t.a, t.c]} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={{ flex: 1, borderRadius: 21, opacity: 0.95 }} />
          </Animated.View>
          {TABS.map((tab, i) => (
            <Pressable key={tab.key} onPress={() => onChange(i)} style={{ width: ITEM_W, alignItems: 'center', paddingVertical: 10 }}>
              <Text style={{ fontSize: 17 }}>{tab.icon}</Text>
              <Text style={{ fontSize: 9.5, fontWeight: '800', marginTop: 2, color: i === index ? '#fff' : t.sub }}>{tab.label}</Text>
            </Pressable>
          ))}
        </View>
      </RNScrollView>
    </View>
  );
}

function Screen({ C, tabKey }) {
  const v = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    v.setValue(0);
    Animated.timing(v, { toValue: 1, duration: 380, easing: Easing.out(Easing.cubic), useNativeDriver: ND }).start();
  }, [tabKey]);
  return (
    <Animated.View style={{ opacity: v, transform: [{ translateY: v.interpolate({ inputRange: [0, 1], outputRange: [24, 0] }) }] }}>
      <C />
    </Animated.View>
  );
}

export default function App() {
  const [dark, setDark] = useState(true);
  const [index, setIndex] = useState(0);
  const t = dark ? THEMES.dark : THEMES.light;
  const Tab = TABS[index];

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
    <ThemeCtx.Provider value={t}>
      <View style={{ flex: 1, backgroundColor: t.bg, alignItems: 'center' }}>
        <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1, width: '100%', maxWidth: 480 }}>
        <SafeAreaView style={{ flex: 1 }}>
          <StatusBar style={dark ? 'light' : 'dark'} />
          <View style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 20, paddingTop: 18, paddingBottom: 12 }}>
            <View style={{ flex: 1 }}>
              <Text style={{ color: t.sub, fontSize: 12, fontWeight: '800', letterSpacing: 1.5 }}>REACT NATIVE</Text>
              <Text style={{ color: t.ink, fontSize: 28, fontWeight: '800' }}>UI Showcase</Text>
            </View>
            <Text style={{ fontSize: 16, marginRight: 6 }}>{dark ? '🌙' : '☀️'}</Text>
            <Switch value={dark} onValueChange={setDark} trackColor={{ false: t.card2, true: t.a }} thumbColor="#fff" activeThumbColor="#fff" />
          </View>
          <ScrollView
            key={Tab.key}
            contentContainerStyle={{ paddingHorizontal: 18, paddingTop: 6, paddingBottom: 24 }}
            showsVerticalScrollIndicator={false}
            keyboardShouldPersistTaps="handled"
            keyboardDismissMode="on-drag"
          >
            <Screen C={Tab.C} tabKey={Tab.key} />
          </ScrollView>
          <TabBar index={index} onChange={setIndex} t={t} />
        </SafeAreaView>
        </KeyboardAvoidingView>
      </View>
    </ThemeCtx.Provider>
    </GestureHandlerRootView>
  );
}
