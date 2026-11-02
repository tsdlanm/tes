import React, { createContext, useContext } from 'react';
import { View, Text, Pressable, Platform } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

const accents = { a: '#7C5CFF', b: '#22D3EE', c: '#FF6B9A', d: '#FBBF24', e: '#34D399' };

export const THEMES = {
  dark: {
    name: 'dark', bg: '#0B0F1E', card: '#151B31', card2: '#1D2542',
    ink: '#F2F4FF', sub: '#8D95B8', line: '#262F52', ...accents,
  },
  light: {
    name: 'light', bg: '#F3F4FB', card: '#FFFFFF', card2: '#ECEEFA',
    ink: '#161A33', sub: '#6B7194', line: '#E2E5F5', ...accents,
  },
};

export const ThemeCtx = createContext(THEMES.dark);
export const useTheme = () => useContext(ThemeCtx);

// Native driver hanya untuk transform/opacity; di web jatuh ke JS driver.
export const ND = Platform.OS !== 'web';

export const dragStyle = Platform.select({
  web: { userSelect: 'none', touchAction: 'none', cursor: 'grab' },
  default: {},
});

export const glow = (color, r = 16) =>
  Platform.select({
    web: { boxShadow: `0 8px ${r * 1.6}px ${color}66` },
    default: {
      shadowColor: color, shadowOpacity: 0.45, shadowRadius: r,
      shadowOffset: { width: 0, height: 8 }, elevation: 6,
    },
  });

export function Section({ title, hint, children }) {
  const t = useTheme();
  return (
    <View
      style={{
        backgroundColor: t.card, borderRadius: 24, padding: 18,
        marginBottom: 16, borderWidth: 1, borderColor: t.line,
      }}
    >
      <Text style={{ color: t.ink, fontSize: 17, fontWeight: '800' }}>{title}</Text>
      {hint ? (
        <Text style={{ color: t.sub, fontSize: 12.5, marginTop: 3, lineHeight: 18 }}>{hint}</Text>
      ) : null}
      <View style={{ marginTop: 14 }}>{children}</View>
    </View>
  );
}

export function Pill({ label, on, onPress, color }) {
  const t = useTheme();
  const c = color || t.a;
  return (
    <Pressable
      onPress={onPress}
      style={{
        paddingVertical: 8, paddingHorizontal: 14, borderRadius: 14,
        backgroundColor: on ? c : t.card2,
      }}
    >
      <Text style={{ color: on ? '#fff' : t.sub, fontWeight: '700', fontSize: 12.5 }}>{label}</Text>
    </Pressable>
  );
}

export function Btn({ label, onPress, colors, small }) {
  const t = useTheme();
  return (
    <Pressable onPress={onPress} style={({ pressed }) => ({ opacity: pressed ? 0.8 : 1 })}>
      <LinearGradient
        colors={colors || [t.a, t.c]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={{
          paddingVertical: small ? 9 : 13, paddingHorizontal: small ? 16 : 22,
          borderRadius: 16, alignItems: 'center',
        }}
      >
        <Text style={{ color: '#fff', fontWeight: '800', fontSize: small ? 13 : 15 }}>{label}</Text>
      </LinearGradient>
    </Pressable>
  );
}
