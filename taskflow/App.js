import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Pressable,
  FlatList,
  Modal,
  StyleSheet,
  Platform,
  KeyboardAvoidingView,
  SafeAreaView,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';

const C = {
  bg: '#F4F2FF',
  card: '#FFFFFF',
  ink: '#1D1B3A',
  sub: '#7B7A99',
  line: '#ECEAF8',
  primary: '#6C4DFF',
  primary2: '#9A7BFF',
};

const CATEGORIES = {
  Kerja: { color: '#6C4DFF', bg: '#EFEBFF', icon: '💼' },
  Pribadi: { color: '#FF7A59', bg: '#FFEFEA', icon: '🌿' },
  Belajar: { color: '#12B886', bg: '#E3F8F0', icon: '📚' },
  Belanja: { color: '#F5A623', bg: '#FFF3DC', icon: '🛒' },
};

const PRIORITY = {
  Tinggi: '#FF4D6D',
  Sedang: '#F5A623',
  Rendah: '#12B886',
};

const INITIAL = [
  { id: '1', title: 'Presentasi desain sprint', cat: 'Kerja', pri: 'Tinggi', due: 'Hari ini, 14:00', done: false },
  { id: '2', title: 'Balas email klien', cat: 'Kerja', pri: 'Sedang', due: 'Hari ini, 16:30', done: true },
  { id: '3', title: 'Belajar React Native animasi', cat: 'Belajar', pri: 'Sedang', due: 'Besok, 09:00', done: false },
  { id: '4', title: 'Beli bahan masak mingguan', cat: 'Belanja', pri: 'Rendah', due: 'Besok, 17:00', done: false },
  { id: '5', title: 'Olahraga pagi 30 menit', cat: 'Pribadi', pri: 'Rendah', due: 'Hari ini, 06:00', done: true },
];

const FILTERS = ['Semua', 'Aktif', 'Selesai'];

function ProgressBar({ value }) {
  return (
    <View style={s.barTrack}>
      <View style={[s.barFill, { width: `${Math.round(value * 100)}%` }]} />
    </View>
  );
}

function TaskCard({ item, onToggle, onDelete }) {
  const cat = CATEGORIES[item.cat];
  return (
    <View style={s.card}>
      <Pressable onPress={() => onToggle(item.id)} hitSlop={8}>
        <View style={[s.check, item.done && { backgroundColor: C.primary, borderColor: C.primary }]}>
          {item.done && <Text style={s.checkMark}>✓</Text>}
        </View>
      </Pressable>
      <View style={{ flex: 1 }}>
        <Text style={[s.taskTitle, item.done && s.taskDone]} numberOfLines={2}>
          {item.title}
        </Text>
        <View style={s.metaRow}>
          <View style={[s.chip, { backgroundColor: cat.bg }]}>
            <Text style={[s.chipText, { color: cat.color }]}>
              {cat.icon} {item.cat}
            </Text>
          </View>
          <View style={[s.dot, { backgroundColor: PRIORITY[item.pri] }]} />
          <Text style={s.metaText}>{item.pri}</Text>
        </View>
        <Text style={s.due}>⏰ {item.due}</Text>
      </View>
      <Pressable onPress={() => onDelete(item.id)} hitSlop={8} style={s.del}>
        <Text style={{ fontSize: 16 }}>🗑️</Text>
      </Pressable>
    </View>
  );
}

function Segment({ options, value, onChange, colorFor }) {
  return (
    <View style={s.segment}>
      {options.map((o) => {
        const on = o === value;
        const color = colorFor ? colorFor(o) : C.primary;
        return (
          <Pressable
            key={o}
            onPress={() => onChange(o)}
            style={[s.segItem, on && { backgroundColor: color }]}
          >
            <Text style={[s.segText, on && { color: '#fff' }]}>{o}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

export default function App() {
  const [tasks, setTasks] = useState(INITIAL);
  const [filter, setFilter] = useState('Semua');
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState('');
  const [cat, setCat] = useState('Kerja');
  const [pri, setPri] = useState('Sedang');

  const doneCount = tasks.filter((t) => t.done).length;
  const progress = tasks.length ? doneCount / tasks.length : 0;

  const visible = useMemo(
    () =>
      tasks.filter((t) =>
        filter === 'Semua' ? true : filter === 'Aktif' ? !t.done : t.done
      ),
    [tasks, filter]
  );

  const toggle = (id) =>
    setTasks((p) => p.map((t) => (t.id === id ? { ...t, done: !t.done } : t)));
  const remove = (id) => setTasks((p) => p.filter((t) => t.id !== id));

  const add = () => {
    if (!title.trim()) return;
    setTasks((p) => [
      { id: String(Date.now()), title: title.trim(), cat, pri, due: 'Hari ini', done: false },
      ...p,
    ]);
    setTitle('');
    setCat('Kerja');
    setPri('Sedang');
    setOpen(false);
  };

  return (
    <SafeAreaView style={s.root}>
      <StatusBar style="light" />
      <FlatList
        data={visible}
        keyExtractor={(t) => t.id}
        contentContainerStyle={s.list}
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={
          <View>
            <LinearGradient
              colors={[C.primary, C.primary2]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={s.hero}
            >
              <Text style={s.hi}>Halo, Ibra 👋</Text>
              <Text style={s.heroTitle}>Ayo selesaikan{'\n'}tugas hari ini</Text>
              <View style={s.progressCard}>
                <View style={s.progressTop}>
                  <Text style={s.progressLabel}>Progres hari ini</Text>
                  <Text style={s.progressPct}>{Math.round(progress * 100)}%</Text>
                </View>
                <ProgressBar value={progress} />
                <Text style={s.progressSub}>
                  {doneCount} dari {tasks.length} tugas selesai
                </Text>
              </View>
            </LinearGradient>

            <View style={s.filterRow}>
              {FILTERS.map((f) => {
                const on = f === filter;
                return (
                  <Pressable
                    key={f}
                    onPress={() => setFilter(f)}
                    style={[s.filter, on && s.filterOn]}
                  >
                    <Text style={[s.filterText, on && { color: '#fff' }]}>{f}</Text>
                  </Pressable>
                );
              })}
            </View>
          </View>
        }
        renderItem={({ item }) => (
          <TaskCard item={item} onToggle={toggle} onDelete={remove} />
        )}
        ListEmptyComponent={
          <View style={s.empty}>
            <Text style={{ fontSize: 48 }}>🎉</Text>
            <Text style={s.emptyTitle}>Tidak ada tugas</Text>
            <Text style={s.emptySub}>Tekan tombol + untuk menambah tugas baru.</Text>
          </View>
        }
      />

      <Pressable onPress={() => setOpen(true)} style={s.fabWrap}>
        <LinearGradient colors={[C.primary, C.primary2]} style={s.fab}>
          <Text style={s.fabPlus}>+</Text>
        </LinearGradient>
      </Pressable>

      <Modal visible={open} animationType="slide" transparent onRequestClose={() => setOpen(false)}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          style={s.overlay}
        >
          <Pressable style={{ flex: 1 }} onPress={() => setOpen(false)} />
          <View style={s.sheet}>
            <View style={s.grabber} />
            <Text style={s.sheetTitle}>Tugas baru</Text>

            <TextInput
              value={title}
              onChangeText={setTitle}
              placeholder="Apa yang ingin kamu kerjakan?"
              placeholderTextColor={C.sub}
              style={s.input}
              autoFocus
            />

            <Text style={s.label}>Kategori</Text>
            <Segment
              options={Object.keys(CATEGORIES)}
              value={cat}
              onChange={setCat}
              colorFor={(o) => CATEGORIES[o].color}
            />

            <Text style={s.label}>Prioritas</Text>
            <Segment
              options={Object.keys(PRIORITY)}
              value={pri}
              onChange={setPri}
              colorFor={(o) => PRIORITY[o]}
            />

            <Pressable onPress={add} style={{ marginTop: 22 }}>
              <LinearGradient
                colors={[C.primary, C.primary2]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
                style={s.save}
              >
                <Text style={s.saveText}>Simpan tugas</Text>
              </LinearGradient>
            </Pressable>
          </View>
        </KeyboardAvoidingView>
      </Modal>
    </SafeAreaView>
  );
}

const shadow = Platform.select({
  web: { boxShadow: '0 6px 20px rgba(76, 56, 160, 0.10)' },
  default: {
    shadowColor: '#4C38A0',
    shadowOpacity: 0.1,
    shadowRadius: 14,
    shadowOffset: { width: 0, height: 6 },
    elevation: 3,
  },
});

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: C.bg },
  list: { paddingBottom: 120 },
  hero: {
    paddingTop: 36,
    paddingHorizontal: 22,
    paddingBottom: 26,
    borderBottomLeftRadius: 34,
    borderBottomRightRadius: 34,
  },
  hi: { color: 'rgba(255,255,255,0.85)', fontSize: 15, fontWeight: '600' },
  heroTitle: { color: '#fff', fontSize: 30, fontWeight: '800', marginTop: 6, lineHeight: 36 },
  progressCard: {
    marginTop: 22,
    backgroundColor: 'rgba(255,255,255,0.18)',
    borderRadius: 22,
    padding: 16,
  },
  progressTop: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 10 },
  progressLabel: { color: '#fff', fontWeight: '600', fontSize: 14 },
  progressPct: { color: '#fff', fontWeight: '800', fontSize: 18 },
  barTrack: { height: 10, borderRadius: 6, backgroundColor: 'rgba(255,255,255,0.3)', overflow: 'hidden' },
  barFill: { height: '100%', borderRadius: 6, backgroundColor: '#fff' },
  progressSub: { color: 'rgba(255,255,255,0.9)', marginTop: 10, fontSize: 13 },

  filterRow: { flexDirection: 'row', paddingHorizontal: 22, marginTop: 22, marginBottom: 8, gap: 10 },
  filter: {
    paddingVertical: 9,
    paddingHorizontal: 18,
    borderRadius: 20,
    backgroundColor: C.card,
    ...shadow,
  },
  filterOn: { backgroundColor: C.ink },
  filterText: { color: C.sub, fontWeight: '700', fontSize: 13 },

  card: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
    marginHorizontal: 22,
    marginTop: 12,
    padding: 16,
    borderRadius: 20,
    backgroundColor: C.card,
    ...shadow,
  },
  check: {
    width: 26,
    height: 26,
    borderRadius: 13,
    borderWidth: 2,
    borderColor: '#CFCBEE',
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkMark: { color: '#fff', fontWeight: '800', fontSize: 14, marginTop: -1 },
  taskTitle: { color: C.ink, fontSize: 16, fontWeight: '700' },
  taskDone: { textDecorationLine: 'line-through', color: C.sub },
  metaRow: { flexDirection: 'row', alignItems: 'center', marginTop: 8, gap: 8 },
  chip: { paddingVertical: 4, paddingHorizontal: 10, borderRadius: 10 },
  chipText: { fontSize: 12, fontWeight: '700' },
  dot: { width: 8, height: 8, borderRadius: 4 },
  metaText: { color: C.sub, fontSize: 12, fontWeight: '600' },
  due: { color: C.sub, fontSize: 12, marginTop: 6 },
  del: { padding: 6, borderRadius: 12, backgroundColor: '#F6F5FC' },

  empty: { alignItems: 'center', marginTop: 50, paddingHorizontal: 40 },
  emptyTitle: { color: C.ink, fontSize: 18, fontWeight: '800', marginTop: 10 },
  emptySub: { color: C.sub, textAlign: 'center', marginTop: 4 },

  fabWrap: { position: 'absolute', right: 24, bottom: 30, borderRadius: 31, ...shadow },
  fab: { width: 62, height: 62, borderRadius: 31, alignItems: 'center', justifyContent: 'center' },
  fabPlus: { color: '#fff', fontSize: 34, fontWeight: '400', marginTop: -2 },

  overlay: { flex: 1, backgroundColor: 'rgba(29,27,58,0.45)' },
  sheet: {
    backgroundColor: C.card,
    borderTopLeftRadius: 30,
    borderTopRightRadius: 30,
    padding: 24,
    paddingBottom: 32,
  },
  grabber: { alignSelf: 'center', width: 44, height: 5, borderRadius: 3, backgroundColor: C.line, marginBottom: 16 },
  sheetTitle: { color: C.ink, fontSize: 22, fontWeight: '800', marginBottom: 16 },
  input: {
    backgroundColor: C.bg,
    borderRadius: 16,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 16,
    color: C.ink,
    ...Platform.select({ web: { outlineStyle: 'none' } }),
  },
  label: { color: C.sub, fontWeight: '700', fontSize: 13, marginTop: 18, marginBottom: 8 },
  segment: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  segItem: { paddingVertical: 9, paddingHorizontal: 14, borderRadius: 14, backgroundColor: C.bg },
  segText: { color: C.sub, fontWeight: '700', fontSize: 13 },
  save: { paddingVertical: 16, borderRadius: 18, alignItems: 'center' },
  saveText: { color: '#fff', fontWeight: '800', fontSize: 16 },
});
