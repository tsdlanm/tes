import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'ui.dart';

/// Padanan tab "Pro" di versi React Native (Reanimated + Gesture Handler + Skia).
/// Di Flutter semuanya sudah ada di SDK, tanpa package tambahan.
class ProTab extends StatelessWidget {
  const ProTab({super.key});
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
          Text('⚡ Padanan tab Pro versi React Native', style: TextStyle(color: p.ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Versi RN butuh Reanimated, Gesture Handler, dan Skia. Di Flutter semua demo ini memakai SDK bawaan. '
            'Glassmorphism dan grafik Bezier ada di tab Layout dan Grafik.',
            style: TextStyle(color: p.sub, fontSize: 12.5, height: 1.5),
          ),
        ]),
      ),
      const Section(title: 'Lempar (fling)', hint: 'FrictionSimulation + SpringSimulation di tepi — momentum seperti iOS', child: FlingDemo()),
      const Section(title: 'Cubit, putar, geser', hint: 'onScaleUpdate memberi scale, rotation, dan focalPointDelta sekaligus', child: PinchDemo()),
      const Section(title: 'Layout animation', hint: 'AnimatedList — sisip & hapus beranimasi. Catatan: urutan acak tidak dianimasikan otomatis seperti di Reanimated.', child: ListAnimDemo()),
      const Section(title: 'Gooey metaballs', hint: 'ImageFiltered (blur) + ColorFiltered (matrix alpha), posisi dari Ticker', child: GooeyDemo()),
    ]);
  }
}

/* 1. Fling ------------------------------------------------------------- */
class FlingDemo extends StatefulWidget {
  const FlingDemo({super.key});
  @override
  State<FlingDemo> createState() => _FlingDemoState();
}

class _FlingDemoState extends State<FlingDemo> with TickerProviderStateMixin {
  static const size = 90.0, h = 210.0;
  static const spring = SpringDescription(mass: 1, stiffness: 180, damping: 18);
  late final AnimationController ax = AnimationController.unbounded(vsync: this);
  late final AnimationController ay = AnimationController.unbounded(vsync: this);
  final Set<AnimationController> bouncing = {};
  double bx = 100, by = (h - size) / 2;
  bool down = false;

  @override
  void initState() {
    super.initState();
    ax.addListener(() => _edge(ax, bx));
    ay.addListener(() => _edge(ay, by));
  }

  // Saat melewati tepi, ganti friksi dengan spring kembali ke tepi (efek rubber band).
  void _edge(AnimationController c, double b) {
    setState(() {});
    if (c.isAnimating && !bouncing.contains(c) && c.value.abs() > b) {
      bouncing.add(c);
      c.animateWith(SpringSimulation(spring, c.value, c.value.sign * b, c.velocity));
    }
  }

  @override
  void dispose() {
    ax.dispose();
    ay.dispose();
    super.dispose();
  }

  void _springTo0(AnimationController c) {
    bouncing.add(c);
    c.animateWith(SpringSimulation(spring, c.value, 0, c.velocity));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return LayoutBuilder(builder: (_, box) {
      bx = math.max(0, (box.maxWidth - size) / 2);
      return Container(
        height: h,
        width: double.infinity,
        decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(top: 12, child: Text('Lempar kartunya · ketuk 2x untuk kembali', style: TextStyle(color: p.sub, fontSize: 12))),
          GestureDetector(
            onDoubleTap: () {
              _springTo0(ax);
              _springTo0(ay);
            },
            onPanStart: (_) {
              ax.stop();
              ay.stop();
              setState(() => down = true);
            },
            onPanUpdate: (d) {
              ax.value += d.delta.dx;
              ay.value += d.delta.dy;
            },
            onPanEnd: (d) {
              setState(() => down = false);
              bouncing.clear();
              final v = d.velocity.pixelsPerSecond;
              ax.animateWith(FrictionSimulation(0.12, ax.value, v.dx));
              ay.animateWith(FrictionSimulation(0.12, ay.value, v.dy));
            },
            child: Transform.translate(
              offset: Offset(ax.value, ay.value),
              child: Transform.rotate(
                angle: ax.value / 8 * math.pi / 180,
                child: AnimatedScale(
                  scale: down ? 1.12 : 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: kA, borderRadius: BorderRadius.circular(26), boxShadow: glow(kA)),
                    child: const Text('🥏', style: TextStyle(fontSize: 36)),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
    });
  }
}

/* 2. Pinch ------------------------------------------------------------- */
class PinchDemo extends StatefulWidget {
  const PinchDemo({super.key});
  @override
  State<PinchDemo> createState() => _PinchDemoState();
}

class _PinchDemoState extends State<PinchDemo> with SingleTickerProviderStateMixin {
  double s = 1, r = 0, baseS = 1, baseR = 0;
  Offset o = Offset.zero;
  late final AnimationController reset = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  double fs = 1, fr = 0;
  Offset fo = Offset.zero;

  @override
  void initState() {
    super.initState();
    reset.addListener(() {
      final t = Curves.elasticOut.transform(reset.value);
      setState(() {
        s = lerpDouble(fs, 1, t)!;
        r = lerpDouble(fr, 0, t)!;
        o = Offset.lerp(fo, Offset.zero, t)!;
      });
    });
  }

  @override
  void dispose() {
    reset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.hardEdge,
      child: Stack(alignment: Alignment.center, children: [
        Positioned(top: 12, child: Text('Di HP: cubit & putar dengan dua jari', style: TextStyle(color: p.sub, fontSize: 12))),
        GestureDetector(
          onDoubleTap: () {
            fs = s;
            fr = r;
            fo = o;
            reset.forward(from: 0);
          },
          onScaleStart: (_) {
            reset.stop();
            baseS = s;
            baseR = r;
          },
          onScaleUpdate: (d) => setState(() {
            s = (baseS * d.scale).clamp(0.5, 3.0);
            r = baseR + d.rotation;
            o += d.focalPointDelta;
          }),
          child: Transform.translate(
            offset: o,
            child: Transform.rotate(
              angle: r,
              child: Transform.scale(
                scale: s,
                child: Container(
                  width: 150,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: kC, borderRadius: BorderRadius.circular(22), boxShadow: glow(kC)),
                  child: const Text('🖼️', style: TextStyle(fontSize: 38)),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/* 3. AnimatedList ------------------------------------------------------ */
class ListAnimDemo extends StatefulWidget {
  const ListAnimDemo({super.key});
  @override
  State<ListAnimDemo> createState() => _ListAnimDemoState();
}

class _ListAnimDemoState extends State<ListAnimDemo> {
  final key = GlobalKey<AnimatedListState>();
  final items = [1, 2, 3, 4];
  int next = 5;
  final rnd = math.Random();
  static const cols = [kA, kB, kC, kD, kE];

  Widget tile(int n, Animation<double> a) => SizeTransition(
        sizeFactor: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
        child: ScaleTransition(
          scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => remove(n),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: cols[n % 5], borderRadius: BorderRadius.circular(14)),
                child: Text('#$n  ✕', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
      );

  void add() {
    final at = rnd.nextInt(items.length + 1);
    items.insert(at, next++);
    key.currentState!.insertItem(at, duration: const Duration(milliseconds: 450));
  }

  void remove(int n) {
    final i = items.indexOf(n);
    if (i < 0) return;
    items.removeAt(i);
    key.currentState!.removeItem(i, (_, a) => tile(n, a), duration: const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedList(
        key: key,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        initialItemCount: items.length,
        itemBuilder: (_, i, a) => tile(items[i], a),
      ),
      const SizedBox(height: 6),
      GradBtn(label: 'Tambah', onTap: add),
    ]);
  }
}

/* 4. Gooey ------------------------------------------------------------- */
class GooeyDemo extends StatefulWidget {
  const GooeyDemo({super.key});
  @override
  State<GooeyDemo> createState() => _GooeyDemoState();
}

class _GooeyDemoState extends State<GooeyDemo> with SingleTickerProviderStateMixin {
  static const h = 220.0;
  late final Ticker ticker;
  double ms = 0;
  Offset? drag;

  @override
  void initState() {
    super.initState();
    ticker = createTicker((e) => setState(() => ms = e.inMicroseconds / 1000))..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  Widget blob(double x, double y, double r, Color c) => Positioned(
        left: x - r,
        top: y - r,
        child: Container(width: r * 2, height: r * 2, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return LayoutBuilder(builder: (_, box) {
      final w = box.maxWidth;
      final d = drag ?? Offset(w * 0.75, h / 2);
      return GestureDetector(
        onPanUpdate: (e) => setState(() => drag = d + e.delta),
        child: Container(
          height: h,
          decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.hardEdge,
          child: Stack(children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 18, -7 * 255]),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: SizedBox(
                  width: w,
                  height: h,
                  child: Stack(children: [
                    blob(w / 2 + math.cos(ms / 900) * w * 0.28, h / 2 + math.sin(ms / 700) * 50, 36, kA),
                    blob(w / 2 + math.sin(ms / 1100) * w * 0.3, h / 2 + math.cos(ms / 800) * 55, 30, kB),
                    blob(w / 2 + math.cos(ms / 1300 + 2) * w * 0.2, h / 2 + math.sin(ms / 600 + 1) * 40, 26, kE),
                    blob(d.dx, d.dy, 42, kC),
                  ]),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Text('Seret di area ini untuk menggerakkan blob pink',
                  textAlign: TextAlign.center, style: TextStyle(color: p.sub, fontSize: 12)),
            ),
          ]),
        ),
      );
    });
  }
}
