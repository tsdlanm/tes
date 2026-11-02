import React from 'react';
import { View, Text, Pressable, FlatList } from 'react-native';
import { NavigationContainer, DefaultTheme, DarkTheme } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { LinearGradient } from 'expo-linear-gradient';
import { Section, Btn, useTheme, glow } from './ui';

const PLACES = [
  { id: 'bali', name: 'Senja Pantai', city: 'Bali', e: '🌅', c: ['#FF9A8B', '#FF6A88'], d: 'Pantai dengan matahari terbenam terbaik untuk fotografi. Datang satu jam sebelum senja.' },
  { id: 'bogor', name: 'Hutan Pagi', city: 'Bogor', e: '🌲', c: ['#43E97B', '#38F9D7'], d: 'Jalur trekking ringan dengan kabut tipis setiap pagi. Cocok untuk keluarga.' },
  { id: 'jkt', name: 'Kota Malam', city: 'Jakarta', e: '🌃', c: ['#667EEA', '#764BA2'], d: 'Rooftop dengan pemandangan gedung-gedung yang menyala sepanjang malam.' },
  { id: 'papua', name: 'Gunung Salju', city: 'Papua', e: '🏔️', c: ['#4FACFE', '#00F2FE'], d: 'Salah satu dari sedikit puncak bersalju di daerah tropis dunia.' },
];

function Home({ navigation }) {
  const t = useTheme();
  return (
    <FlatList
      data={PLACES}
      keyExtractor={(i) => i.id}
      contentContainerStyle={{ padding: 16, gap: 12 }}
      renderItem={({ item }) => (
        <Pressable onPress={() => navigation.navigate('Detail', { id: item.id })}>
          <LinearGradient colors={item.c} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={{ borderRadius: 22, padding: 16, flexDirection: 'row', alignItems: 'center', gap: 14 }}>
            <Text style={{ fontSize: 38 }}>{item.e}</Text>
            <View style={{ flex: 1 }}>
              <Text style={{ color: '#fff', fontSize: 18, fontWeight: '800' }}>{item.name}</Text>
              <Text style={{ color: '#ffffffcc', fontWeight: '600' }}>{item.city}</Text>
            </View>
            <Text style={{ color: '#fff', fontSize: 22 }}>›</Text>
          </LinearGradient>
        </Pressable>
      )}
      ListFooterComponent={
        <Text style={{ color: t.sub, textAlign: 'center', fontSize: 12, marginTop: 6 }}>Ketuk kartu untuk membuka halaman detail</Text>
      }
    />
  );
}

function Detail({ route, navigation }) {
  const t = useTheme();
  const p = PLACES.find((x) => x.id === route.params.id);
  return (
    <View style={{ flex: 1, backgroundColor: t.bg }}>
      <LinearGradient colors={p.c} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={{ height: 180, alignItems: 'center', justifyContent: 'center' }}>
        <Text style={{ fontSize: 80 }}>{p.e}</Text>
      </LinearGradient>
      <View style={{ padding: 20, gap: 10 }}>
        <Text style={{ color: t.ink, fontSize: 24, fontWeight: '800' }}>{p.name}</Text>
        <Text style={{ color: t.sub, lineHeight: 21 }}>{p.d}</Text>
        <View style={{ flexDirection: 'row', gap: 10, marginTop: 8 }}>
          <Btn small label="Pesan" onPress={() => navigation.navigate('Booking', { id: p.id })} />
          <Btn small label="Tempat lain" colors={[t.b, t.a]} onPress={() => navigation.push('Detail', { id: PLACES[(PLACES.indexOf(p) + 1) % PLACES.length].id })} />
        </View>
      </View>
    </View>
  );
}

function Booking({ route, navigation }) {
  const t = useTheme();
  const p = PLACES.find((x) => x.id === route.params.id);
  return (
    <View style={{ flex: 1, backgroundColor: t.card, padding: 24, alignItems: 'center', justifyContent: 'center', gap: 10 }}>
      <Text style={{ fontSize: 54 }}>🎟️</Text>
      <Text style={{ color: t.ink, fontSize: 20, fontWeight: '800' }}>Pesan {p.name}</Text>
      <Text style={{ color: t.sub, textAlign: 'center', lineHeight: 20 }}>
        Layar ini dibuka sebagai modal: muncul dari bawah dan bisa ditutup dengan menggeser ke bawah di iOS.
      </Text>
      <Btn label="Selesai" onPress={() => navigation.popToTop()} />
    </View>
  );
}

const Stack = createNativeStackNavigator();

function Demo() {
  const t = useTheme();
  const base = t.name === 'dark' ? DarkTheme : DefaultTheme;
  const theme = { ...base, colors: { ...base.colors, background: t.bg, card: t.card, text: t.ink, border: t.line, primary: t.a } };
  return (
    <View style={{ height: 540, borderRadius: 20, overflow: 'hidden', borderWidth: 1, borderColor: t.line }}>
      <NavigationContainer theme={theme} documentTitle={{ enabled: false }} linking={undefined}>
        <Stack.Navigator
          screenOptions={{
            headerTitleStyle: { fontWeight: '800' },
            headerShadowVisible: false,
            animation: 'slide_from_right',
            gestureEnabled: true,
          }}
        >
          <Stack.Screen name="Home" component={Home} options={{ title: 'Jelajah', headerLargeTitle: true }} />
          <Stack.Screen name="Detail" component={Detail} options={({ route }) => ({ title: PLACES.find((x) => x.id === route.params.id).name })} />
          <Stack.Screen name="Booking" component={Booking} options={{ presentation: 'modal', animation: 'slide_from_bottom', title: 'Pemesanan' }} />
        </Stack.Navigator>
      </NavigationContainer>
    </View>
  );
}

export default function NavTab() {
  return (
    <>
      <Section title="Navigasi antar layar" hint="@react-navigation/native-stack — push, back, modal dari bawah. Di HP memakai UINavigationController (iOS) dan Fragment (Android) asli.">
        <Demo />
      </Section>
    </>
  );
}
