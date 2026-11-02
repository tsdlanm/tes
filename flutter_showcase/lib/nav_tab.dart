import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ui.dart';

class _Place {
  final String id, name, city, emoji, desc;
  final List<Color> colors;
  const _Place(this.id, this.name, this.city, this.emoji, this.colors, this.desc);
}

const _places = [
  _Place('bali', 'Senja Pantai', 'Bali', '🌅', [Color(0xFFFF9A8B), Color(0xFFFF6A88)], 'Pantai dengan matahari terbenam terbaik untuk fotografi. Datang satu jam sebelum senja.'),
  _Place('bogor', 'Hutan Pagi', 'Bogor', '🌲', [Color(0xFF43E97B), Color(0xFF38F9D7)], 'Jalur trekking ringan dengan kabut tipis setiap pagi. Cocok untuk keluarga.'),
  _Place('jkt', 'Kota Malam', 'Jakarta', '🌃', [Color(0xFF667EEA), Color(0xFF764BA2)], 'Rooftop dengan pemandangan gedung-gedung yang menyala sepanjang malam.'),
  _Place('papua', 'Gunung Salju', 'Papua', '🏔️', [Color(0xFF4FACFE), Color(0xFF00F2FE)], 'Salah satu dari sedikit puncak bersalju di daerah tropis dunia.'),
];

class NavTab extends StatelessWidget {
  const NavTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Section(
        title: 'Navigasi antar layar',
        hint: 'Navigator 1.0 bersarang: push dengan Hero, route Cupertino (geser dari tepi kiri untuk kembali), modal dari bawah',
        child: _NavDemo(),
      ),
    ]);
  }
}

class _NavDemo extends StatelessWidget {
  const _NavDemo();
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      height: 540,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: p.line)),
      clipBehavior: Clip.antiAlias,
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const _HomePage()),
      ),
    );
  }
}

AppBar _bar(BuildContext c, String title, {bool back = true}) {
  final p = Pal.of(c);
  return AppBar(
    backgroundColor: p.card,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: back,
    title: Text(title, style: TextStyle(color: p.ink, fontWeight: FontWeight.w800)),
    iconTheme: IconThemeData(color: p.ink),
  );
}

class _HomePage extends StatelessWidget {
  const _HomePage();
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: _bar(context, 'Jelajah', back: false),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final pl in _places)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              // CupertinoPageRoute: transisi ala iOS + geser dari tepi kiri untuk kembali.
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => _DetailPage(pl))),
              child: Hero(
                tag: 'place-${pl.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(colors: pl.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Row(children: [
                      Text(pl.emoji, style: const TextStyle(fontSize: 38)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(pl.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          Text(pl.city, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                      const Text('›', style: TextStyle(color: Colors.white, fontSize: 22)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        Center(child: Text('Ketuk kartu untuk membuka halaman detail', style: TextStyle(color: p.sub, fontSize: 12))),
      ]),
    );
  }
}

class _DetailPage extends StatelessWidget {
  final _Place pl;
  const _DetailPage(this.pl);
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: _bar(context, pl.name),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Hero(
          tag: 'place-${pl.id}',
          child: Container(
            height: 180,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: LinearGradient(colors: pl.colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Text(pl.emoji, style: const TextStyle(fontSize: 80, decoration: TextDecoration.none)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pl.name, style: TextStyle(color: p.ink, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(pl.desc, style: TextStyle(color: p.sub, height: 1.5)),
            const SizedBox(height: 18),
            Row(children: [
              GradBtn(
                label: 'Pesan',
                onTap: () => Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  transitionDuration: const Duration(milliseconds: 420),
                  pageBuilder: (_, _, _) => _BookingPage(pl),
                  transitionsBuilder: (_, a, _, child) => SlideTransition(
                    position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic)),
                    child: child,
                  ),
                )),
              ),
              const SizedBox(width: 10),
              GradBtn(
                label: 'Tempat lain',
                colors: const [kB, kA],
                onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => _DetailPage(_places[(_places.indexOf(pl) + 1) % _places.length]))),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _BookingPage extends StatelessWidget {
  final _Place pl;
  const _BookingPage(this.pl);
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      backgroundColor: p.card,
      appBar: _bar(context, 'Pemesanan'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎟️', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 10),
            Text('Pesan ${pl.name}', style: TextStyle(color: p.ink, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Layar ini dibuka sebagai modal: muncul dari bawah dengan PageRouteBuilder.', textAlign: TextAlign.center, style: TextStyle(color: p.sub, height: 1.5)),
            const SizedBox(height: 18),
            GradBtn(label: 'Selesai', small: false, onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
          ]),
        ),
      ),
    );
  }
}
