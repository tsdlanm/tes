import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'ui.dart';

class GestureTab extends StatelessWidget {
  const GestureTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Section(title: 'Drag & spring', hint: 'GestureDetector + SpringSimulation, berputar mengikuti posisi', child: DragDemo()),
      Section(title: 'Swipe untuk hapus', hint: 'Dismissible bawaan Flutter — geser baris ke kiri', child: SwipeDemo()),
      Section(title: 'Tap, double-tap & long-press', hint: 'Double-tap untuk suka, tahan untuk getar', child: TapDemo()),
      Section(title: 'Hero transition', hint: 'Ketuk kartu — elemen "terbang" ke halaman berikutnya', child: HeroDemo()),
      Section(title: 'Slider kustom', hint: 'onHorizontalDragUpdate + warna HSL', child: SliderDemo()),
    ]);
  }
}

/* 1. Drag -------------------------------------------------------------- */
class DragDemo extends StatefulWidget {
  const DragDemo({super.key});
  @override
  State<DragDemo> createState() => _DragDemoState();
}

class _DragDemoState extends State<DragDemo> with SingleTickerProviderStateMixin {
  Offset off = Offset.zero;
  Offset from = Offset.zero;
  bool down = false;
  late final AnimationController c = AnimationController.unbounded(vsync: this)
    ..addListener(() => setState(() => off = Offset.lerp(from, Offset.zero, c.value)!));

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void release() {
    from = off;
    c.value = 0;
    c.animateWith(SpringSimulation(const SpringDescription(mass: 1, stiffness: 120, damping: 7), 0, 1, 0));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.hardEdge,
      child: Stack(alignment: Alignment.center, children: [
        Positioned(
          top: 12,
          child: Text(down ? 'Lepas untuk melihat spring kembali' : 'Seret kartu ke mana saja',
              style: TextStyle(color: p.sub, fontSize: 12)),
        ),
        GestureDetector(
          onPanStart: (_) {
            c.stop();
            setState(() => down = true);
          },
          onPanUpdate: (d) => setState(() => off += d.delta),
          onPanEnd: (_) {
            setState(() => down = false);
            release();
          },
          child: Transform.translate(
            offset: off,
            child: Transform.rotate(
              angle: (off.dx / 150).clamp(-1.0, 1.0) * 0.32,
              child: AnimatedScale(
                scale: down ? 1.15 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 110,
                  height: 110,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: kC, borderRadius: BorderRadius.circular(28), boxShadow: glow(kC)),
                  child: const Text('🎈', style: TextStyle(fontSize: 40)),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/* 2. Dismissible ------------------------------------------------------- */
class SwipeDemo extends StatefulWidget {
  const SwipeDemo({super.key});
  @override
  State<SwipeDemo> createState() => _SwipeDemoState();
}

class _SwipeDemoState extends State<SwipeDemo> {
  static const all = [
    (1, '📩', 'Undangan rapat', 'Geser ke kiri untuk menghapus'),
    (2, '🎵', 'Playlist baru', '12 lagu ditambahkan'),
    (3, '📦', 'Paket tiba', 'Diantar kurir pukul 10.30'),
    (4, '🗓️', 'Pengingat ulang tahun', 'Sabtu ini'),
  ];
  late List<(int, String, String, String)> rows = List.of(all);

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Dismissible(
              key: ValueKey(r.$1),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => setState(() => rows.removeWhere((x) => x.$1 == r.$1)),
              background: Container(
                color: const Color(0xFFFF4D6D),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
              ),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: p.card2, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(18)),
                child: Row(children: [
                  Text(r.$2, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.$3, style: TextStyle(color: p.ink, fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(r.$4, style: TextStyle(color: p.sub, fontSize: 12.5)),
                    ]),
                  ),
                  Icon(Icons.chevron_left_rounded, color: p.sub),
                ]),
              ),
            ),
          ),
        ),
      if (rows.isEmpty)
        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('🎉 Semua bersih!'))),
      const SizedBox(height: 6),
      GradBtn(label: 'Isi ulang', onTap: () => setState(() => rows = List.of(all))),
    ]);
  }
}

/* 3. Tap --------------------------------------------------------------- */
class TapDemo extends StatefulWidget {
  const TapDemo({super.key});
  @override
  State<TapDemo> createState() => _TapDemoState();
}

class _TapDemoState extends State<TapDemo> {
  int likes = 0, burst = 0;
  String msg = 'Ketuk dua kali kartu ini';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => setState(() {
        likes++;
        burst++;
        msg = 'Disukai! ❤️';
      }),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => msg = 'Long-press terdeteksi 📳');
      },
      onTap: () => setState(() => msg = 'Tap sekali'),
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [kA, kC], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Stack(alignment: Alignment.center, children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 4),
            Text('$likes suka', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
          if (burst > 0)
            TweenAnimationBuilder<double>(
              key: ValueKey(burst),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (_, v, _) => Opacity(
                opacity: 1 - v,
                child: Transform.translate(
                  offset: Offset(0, -60 * v),
                  child: Transform.scale(scale: 0.6 + v * 1.4, child: const Text('❤️', style: TextStyle(fontSize: 46))),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/* 4. Hero -------------------------------------------------------------- */
class HeroDemo extends StatelessWidget {
  const HeroDemo({super.key});
  static const items = [
    ('Senja', '🌅', [Color(0xFFFF9A8B), Color(0xFFFF6A88)]),
    ('Hutan', '🌲', [Color(0xFF43E97B), Color(0xFF38F9D7)]),
    ('Kota', '🌃', [Color(0xFF667EEA), Color(0xFF764BA2)]),
  ];
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final it in items)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 550),
                reverseTransitionDuration: const Duration(milliseconds: 450),
                pageBuilder: (_, _, _) => _HeroPage(it.$1, it.$2, it.$3),
                transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
              )),
              child: Hero(
                tag: 'hero-${it.$1}',
                child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(colors: it.$3, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Text(it.$2, style: const TextStyle(fontSize: 38, decoration: TextDecoration.none)),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

class _HeroPage extends StatelessWidget {
  final String title, emoji;
  final List<Color> colors;
  const _HeroPage(this.title, this.emoji, this.colors);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Hero(
          tag: 'hero-$title',
          child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 120, decoration: TextDecoration.none)),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.black38),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          left: 24,
          bottom: 48,
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

/* 5. Slider ------------------------------------------------------------ */
class SliderDemo extends StatefulWidget {
  const SliderDemo({super.key});
  @override
  State<SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  double v = 0.55;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final color = HSLColor.fromAHSL(1, v * 280, 0.85, 0.6).toColor();
    return Column(children: [
      Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), boxShadow: glow(color, 12)),
          child: Text('${(v * 100).round()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text('Slider ini digambar dari Container dan digerakkan GestureDetector.', style: TextStyle(color: p.sub, fontSize: 13, height: 1.4))),
      ]),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (_, box) {
        final w = box.maxWidth;
        void set(double dx) => setState(() => v = (dx / w).clamp(0.0, 1.0));
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) => set(d.localPosition.dx),
          onTapDown: (d) => set(d.localPosition.dx),
          child: SizedBox(
            height: 36,
            child: Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
              Container(height: 8, decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(4))),
              Container(width: w * v, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
              Positioned(
                left: w * v - 14,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 4)),
                ),
              ),
            ]),
          ),
        );
      }),
    ]);
  }
}
