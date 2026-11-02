import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui.dart';

class ComponentsTab extends StatelessWidget {
  const ComponentsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Section(title: 'Switch Material & Cupertino', hint: 'Satu codebase, dua gaya platform', child: SwitchDemo()),
      Section(title: 'SegmentedButton', hint: 'Widget Material 3 bawaan', child: SegDemo()),
      Section(title: 'Input teks', hint: 'FocusNode + AnimatedContainer, show/hide, counter', child: InputDemo()),
      Section(title: 'Carousel', hint: 'PageView + viewportFraction, skala dari posisi halaman', child: CarouselDemo()),
      Section(title: 'Daftar dengan sticky header', hint: 'CustomScrollView + SliverPersistentHeader(pinned)', child: ListDemo()),
      Section(title: 'Rating', hint: 'AnimatedScale per bintang', child: RatingDemo()),
      Section(title: 'Dialog, Sheet, Snackbar', hint: 'showDialog, showModalBottomSheet, SnackBar', child: MiscDemo()),
    ]);
  }
}

/* 1. Switch ------------------------------------------------------------ */
class SwitchDemo extends StatefulWidget {
  const SwitchDemo({super.key});
  @override
  State<SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<SwitchDemo> {
  bool a = true, b = false, c = true;
  double s = 0.4;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    Widget row(String e, String l, Widget w) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 34, child: Text(e, style: const TextStyle(fontSize: 20))),
            Expanded(child: Text(l, style: TextStyle(color: p.ink, fontWeight: FontWeight.w600, fontSize: 15))),
            w,
          ]),
        );
    return Column(children: [
      row('🔔', 'Material Switch', Switch(value: a, onChanged: (v) => setState(() => a = v), activeThumbColor: Colors.white, activeTrackColor: kA)),
      row('🍎', 'CupertinoSwitch', CupertinoSwitch(value: b, activeTrackColor: kC, onChanged: (v) => setState(() => b = v))),
      row('☁️', 'Checkbox', Checkbox(value: c, activeColor: kE, onChanged: (v) => setState(() => c = v!))),
      row('🎚️', 'CupertinoSlider', SizedBox(width: 130, child: CupertinoSlider(value: s, activeColor: kB, onChanged: (v) => setState(() => s = v)))),
    ]);
  }
}

/* 2. SegmentedButton --------------------------------------------------- */
class SegDemo extends StatefulWidget {
  const SegDemo({super.key});
  @override
  State<SegDemo> createState() => _SegDemoState();
}

class _SegDemoState extends State<SegDemo> {
  String sel = 'Harian';
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(selectedBackgroundColor: kA, selectedForegroundColor: Colors.white),
        segments: const [
          ButtonSegment(value: 'Harian', label: Text('Harian')),
          ButtonSegment(value: 'Mingguan', label: Text('Mingguan')),
          ButtonSegment(value: 'Bulanan', label: Text('Bulanan')),
        ],
        selected: {sel},
        onSelectionChanged: (s) => setState(() => sel = s.first),
      ),
    );
  }
}

/* 3. Input ------------------------------------------------------------- */
class InputDemo extends StatefulWidget {
  const InputDemo({super.key});
  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  final f1 = FocusNode();
  final name = TextEditingController();
  bool focus = false, show = false;
  @override
  void initState() {
    super.initState();
    f1.addListener(() => setState(() => focus = f1.hasFocus));
    name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    f1.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    InputDecoration deco(String hint, {Widget? suffix, String? prefix}) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: p.sub),
          border: InputBorder.none,
          prefixIcon: prefix == null ? null : Padding(padding: const EdgeInsets.only(left: 14, right: 8), child: Center(widthFactor: 1, child: Text(prefix))),
          suffixIcon: suffix,
          counterStyle: TextStyle(color: p.sub),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        );
    Widget box(Widget child, {bool on = false}) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: p.card2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? kA : Colors.transparent, width: 2),
            boxShadow: on ? [BoxShadow(color: kA.withValues(alpha: 0.25), blurRadius: 14)] : [],
          ),
          child: child,
        );
    return Column(children: [
      box(
        TextField(
          controller: name,
          focusNode: f1,
          style: TextStyle(color: p.ink),
          cursorColor: kA,
          decoration: deco('Nama lengkap',
              prefix: '👤',
              suffix: name.text.isEmpty ? null : IconButton(icon: Icon(Icons.close_rounded, color: p.sub, size: 18), onPressed: name.clear)),
        ),
        on: focus,
      ),
      const SizedBox(height: 12),
      box(TextField(
        obscureText: !show,
        style: TextStyle(color: p.ink),
        decoration: deco('Kata sandi',
            prefix: '🔒',
            suffix: IconButton(
                icon: Icon(show ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: p.sub, size: 20),
                onPressed: () => setState(() => show = !show))),
      )),
      const SizedBox(height: 12),
      box(TextField(
        maxLines: 3,
        maxLength: 80,
        style: TextStyle(color: p.ink),
        decoration: deco('Bio singkat…'),
      )),
    ]);
  }
}

/* 4. Carousel ---------------------------------------------------------- */
class CarouselDemo extends StatefulWidget {
  const CarouselDemo({super.key});
  @override
  State<CarouselDemo> createState() => _CarouselDemoState();
}

class _CarouselDemoState extends State<CarouselDemo> {
  static const cards = [
    ('Senja Pantai', 'Bali', '🌅', [Color(0xFFFF9A8B), Color(0xFFFF6A88)]),
    ('Hutan Pagi', 'Bogor', '🌲', [Color(0xFF43E97B), Color(0xFF38F9D7)]),
    ('Kota Malam', 'Jakarta', '🌃', [Color(0xFF667EEA), Color(0xFF764BA2)]),
    ('Gunung Salju', 'Papua', '🏔️', [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
  ];
  final pc = PageController(viewportFraction: 0.82);
  @override
  void dispose() {
    pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 160,
        child: PageView.builder(
          controller: pc,
          itemCount: cards.length,
          itemBuilder: (_, i) => AnimatedBuilder(
            animation: pc,
            builder: (_, child) {
              final page = pc.hasClients && pc.position.haveDimensions ? pc.page! : 0.0;
              final d = (page - i).abs().clamp(0.0, 1.0);
              return Center(
                child: Transform.scale(scale: 1 - 0.1 * d, child: Opacity(opacity: 1 - 0.4 * d, child: child)),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: cards[i].$4, begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(cards[i].$3, style: const TextStyle(fontSize: 40)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(cards[i].$1, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(cards[i].$2, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      AnimatedBuilder(
        animation: pc,
        builder: (_, _) {
          final page = pc.hasClients && pc.position.haveDimensions ? pc.page! : 0.0;
          return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < cards.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8 + 16 * (1 - (page - i).abs().clamp(0.0, 1.0)),
                height: 8,
                decoration: BoxDecoration(
                  color: kA.withValues(alpha: 0.35 + 0.65 * (1 - (page - i).abs().clamp(0.0, 1.0))),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ]);
        },
      ),
    ]);
  }
}

/* 5. Sticky list ------------------------------------------------------- */
class _Header extends SliverPersistentHeaderDelegate {
  final String t;
  final Color bg;
  _Header(this.t, this.bg);
  @override
  double get minExtent => 28;
  @override
  double get maxExtent => 28;
  @override
  Widget build(BuildContext c, double s, bool o) => Container(
        color: bg,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(t, style: const TextStyle(color: kA, fontWeight: FontWeight.w800, fontSize: 12)),
      );
  @override
  bool shouldRebuild(_Header o) => o.t != t || o.bg != bg;
}

class ListDemo extends StatelessWidget {
  const ListDemo({super.key});
  static const data = {
    'A': ['Adi Pratama', 'Ayu Lestari', 'Andi Wijaya'],
    'B': ['Bagas Saputra', 'Bunga Citra'],
    'D': ['Dewi Anggraini', 'Dimas Aryo', 'Dina Mariana'],
    'R': ['Rangga Putra', 'Rani Oktavia'],
  };
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    const cols = [kA, kB, kC, kD, kE];
    return Container(
      height: 230,
      decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(slivers: [
        for (final e in data.entries)
          SliverMainAxisGroup(slivers: [
            SliverPersistentHeader(pinned: true, delegate: _Header(e.key, p.card2)),
            SliverList.builder(
              itemCount: e.value.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: Row(children: [
                  CircleAvatar(radius: 17, backgroundColor: cols[(e.value[i].length + i) % 5], child: Text(e.value[i][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                  const SizedBox(width: 12),
                  Text(e.value[i], style: TextStyle(color: p.ink, fontWeight: FontWeight.w600, fontSize: 14.5)),
                ]),
              ),
            ),
          ]),
      ]),
    );
  }
}

/* 6. Rating ------------------------------------------------------------ */
class RatingDemo extends StatefulWidget {
  const RatingDemo({super.key});
  @override
  State<RatingDemo> createState() => _RatingDemoState();
}

class _RatingDemoState extends State<RatingDemo> {
  int r = 3, bump = -1;
  static const labels = ['', 'Buruk', 'Kurang', 'Cukup', 'Bagus', 'Luar biasa!'];
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Center(
      child: Column(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (var n = 1; n <= 5; n++)
            GestureDetector(
              onTap: () {
                setState(() {
                  r = n;
                  bump = n;
                });
                Future.delayed(const Duration(milliseconds: 160), () {
                  if (mounted) setState(() => bump = -1);
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: AnimatedScale(
                  scale: bump == n ? 1.5 : 1,
                  duration: const Duration(milliseconds: 450),
                  curve: bump == n ? Curves.easeOut : Curves.elasticOut,
                  child: AnimatedOpacity(
                    opacity: n <= r ? 1 : 0.28,
                    duration: const Duration(milliseconds: 200),
                    child: const Text('⭐', style: TextStyle(fontSize: 34)),
                  ),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(labels[r], key: ValueKey(r), style: TextStyle(color: p.ink, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

/* 7. Misc -------------------------------------------------------------- */
class MiscDemo extends StatelessWidget {
  const MiscDemo({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: kA)),
        SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 4, color: kB)),
        CupertinoActivityIndicator(radius: 14),
        SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 4, color: kC, value: 0.65)),
      ]),
      const SizedBox(height: 14),
      ClipRRect(borderRadius: BorderRadius.circular(6), child: const LinearProgressIndicator(minHeight: 8, color: kE)),
      const SizedBox(height: 16),
      Wrap(spacing: 10, runSpacing: 10, children: [
        GradBtn(
          label: 'Dialog',
          onTap: () => showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'tutup',
            barrierColor: Colors.black54,
            transitionDuration: const Duration(milliseconds: 450),
            transitionBuilder: (_, a, _, child) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut, reverseCurve: Curves.easeIn), child: FadeTransition(opacity: a, child: child)),
            pageBuilder: (ctx, _, _) => Center(
              child: Material(
                color: p.card,
                borderRadius: BorderRadius.circular(28),
                elevation: 12,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🚀', style: TextStyle(fontSize: 54)),
                    const SizedBox(height: 8),
                    Text('Ini Dialog', style: TextStyle(color: p.ink, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    SizedBox(width: 240, child: Text('Transisi masuk elastis dibuat dengan showGeneralDialog.', textAlign: TextAlign.center, style: TextStyle(color: p.sub, height: 1.4))),
                    const SizedBox(height: 16),
                    GradBtn(label: 'Tutup', small: false, onTap: () => Navigator.pop(ctx)),
                  ]),
                ),
              ),
            ),
          ),
        ),
        GradBtn(
          label: 'Bottom Sheet',
          colors: const [kB, kA],
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: p.card,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 44, height: 5, decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 18),
                for (final e in const [('📷', 'Ambil foto'), ('🖼️', 'Pilih dari galeri'), ('🗑️', 'Hapus foto')])
                  ListTile(leading: Text(e.$1, style: const TextStyle(fontSize: 24)), title: Text(e.$2, style: TextStyle(color: p.ink, fontWeight: FontWeight.w700)), onTap: () => Navigator.pop(context)),
              ]),
            ),
          ),
        ),
        GradBtn(
          label: 'Snackbar',
          colors: const [kE, kB],
          onTap: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: p.ink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Text('✅ Berhasil disimpan', style: TextStyle(color: p.bg, fontWeight: FontWeight.w700)),
              ));
          },
        ),
        GradBtn(label: 'Getar', colors: const [kD, kC], onTap: () => HapticFeedback.heavyImpact()),
      ]),
    ]);
  }
}
