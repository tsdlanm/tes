import 'package:flutter/material.dart';

const kA = Color(0xFF7C5CFF);
const kB = Color(0xFF22D3EE);
const kC = Color(0xFFFF6B9A);
const kD = Color(0xFFFBBF24);
const kE = Color(0xFF34D399);

class Pal {
  final Color bg, card, card2, ink, sub, line;
  const Pal(this.bg, this.card, this.card2, this.ink, this.sub, this.line);

  static const dark = Pal(Color(0xFF0B0F1E), Color(0xFF151B31), Color(0xFF1D2542),
      Color(0xFFF2F4FF), Color(0xFF8D95B8), Color(0xFF262F52));
  static const light = Pal(Color(0xFFF3F4FB), Color(0xFFFFFFFF), Color(0xFFECEEFA),
      Color(0xFF161A33), Color(0xFF6B7194), Color(0xFFE2E5F5));

  static Pal of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

List<BoxShadow> glow(Color c, [double r = 16]) => [
      BoxShadow(color: c.withValues(alpha: 0.42), blurRadius: r * 1.5, offset: const Offset(0, 8)),
    ];

class Section extends StatelessWidget {
  final String title;
  final String? hint;
  final Widget child;
  const Section({super.key, required this.title, this.hint, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: p.ink, fontSize: 17, fontWeight: FontWeight.w800)),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(hint!, style: TextStyle(color: p.sub, fontSize: 12.5, height: 1.4)),
            ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  final Color color;
  const Pill({super.key, required this.label, required this.on, required this.onTap, this.color = kA});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? color : p.card2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label,
            style: TextStyle(color: on ? Colors.white : p.sub, fontWeight: FontWeight.w700, fontSize: 12.5)),
      ),
    );
  }
}

class GradBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color> colors;
  final bool small;
  const GradBtn({super.key, required this.label, required this.onTap, this.colors = const [kA, kC], this.small = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: small ? 16 : 24, vertical: small ? 10 : 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: small ? 13 : 15)),
      ),
    );
  }
}

String rupiah(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}
