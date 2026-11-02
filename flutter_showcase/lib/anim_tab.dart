import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ui.dart';

class AnimTab extends StatelessWidget {
  const AnimTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Section(title: 'Animasi implisit', hint: 'AnimatedContainer, AnimatedScale — ketuk atau tunggu, bentuk berganti sendiri', child: MorphDemo()),
      Section(title: 'Spring & Bounce', hint: 'AnimatedScale + Curves.elasticOut, TweenSequence + Curves.bounceOut', child: SpringDemo()),
      Section(title: 'Pulse berulang', hint: 'AnimationController.repeat + CustomPainter', child: PulseDemo()),
      Section(title: 'Stagger', hint: 'Satu controller, tiap bar memakai Interval berbeda', child: StaggerDemo()),
      Section(title: 'Indikator mengetik', hint: 'Gelombang sinus dari satu controller', child: TypingDemo()),
      Section(title: 'Hitung naik', hint: 'TweenAnimationBuilder', child: CountDemo()),
      Section(title: 'Skeleton shimmer', hint: 'GradientTransform yang bergeser', child: SkeletonDemo()),
    ]);
  }
}

/* 1. Morph implisit ---------------------------------------------------- */
class MorphDemo extends StatefulWidget {
  const MorphDemo({super.key});
  @override
  State<MorphDemo> createState() => _MorphDemoState();
}

class _MorphDemoState extends State<MorphDemo> {
  int i = 0;
  Timer? timer;
  static const states = [
    (96.0, 14.0, kA, 0.0),
    (130.0, 65.0, kC, 0.5),
    (84.0, 30.0, kD, 1.0),
    (112.0, 8.0, kB, 1.5),
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 2200), (_) => _next());
  }

  void _next() {
    if (mounted) setState(() => i = (i + 1) % states.length);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (size, radius, color, turns) = states[i];
    return GestureDetector(
      onTap: _next,
      child: SizedBox(
        height: 140,
        child: Center(
          child: AnimatedRotation(
            turns: turns,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOutCubic,
              width: size,
              height: size,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius), boxShadow: glow(color)),
            ),
          ),
        ),
      ),
    );
  }
}

/* 2. Spring ------------------------------------------------------------ */
class SpringDemo extends StatefulWidget {
  const SpringDemo({super.key});
  @override
  State<SpringDemo> createState() => _SpringDemoState();
}

class _SpringDemoState extends State<SpringDemo> with SingleTickerProviderStateMixin {
  bool pressed = false;
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  late final Animation<double> y = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -80.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 26),
    TweenSequenceItem(tween: Tween(begin: -80.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 74),
  ]).animate(c);

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(
              onTapDown: (_) => setState(() => pressed = true),
              onTapUp: (_) => setState(() => pressed = false),
              onTapCancel: () => setState(() => pressed = false),
              child: AnimatedScale(
                scale: pressed ? 0.8 : 1,
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                child: Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: kA, borderRadius: BorderRadius.circular(24), boxShadow: glow(kA)),
                  child: const Text('👆', style: TextStyle(fontSize: 30)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Tekan & tahan', style: TextStyle(color: p.sub, fontSize: 12)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            AnimatedBuilder(
              animation: y,
              builder: (_, _) => Transform.translate(
                offset: Offset(0, y.value),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: kD, shape: BoxShape.circle, boxShadow: glow(kD)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradBtn(label: 'Lompat', colors: const [kD, kC], onTap: () => c.forward(from: 0)),
          ]),
        ],
      ),
    );
  }
}

/* 3. Pulse ------------------------------------------------------------- */
class PulseDemo extends StatefulWidget {
  const PulseDemo({super.key});
  @override
  State<PulseDemo> createState() => _PulseDemoState();
}

class _PulseDemoState extends State<PulseDemo> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(
          animation: c,
          builder: (_, _) => CustomPaint(size: const Size(300, 150), painter: _PulsePainter(c.value)),
        ),
        Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: kB, shape: BoxShape.circle, boxShadow: glow(kB)),
          child: const Text('📡', style: TextStyle(fontSize: 26)),
        ),
      ]),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double t;
  _PulsePainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = kB.withValues(alpha: (1 - p) * 0.8);
      canvas.drawCircle(c, 31 + p * 62, paint);
    }
  }

  @override
  bool shouldRepaint(_PulsePainter o) => o.t != t;
}

/* 4. Stagger ----------------------------------------------------------- */
class StaggerDemo extends StatefulWidget {
  const StaggerDemo({super.key});
  @override
  State<StaggerDemo> createState() => _StaggerDemoState();
}

class _StaggerDemoState extends State<StaggerDemo> with SingleTickerProviderStateMixin {
  static const hs = [48.0, 86.0, 64.0, 110.0, 78.0, 100.0, 56.0, 92.0];
  static const cols = [kA, kB, kC, kD, kE];
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 125,
        child: AnimatedBuilder(
          animation: c,
          builder: (_, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < hs.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Builder(builder: (_) {
                      final v = Interval(i * 0.07, i * 0.07 + 0.45, curve: Curves.elasticOut).transform(c.value);
                      return Opacity(
                        opacity: (v * 3).clamp(0.0, 1.0),
                        child: Container(
                          height: math.max(6, 6 + (hs[i] - 6) * v),
                          decoration: BoxDecoration(color: cols[i % cols.length], borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      GradBtn(label: 'Putar ulang', colors: const [kB, kA], onTap: () => c.forward(from: 0)),
    ]);
  }
}

/* 5. Typing ------------------------------------------------------------ */
class TypingDemo extends StatefulWidget {
  const TypingDemo({super.key});
  @override
  State<TypingDemo> createState() => _TypingDemoState();
}

class _TypingDemoState extends State<TypingDemo> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: p.card2,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
        ),
        child: AnimatedBuilder(
          animation: c,
          builder: (_, _) => Row(children: [
            for (var i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: Builder(builder: (_) {
                  final w = math.max(0.0, math.sin((c.value - i * 0.12) * 2 * math.pi));
                  return Transform.translate(
                    offset: Offset(0, -7 * w),
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: p.sub.withValues(alpha: 0.4 + 0.6 * w), shape: BoxShape.circle),
                    ),
                  );
                }),
              ),
          ]),
        ),
      ),
      const SizedBox(width: 12),
      Text('Sedang mengetik…', style: TextStyle(color: p.sub, fontSize: 13)),
    ]);
  }
}

/* 6. Count ------------------------------------------------------------- */
class CountDemo extends StatefulWidget {
  const CountDemo({super.key});
  @override
  State<CountDemo> createState() => _CountDemoState();
}

class _CountDemoState extends State<CountDemo> {
  int round = 0;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TOTAL SALDO', style: TextStyle(color: p.sub, fontSize: 12, fontWeight: FontWeight.w700)),
        TweenAnimationBuilder<double>(
          key: ValueKey(round),
          tween: Tween(begin: 0, end: 128450.0 + round * 5000),
          duration: const Duration(milliseconds: 1600),
          curve: Curves.easeOutExpo,
          builder: (_, v, _) => Text('Rp ${rupiah(v.round())}',
              style: TextStyle(color: p.ink, fontSize: 30, fontWeight: FontWeight.w800)),
        ),
      ]),
      GradBtn(label: 'Hitung', colors: const [kE, kB], onTap: () => setState(() => round++)),
    ]);
  }
}

/* 7. Skeleton ---------------------------------------------------------- */
class _Slide extends GradientTransform {
  final double pct;
  const _Slide(this.pct);
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * pct, 0, 0);
}

class SkeletonDemo extends StatefulWidget {
  const SkeletonDemo({super.key});
  @override
  State<SkeletonDemo> createState() => _SkeletonDemoState();
}

class _SkeletonDemoState extends State<SkeletonDemo> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Widget bone(Pal p, double? w, double h, double r) => AnimatedBuilder(
        animation: c,
        builder: (_, _) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: LinearGradient(
              colors: [p.card2, p.sub.withValues(alpha: 0.28), p.card2],
              stops: const [0.3, 0.5, 0.7],
              transform: _Slide(-1 + 2 * c.value),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(children: [
      for (var i = 0; i < 2; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(children: [
            bone(p, 54, 54, 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                bone(p, null, 14, 7),
                const SizedBox(height: 8),
                FractionallySizedBox(widthFactor: 0.5, child: bone(p, null, 12, 6)),
              ]),
            ),
          ]),
        ),
    ]);
  }
}
