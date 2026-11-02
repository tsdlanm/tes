import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'ui.dart';

class LayoutTab extends StatelessWidget {
  const LayoutTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Section(title: 'Row / Column playground', hint: 'Ubah direction, mainAxisAlignment, crossAxisAlignment', child: FlexDemo()),
      Section(title: 'Accordion', hint: 'AnimatedSize + AnimatedRotation', child: AccordionDemo()),
      Section(title: 'Transform 3D', hint: 'Matrix4 dengan perspektif, dipindah antar pose', child: Transform3D()),
      Section(title: 'Glassmorphism', hint: 'BackdropFilter + ImageFilter.blur', child: GlassDemo()),
      Section(title: 'Galeri bentuk', hint: 'Gradient, glow, dashed (CustomPainter), ClipPath, radius per sudut, skew', child: GalleryDemo()),
    ]);
  }
}

/* 1. Flex -------------------------------------------------------------- */
class FlexDemo extends StatefulWidget {
  const FlexDemo({super.key});
  @override
  State<FlexDemo> createState() => _FlexDemoState();
}

class _FlexDemoState extends State<FlexDemo> {
  Axis dir = Axis.horizontal;
  MainAxisAlignment main = MainAxisAlignment.start;
  CrossAxisAlignment cross = CrossAxisAlignment.start;
  Widget label(String t, Pal p) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Text(t, style: TextStyle(color: p.sub, fontSize: 11.5, fontWeight: FontWeight.w700)),
      );
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final boxes = [(kA, 44.0), (kC, 62.0), (kB, 50.0)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      label('direction', p),
      Wrap(spacing: 6, runSpacing: 6, children: [
        Pill(label: 'Row', on: dir == Axis.horizontal, onTap: () => setState(() => dir = Axis.horizontal)),
        Pill(label: 'Column', on: dir == Axis.vertical, onTap: () => setState(() => dir = Axis.vertical)),
      ]),
      label('mainAxisAlignment', p),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final e in {'start': MainAxisAlignment.start, 'center': MainAxisAlignment.center, 'spaceBetween': MainAxisAlignment.spaceBetween, 'spaceAround': MainAxisAlignment.spaceAround}.entries)
          Pill(label: e.key, color: kC, on: main == e.value, onTap: () => setState(() => main = e.value)),
      ]),
      label('crossAxisAlignment', p),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final e in {'start': CrossAxisAlignment.start, 'center': CrossAxisAlignment.center, 'end': CrossAxisAlignment.end, 'stretch': CrossAxisAlignment.stretch}.entries)
          Pill(label: e.key, color: kB, on: cross == e.value, onTap: () => setState(() => cross = e.value)),
      ]),
      const SizedBox(height: 14),
      Container(
        height: 170,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
        child: Flex(
          direction: dir,
          mainAxisAlignment: main,
          crossAxisAlignment: cross,
          children: [
            for (var i = 0; i < boxes.length; i++)
              Container(
                width: cross == CrossAxisAlignment.stretch && dir == Axis.vertical ? null : boxes[i].$2,
                height: cross == CrossAxisAlignment.stretch && dir == Axis.horizontal ? null : boxes[i].$2,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: boxes[i].$1, borderRadius: BorderRadius.circular(12)),
                child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
          ],
        ),
      ),
    ]);
  }
}

/* 2. Accordion --------------------------------------------------------- */
class AccordionDemo extends StatelessWidget {
  const AccordionDemo({super.key});
  static const faq = [
    ('Apa itu Flutter?', 'Toolkit UI dari Google. Flutter menggambar sendiri setiap piksel dengan mesin Impeller, bukan memakai widget native.'),
    ('Bahasa apa yang dipakai?', 'Dart, dengan hot reload sehingga perubahan UI terlihat dalam hitungan detik.'),
    ('Bisa jalan di mana saja?', 'Android, iOS, web, desktop (Windows, macOS, Linux) dari satu codebase.'),
  ];
  @override
  Widget build(BuildContext context) =>
      Column(children: [for (final f in faq) _Item(f.$1, f.$2)]);
}

class _Item extends StatefulWidget {
  final String q, a;
  const _Item(this.q, this.a);
  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => open = !open),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(widget.q, style: TextStyle(color: p.ink, fontWeight: FontWeight.w700, fontSize: 14.5))),
                AnimatedRotation(turns: open ? 0.375 : 0, duration: const Duration(milliseconds: 320), child: const Text('+', style: TextStyle(color: kA, fontSize: 20, fontWeight: FontWeight.w800))),
              ]),
              if (open) Padding(padding: const EdgeInsets.only(top: 10), child: Text(widget.a, style: TextStyle(color: p.sub, height: 1.45, fontSize: 13.5))),
            ]),
          ),
        ),
      ),
    );
  }
}

/* 3. 3D ---------------------------------------------------------------- */
class Transform3D extends StatefulWidget {
  const Transform3D({super.key});
  @override
  State<Transform3D> createState() => _Transform3DState();
}

class _Transform3DState extends State<Transform3D> {
  static const poses = [
    (0.0, 0.0, 0.0, 1.0, 'Datar'),
    (0.45, -0.6, 0.0, 1.0, 'Perspektif 3D'),
    (-0.3, 0.8, 0.0, 1.0, 'Putar Y'),
    (0.0, 0.0, 0.21, 1.12, 'Miring + scale'),
  ];
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final (rx, ry, rz, s, name) = poses[i];
    return GestureDetector(
      onTap: () => setState(() => i = (i + 1) % poses.length),
      child: Column(children: [
        SizedBox(
          height: 200,
          child: Center(
            child: TweenAnimationBuilder<List<double>>(
              tween: _PoseTween(end: [rx, ry, rz, s]),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(v[0])
                  ..rotateY(v[1])
                  ..rotateZ(v[2])
                  ..scaleByDouble(v[3], v[3], v[3], 1),
                child: child,
              ),
              child: Container(
                width: 230,
                height: 135,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [kA, kC, kD], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: glow(kA, 22),
                ),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('FLUTTER CARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 2)),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('•••• 4242', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 3)),
                    SizedBox(height: 4),
                    Text('IBRA REAL', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ]),
              ),
            ),
          ),
        ),
        Text('Ketuk kartu · $name', style: TextStyle(color: p.sub, fontSize: 12.5)),
      ]),
    );
  }
}

class _PoseTween extends Tween<List<double>> {
  _PoseTween({required List<double> end}) : super(end: end);
  @override
  List<double> lerp(double t) {
    final b = begin ?? end!;
    return [for (var i = 0; i < end!.length; i++) b[i] + (end![i] - b[i]) * t];
  }
}

/* 4. Glass ------------------------------------------------------------- */
class GlassDemo extends StatelessWidget {
  const GlassDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 180,
        child: Stack(alignment: Alignment.center, children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2B1B6B), Color(0xFF0E2A55)]))),
          Positioned(left: -20, top: -20, child: Container(width: 120, height: 120, decoration: const BoxDecoration(color: kC, shape: BoxShape.circle))),
          Positioned(right: 10, bottom: -30, child: Container(width: 140, height: 140, decoration: const BoxDecoration(color: kB, shape: BoxShape.circle))),
          Positioned(right: 70, top: 14, child: Container(width: 60, height: 60, decoration: const BoxDecoration(color: kD, shape: BoxShape.circle))),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 240,
                height: 110,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Kaca buram ✨', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Latar di belakang ikut kabur secara real-time.', style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/* 5. Gallery ----------------------------------------------------------- */
class _DashedPainter extends CustomPainter {
  final Color color;
  _DashedPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 12) {
        canvas.drawPath(m.extractPath(d, math.min(d + 7, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter o) => false;
}

class _DiamondClip extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(s.width / 2, 0)
    ..lineTo(s.width, s.height / 2)
    ..lineTo(s.width / 2, s.height)
    ..lineTo(0, s.height / 2)
    ..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> o) => false;
}

class GalleryDemo extends StatelessWidget {
  const GalleryDemo({super.key});
  @override
  Widget build(BuildContext context) {
    Widget cell(Widget Function(Widget inner) wrap, String e, String l, {Color fg = Colors.white}) => AspectRatio(
          aspectRatio: 1,
          child: wrap(Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(e, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(l, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 11)),
          ])),
        );
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        cell((c) => Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [kA, kB], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: c), '🌈', 'Gradient'),
        cell((c) => Container(decoration: BoxDecoration(color: kC, shape: BoxShape.circle, boxShadow: glow(kC, 14)), child: c), '💫', 'Glow'),
        cell((c) => CustomPaint(painter: _DashedPainter(kD), child: c), '✂️', 'Dashed', fg: kD),
        cell((c) => Container(decoration: const BoxDecoration(color: kE, borderRadius: BorderRadius.only(topLeft: Radius.circular(40), bottomRight: Radius.circular(40), topRight: Radius.circular(8), bottomLeft: Radius.circular(8))), child: c), '🍃', 'Radius'),
        cell((c) => ClipPath(clipper: _DiamondClip(), child: Container(color: kA, child: c)), '💎', 'ClipPath'),
        cell((c) => Transform(transform: Matrix4.identity()..rotateZ(-0.14)..setEntry(0, 1, -0.14), alignment: Alignment.center, child: Container(decoration: BoxDecoration(color: kB, borderRadius: BorderRadius.circular(20)), child: c)), '🌀', 'Skew'),
      ],
    );
  }
}
