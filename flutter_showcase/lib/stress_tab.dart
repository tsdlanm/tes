import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'ui.dart';

Color fpsColor(num f) => f >= 50 ? kE : (f >= 30 ? kD : const Color(0xFFFF4D6D));

/// Dipanggil lewat compute(): di HP berjalan di isolate terpisah.
int heavyWork(int ms) {
  final sw = Stopwatch()..start();
  var x = 0;
  while (sw.elapsedMilliseconds < ms) {
    x++;
  }
  return x;
}

class StressTab extends StatelessWidget {
  const StressTab({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(children: [
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🔥 Uji beban — sama persis dengan versi React Native', style: TextStyle(color: p.ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Jalankan di HP asli dengan `flutter run --profile`. Mode debug dan browser tidak mewakili performa sebenarnya.',
              style: TextStyle(color: p.sub, fontSize: 12.5, height: 1.5)),
        ]),
      ),
      const Section(title: 'FPS', hint: 'UI thread: Ticker · Waktu frame: FrameTiming (build & raster)', child: FpsMeter()),
      const Section(title: 'Daftar 5.000 item', hint: 'ListView.builder dengan itemExtent tetap', child: BigList()),
      const Section(title: 'Animasi massal', hint: 'Bandingkan widget (AnimatedBuilder) vs satu CustomPainter', child: MassAnim()),
      const Section(title: 'Thread sibuk', hint: 'Kerja berat di UI isolate membuat animasi tersendat; compute() memindahkannya', child: BusyThread()),
    ]);
  }
}

/* FPS ------------------------------------------------------------------ */
class FpsMeter extends StatefulWidget {
  const FpsMeter({super.key});
  @override
  State<FpsMeter> createState() => _FpsMeterState();
}

class _FpsMeterState extends State<FpsMeter> with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  int frames = 0, fps = 0;
  Duration last = Duration.zero;
  double buildMs = 0, rasterMs = 0;
  bool hasTimings = false;

  void _timings(List<FrameTiming> ts) {
    if (ts.isEmpty) return;
    hasTimings = true;
    buildMs = ts.map((t) => t.buildDuration.inMicroseconds).reduce((a, b) => a + b) / ts.length / 1000;
    rasterMs = ts.map((t) => t.rasterDuration.inMicroseconds).reduce((a, b) => a + b) / ts.length / 1000;
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_timings);
    ticker = createTicker((e) {
      frames++;
      final dt = e - last;
      if (dt.inMilliseconds >= 500) {
        setState(() => fps = (frames * 1000 / dt.inMilliseconds).round());
        frames = 0;
        last = e;
      }
    })..start();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_timings);
    ticker.dispose();
    super.dispose();
  }

  Widget card(Pal p, String label, Widget value, double ratio, Color c) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: p.sub, fontSize: 11.5, fontWeight: FontWeight.w800)),
            SizedBox(height: 40, child: Align(alignment: Alignment.centerLeft, child: value)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: ratio.clamp(0.0, 1.0), minHeight: 6, color: c, backgroundColor: p.line),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final worst = math.max(buildMs, rasterMs);
    final budgetColor = worst <= 16.7 ? kE : (worst <= 33 ? kD : const Color(0xFFFF4D6D));
    return Row(children: [
      card(
        p,
        'UI THREAD',
        Text.rich(TextSpan(children: [
          TextSpan(text: '$fps', style: TextStyle(color: fpsColor(fps), fontSize: 30, fontWeight: FontWeight.w800)),
          TextSpan(text: ' fps', style: TextStyle(color: p.sub, fontSize: 13)),
        ])),
        fps / 60,
        fpsColor(fps),
      ),
      const SizedBox(width: 10),
      card(
        p,
        'WAKTU FRAME',
        Text(
          hasTimings ? 'build ${buildMs.toStringAsFixed(1)} ms\nraster ${rasterMs.toStringAsFixed(1)} ms' : 'tidak tersedia\ndi platform ini',
          style: TextStyle(color: hasTimings ? p.ink : p.sub, fontSize: 13, fontWeight: FontWeight.w700, height: 1.35),
        ),
        hasTimings ? worst / 16.7 : 0,
        budgetColor,
      ),
    ]);
  }
}

/* Daftar --------------------------------------------------------------- */
const _names = ['Adi', 'Ayu', 'Bagas', 'Bunga', 'Citra', 'Dewi', 'Dimas', 'Eka', 'Fajar', 'Gita', 'Hana', 'Indra', 'Joko', 'Kirana', 'Lukman', 'Maya', 'Nanda', 'Oki', 'Putri', 'Rangga'];
const _cols = [kA, kB, kC, kD, kE];
const _tags = ['Belanja', 'Gaji', 'Transfer', 'Tagihan'];
const _rowH = 64.0;

class BigList extends StatefulWidget {
  const BigList({super.key});
  @override
  State<BigList> createState() => _BigListState();
}

class _BigListState extends State<BigList> {
  final sc = ScrollController();
  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 380,
        decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: ListView.builder(
          controller: sc,
          itemCount: 5000,
          itemExtent: _rowH,
          itemBuilder: (_, i) {
            final name = '${_names[i % _names.length]} ${_names[(i * 7) % _names.length]}';
            final c = _cols[i % 5];
            final amount = ((i * 7919) % 990) * 1000 + 10000;
            final isIn = i % 3 == 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
              child: Row(children: [
                CircleAvatar(radius: 20, backgroundColor: c, child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.ink, fontWeight: FontWeight.w700, fontSize: 14.5)),
                    Text('Transaksi #${i + 1}', style: TextStyle(color: p.sub, fontSize: 12)),
                  ]),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${isIn ? '+' : '−'}Rp ${rupiah(amount)}', style: TextStyle(color: isIn ? kE : p.ink, fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: c.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(_tags[i % 4], style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        GradBtn(label: 'Lompat ke #4000', onTap: () => sc.animateTo(3999 * _rowH, duration: const Duration(milliseconds: 900), curve: Curves.easeInOutCubic)),
        const SizedBox(width: 10),
        GradBtn(label: 'Ke atas', colors: const [kB, kA], onTap: () => sc.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic)),
      ]),
    ]);
  }
}

/* Animasi massal ------------------------------------------------------- */
class MassAnim extends StatefulWidget {
  const MassAnim({super.key});
  @override
  State<MassAnim> createState() => _MassAnimState();
}

class _MassAnimState extends State<MassAnim> with SingleTickerProviderStateMixin {
  int n = 200;
  bool painter = false;
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  static const box = 16.0, cell = 22.0;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final k in const [50, 200, 500, 1000]) Pill(label: '$k kotak', on: n == k, onTap: () => setState(() => n = k)),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        Pill(label: 'Widget (AnimatedBuilder)', color: kE, on: !painter, onTap: () => setState(() => painter = false)),
        Pill(label: 'CustomPainter (1 kanvas)', color: kC, on: painter, onTap: () => setState(() => painter = true)),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(16)),
        child: LayoutBuilder(builder: (_, b) {
          final perRow = math.max(1, (b.maxWidth / cell).floor());
          final rows = (n / perRow).ceil();
          if (painter) {
            return AnimatedBuilder(
              animation: c,
              builder: (_, _) => CustomPaint(size: Size(b.maxWidth, rows * cell), painter: _BoxPainter(n, perRow, c.value)),
            );
          }
          return AnimatedBuilder(
            animation: c,
            builder: (_, _) => Wrap(children: [
              for (var i = 0; i < n; i++)
                Builder(builder: (_) {
                  final v = (c.value + (i * 0.137) % 1) % 1;
                  return SizedBox(
                    width: cell,
                    height: cell,
                    child: Center(
                      child: Transform.rotate(
                        angle: v * 2 * math.pi,
                        child: Transform.scale(
                          scale: 0.7 + 0.4 * math.sin(v * math.pi),
                          child: Container(
                            width: box,
                            height: box,
                            decoration: BoxDecoration(color: _cols[i % 5], borderRadius: BorderRadius.circular(5)),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ]),
          );
        }),
      ),
    ]);
  }
}

class _BoxPainter extends CustomPainter {
  final int n, perRow;
  final double t;
  _BoxPainter(this.n, this.perRow, this.t);
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 22.0, box = 16.0;
    final paint = Paint();
    final r = RRect.fromRectAndRadius(const Rect.fromLTWH(-box / 2, -box / 2, box, box), const Radius.circular(5));
    for (var i = 0; i < n; i++) {
      final v = (t + (i * 0.137) % 1) % 1;
      final s = 0.7 + 0.4 * math.sin(v * math.pi);
      canvas.save();
      canvas.translate((i % perRow) * cell + cell / 2, (i ~/ perRow) * cell + cell / 2);
      canvas.rotate(v * 2 * math.pi);
      canvas.scale(s);
      canvas.drawRRect(r, paint..color = _cols[i % 5]);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BoxPainter o) => o.t != t || o.n != n;
}

/* Thread sibuk --------------------------------------------------------- */
class BusyThread extends StatefulWidget {
  const BusyThread({super.key});
  @override
  State<BusyThread> createState() => _BusyThreadState();
}

class _BusyThreadState extends State<BusyThread> {
  Timer? timer;
  bool useIsolate = false;
  bool pending = false;

  void toggle() {
    if (timer != null) {
      timer!.cancel();
      setState(() => timer = null);
      return;
    }
    setState(() {
      timer = Timer.periodic(const Duration(milliseconds: 250), (_) async {
        if (useIsolate) {
          if (pending) return;
          pending = true;
          await compute(heavyWork, 120);
          pending = false;
        } else {
          heavyWork(120); // sengaja memblokir UI isolate
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final on = timer != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Menjalankan kerja berat 120ms setiap 250ms, meniru parsing JSON besar. '
        'Di Flutter, kode Dart dan animasi berbagi UI thread, jadi semua ikut tersendat — kecuali kerja itu dipindah ke isolate lain.',
        style: TextStyle(color: p.sub, fontSize: 13, height: 1.45),
      ),
      const SizedBox(height: 10),
      Wrap(spacing: 6, runSpacing: 6, children: [
        Pill(label: 'Di UI isolate', color: kC, on: !useIsolate, onTap: () => setState(() => useIsolate = false)),
        Pill(label: 'Pakai compute() (isolate lain)', color: kE, on: useIsolate, onTap: () => setState(() => useIsolate = true)),
      ]),
      if (kIsWeb)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('Catatan: di web, compute() tetap berjalan di thread utama.', style: TextStyle(color: p.sub, fontSize: 11.5)),
        ),
      const SizedBox(height: 10),
      GradBtn(
        label: on ? '⏹ Hentikan beban' : '▶ Jalankan beban',
        colors: on ? const [Color(0xFFFF4D6D), kC] : const [kD, kC],
        onTap: toggle,
      ),
    ]);
  }
}
