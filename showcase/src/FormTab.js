import React, { createElement, useRef, useState } from 'react';
import {
  View, Text, TextInput, Pressable, Switch, Platform, Alert, ActionSheetIOS, Keyboard,
} from 'react-native';
import Animated, {
  useSharedValue, useAnimatedStyle, withSequence, withTiming, withSpring, FadeInDown, FadeOutUp,
} from 'react-native-reanimated';
import DateTimePicker from '@react-native-community/datetimepicker';
import { Section, Btn, Pill, useTheme } from './ui';

const isWeb = Platform.OS === 'web';
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

function strength(pw) {
  let s = 0;
  if (pw.length >= 8) s++;
  if (/[A-Z]/.test(pw) && /[a-z]/.test(pw)) s++;
  if (/\d/.test(pw)) s++;
  if (/[^A-Za-z0-9]/.test(pw)) s++;
  return s;
}

/* Field dengan label, error, dan getar saat salah ----------------------- */
const Field = React.forwardRef(function Field({ label, error, icon, ...props }, ref) {
  const t = useTheme();
  const [focus, setFocus] = useState(false);
  const x = useSharedValue(0);
  const shake = () => {
    x.value = withSequence(
      withTiming(-8, { duration: 50 }), withTiming(8, { duration: 80 }),
      withTiming(-6, { duration: 70 }), withTiming(0, { duration: 50 })
    );
  };
  React.useEffect(() => { if (error) shake(); }, [error]);
  const st = useAnimatedStyle(() => ({ transform: [{ translateX: x.value }] }));
  return (
    <View style={{ marginBottom: 14 }}>
      <Text style={{ color: t.sub, fontSize: 12, fontWeight: '800', marginBottom: 6 }}>{label}</Text>
      <Animated.View
        style={[
          {
            flexDirection: 'row', alignItems: 'center', backgroundColor: t.card2, borderRadius: 16, paddingHorizontal: 14,
            borderWidth: 2, borderColor: error ? '#FF4D6D' : focus ? t.a : 'transparent',
          },
          st,
        ]}
      >
        <Text style={{ marginRight: 8 }}>{icon}</Text>
        <TextInput
          ref={ref}
          placeholderTextColor={t.sub}
          style={{ flex: 1, color: t.ink, fontSize: 15, paddingVertical: 13, outlineStyle: 'none' }}
          onFocus={() => setFocus(true)}
          onBlur={() => setFocus(false)}
          {...props}
        />
      </Animated.View>
      {error ? (
        <Animated.Text entering={FadeInDown} exiting={FadeOutUp} style={{ color: '#FF4D6D', fontSize: 12, marginTop: 5, fontWeight: '600' }}>
          {error}
        </Animated.Text>
      ) : null}
    </View>
  );
});

function StrengthBar({ score }) {
  const t = useTheme();
  const labels = ['Terlalu pendek', 'Lemah', 'Cukup', 'Kuat', 'Sangat kuat'];
  const cols = ['#FF4D6D', '#FF4D6D', '#FBBF24', '#34D399', '#34D399'];
  return (
    <View style={{ marginTop: -6, marginBottom: 14 }}>
      <View style={{ flexDirection: 'row', gap: 6 }}>
        {[0, 1, 2, 3].map((i) => (
          <View key={i} style={{ flex: 1, height: 5, borderRadius: 3, backgroundColor: i < score ? cols[score] : t.line }} />
        ))}
      </View>
      <Text style={{ color: cols[score], fontSize: 11.5, fontWeight: '700', marginTop: 4 }}>{labels[score]}</Text>
    </View>
  );
}

/* Tanggal: picker native di HP, <input type=date> di web ---------------- */
function DateField({ value, onChange }) {
  const t = useTheme();
  const [open, setOpen] = useState(false);
  const fmt = (d) => d.toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' });
  if (isWeb) {
    return createElement('input', {
      type: 'date',
      value: value.toISOString().slice(0, 10),
      max: new Date().toISOString().slice(0, 10),
      onChange: (e) => e.target.value && onChange(new Date(e.target.value)),
      style: {
        background: t.card2, color: t.ink, border: 'none', borderRadius: 16, padding: '13px 14px',
        fontSize: 15, fontFamily: 'inherit', colorScheme: t.name, width: '100%', boxSizing: 'border-box',
      },
    });
  }
  return (
    <View>
      <Pressable onPress={() => setOpen(true)} style={{ backgroundColor: t.card2, borderRadius: 16, padding: 14 }}>
        <Text style={{ color: t.ink, fontSize: 15 }}>📅  {fmt(value)}</Text>
      </Pressable>
      {open && (
        <DateTimePicker
          value={value}
          mode="date"
          maximumDate={new Date()}
          display={Platform.OS === 'ios' ? 'spinner' : 'default'}
          onChange={(e, d) => {
            if (Platform.OS !== 'ios') setOpen(false);
            if (d) onChange(d);
          }}
        />
      )}
    </View>
  );
}

function SignupForm() {
  const t = useTheme();
  const [f, setF] = useState({ name: '', email: '', phone: '', pw: '' });
  const [dob, setDob] = useState(new Date(2000, 0, 1));
  const [terms, setTerms] = useState(false);
  const [err, setErr] = useState({});
  const [done, setDone] = useState(false);
  const emailRef = useRef(), phoneRef = useRef(), pwRef = useRef();
  const set = (k) => (v) => { setF((p) => ({ ...p, [k]: v })); if (err[k]) setErr((e) => ({ ...e, [k]: undefined })); };
  const btn = useSharedValue(1);
  const btnStyle = useAnimatedStyle(() => ({ transform: [{ scale: btn.value }] }));

  const validate = () => {
    const e = {};
    if (f.name.trim().length < 3) e.name = 'Nama minimal 3 huruf';
    if (!EMAIL.test(f.email)) e.email = 'Format email belum benar';
    if (!/^(\+62|0)8\d{8,11}$/.test(f.phone.replace(/\s|-/g, ''))) e.phone = 'Nomor HP Indonesia, mis. 0812 3456 7890';
    if (strength(f.pw) < 2) e.pw = 'Kata sandi terlalu lemah';
    if (!terms) e.terms = 'Setujui syarat dan ketentuan';
    return e;
  };
  const submit = () => {
    Keyboard.dismiss();
    const e = validate();
    setErr(e);
    btn.value = withSequence(withTiming(0.94, { duration: 80 }), withSpring(1));
    if (Object.keys(e).length === 0) setDone(true);
  };

  if (done) {
    return (
      <Animated.View entering={FadeInDown.springify()} style={{ alignItems: 'center', paddingVertical: 20 }}>
        <Text style={{ fontSize: 54 }}>🎉</Text>
        <Text style={{ color: t.ink, fontSize: 20, fontWeight: '800', marginTop: 8 }}>Selamat datang, {f.name.split(' ')[0]}!</Text>
        <Text style={{ color: t.sub, marginTop: 4, marginBottom: 16 }}>{f.email}</Text>
        <Btn small label="Ulangi" onPress={() => { setDone(false); setF({ name: '', email: '', phone: '', pw: '' }); setTerms(false); }} />
      </Animated.View>
    );
  }

  return (
    <View>
      <Field label="NAMA LENGKAP" icon="👤" placeholder="Ibra Real" value={f.name} onChangeText={set('name')} error={err.name}
        autoComplete="name" textContentType="name" returnKeyType="next" onSubmitEditing={() => emailRef.current?.focus()} blurOnSubmit={false} />
      <Field ref={emailRef} label="EMAIL" icon="✉️" placeholder="nama@email.com" value={f.email} onChangeText={set('email')} error={err.email}
        keyboardType="email-address" autoCapitalize="none" autoCorrect={false} autoComplete="email" textContentType="emailAddress"
        returnKeyType="next" onSubmitEditing={() => phoneRef.current?.focus()} blurOnSubmit={false} />
      <Field ref={phoneRef} label="NOMOR HP" icon="📱" placeholder="0812 3456 7890" value={f.phone} onChangeText={set('phone')} error={err.phone}
        keyboardType="phone-pad" autoComplete="tel" textContentType="telephoneNumber"
        returnKeyType="next" onSubmitEditing={() => pwRef.current?.focus()} blurOnSubmit={false} />
      <Field ref={pwRef} label="KATA SANDI" icon="🔒" placeholder="Minimal 8 karakter" value={f.pw} onChangeText={set('pw')} error={err.pw}
        secureTextEntry autoComplete="new-password" textContentType="newPassword" returnKeyType="done" onSubmitEditing={submit} />
      {f.pw.length > 0 && <StrengthBar score={strength(f.pw)} />}

      <Text style={{ color: t.sub, fontSize: 12, fontWeight: '800', marginBottom: 6 }}>TANGGAL LAHIR</Text>
      <View style={{ marginBottom: 14 }}><DateField value={dob} onChange={setDob} /></View>

      <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: err.terms ? 4 : 18 }}>
        <Text style={{ color: t.ink, flex: 1, fontSize: 14 }}>Saya setuju dengan syarat & ketentuan</Text>
        <Switch value={terms} onValueChange={(v) => { setTerms(v); if (v) setErr((e) => ({ ...e, terms: undefined })); }}
          trackColor={{ false: t.card2, true: t.a }} thumbColor="#fff" activeThumbColor="#fff" />
      </View>
      {err.terms ? <Text style={{ color: '#FF4D6D', fontSize: 12, fontWeight: '600', marginBottom: 14 }}>{err.terms}</Text> : null}

      <Animated.View style={btnStyle}><Btn label="Daftar" onPress={submit} /></Animated.View>
    </View>
  );
}

/* Dialog & sheet yang mengikuti platform -------------------------------- */
function NativeDialogs() {
  const t = useTheme();
  const [log, setLog] = useState('Belum ada aksi');

  const confirm = () => {
    if (isWeb) {
      setLog(window.confirm('Hapus 3 foto ini?') ? 'Dihapus' : 'Dibatalkan');
      return;
    }
    Alert.alert('Hapus 3 foto?', 'Tindakan ini tidak bisa dibatalkan.', [
      { text: 'Batal', style: 'cancel', onPress: () => setLog('Dibatalkan') },
      { text: 'Hapus', style: 'destructive', onPress: () => setLog('Dihapus') },
    ]);
  };
  const sheet = () => {
    const opts = ['Ambil foto', 'Pilih dari galeri', 'Hapus foto', 'Batal'];
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions(
        { options: opts, destructiveButtonIndex: 2, cancelButtonIndex: 3 },
        (i) => setLog(`Action sheet iOS: ${opts[i]}`)
      );
    } else {
      // Android/web: tidak ada ActionSheet bawaan, pakai Alert (Android) atau prompt (web)
      if (isWeb) setLog('Di web tidak ada action sheet bawaan');
      else Alert.alert('Foto profil', undefined, opts.slice(0, 3).map((o) => ({ text: o, onPress: () => setLog(`Dialog Android: ${o}`) })));
    }
  };
  return (
    <View style={{ gap: 12 }}>
      <View style={{ flexDirection: 'row', gap: 10, flexWrap: 'wrap' }}>
        <Btn small label="Alert konfirmasi" onPress={confirm} />
        <Btn small label="Action sheet" colors={[t.b, t.a]} onPress={sheet} />
      </View>
      <View style={{ backgroundColor: t.card2, borderRadius: 14, padding: 12 }}>
        <Text style={{ color: t.sub, fontSize: 12, fontWeight: '800' }}>HASIL</Text>
        <Text style={{ color: t.ink, fontWeight: '700', marginTop: 2 }}>{log}</Text>
      </View>
      <Text style={{ color: t.sub, fontSize: 12.5, lineHeight: 19 }}>
        Di iOS dan Android, <Text style={{ fontWeight: '800', color: t.ink }}>Alert</Text>, <Text style={{ fontWeight: '800', color: t.ink }}>Switch</Text> dan{' '}
        <Text style={{ fontWeight: '800', color: t.ink }}>DateTimePicker</Text> adalah komponen asli sistem — bentuknya otomatis mengikuti platform dan
        versi OS. Di browser ini mereka diganti padanan web, jadi pratinjau tidak mewakili.
      </Text>
    </View>
  );
}

export default function FormTab() {
  return (
    <>
      <Section title="Form pendaftaran" hint="Alur fokus antar field (Enter pindah ke field berikut), keyboard sesuai jenis input, validasi dengan animasi getar">
        <SignupForm />
      </Section>
      <Section title="Dialog & sheet native" hint="Alert, ActionSheetIOS — tampil beda di iOS dan Android"><NativeDialogs /></Section>
    </>
  );
}
