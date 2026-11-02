import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ui.dart';

class ChartTab extends StatefulWidget {
  const ChartTab({super.key});
  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  String range = 'Minggu';
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Section(title: 'Ringkasan', hint: 'Kartu statistik dengan GridView', child: StatsGrid()),
      Section(
        title: 'Grafik batang',
        hint: 'CustomPainter · ketuk batang, ganti rentang untuk animasi data baru',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (final k in const ['Minggu', 'Bulan'])
              Padding(padding: const EdgeInsets.only(right: 8), child: Pill(label: k, on: range == k, onTap: () => setState(() => range = k))),
          ]),
          const SizedBox(height: 14),
          BarChart(range: range),
        ]),
      ),
      const Section(title: 'Grafik garis', hint: 'Kurva Bezier + area gradient, digambar bertahap dengan PathMetric', child: LineChart()),
      const Section(title: 'Donut', hint: 'drawArc dengan sweep animasi', child: DonutChart()),
      const Section(title: 'Progres aktivitas', hint: 'TweenAnimationBuilder + FractionallySizedBox', child: ProgressRows()),
    ]);
  }
}

/* Stats ---------------------------------------------------------------- */
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    const items = [
      ('Pengguna', '12,4K', '+8%', kA),
      ('Pendapatan', r'$3,2K', '+14%', kE),
      ('Sesi', '48,9K', '-2%', kC),
      ('Rating', '4.8', '+0.2', kD),
    ];
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final it in items)
          Container(
            decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(18), border: Border(left: BorderSide(color: it.$4, width: 4))),
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(it.$1, style: TextStyle(color: p.sub, fontSize: 12, fontWeight: FontWeight.w700)),
              Text(it.$2, style: TextStyle(color: p.ink, fontSize: 24, fontWeight: FontWeight.w800)),
              Text('${it.$3.startsWith('-') ? '▼' : '▲'} ${it.$3}', style: TextStyle(color: it.$3.startsWith('-') ? kC : kE, fontSize: 12, fontWeight: FontWeight.w800)),
            ]),
          ),
      ],
    );
  }
}

/* Bar ------------------------------------------------------------------ */
const _data = {
  'Minggu': ([42.0, 68.0, 55.0, 90.0, 76.0, 110.0, 84.0], ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']),
  'Bulan': ([180.0, 240.0, 210.0, 320.0, 290.0, 410.0, 360.0], ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7']),
};

class BarChart extends StatefulWidget {
  final String range;
  const BarChart({super.key, required this.range});
  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  int sel = 5;
  @override
  void didUpdateWidget(BarChart o) {
    super.didUpdateWidget(o);
    if (o.range != widget.range) c.forward(from: 0);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final (vals, labels) = _data[widget.range]!;
    return LayoutBuilder(builder: (_, box) {
      final n = vals.length;
      return GestureDetector(
        onTapDown: (d) => setState(() => sel = (d.localPosition.dx / (box.maxWidth / n)).floor().clamp(0, n - 1)),
        child: AnimatedBuilder(
          animation: c,
          builder: (_, _) => CustomPaint(
            size: Size(box.maxWidth, 190),
            painter: _BarPainter(vals, labels, sel, c.value, p),
          ),
        ),
      );
    });
  }
}

class _BarPainter extends CustomPainter {
  final List<double> v;
  final List<String> labels;
  final int sel;
  final double t;
  final Pal p;
  _BarPainter(this.v, this.labels, this.sel, this.t, this.p);
  @override
  void paint(Canvas canvas, Size size) {
    final n = v.length;
    final slot = size.width / n;
    final maxV = v.reduce(math.max);
    const chartH = 140.0, top = 22.0;
    for (var i = 0; i < n; i++) {
      final k = Interval(i * 0.07, i * 0.07 + 0.55, curve: Curves.elasticOut).transform(t);
      final h = math.max(0.0, v[i] / maxV * chartH * k);
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(i * slot + 5, top + chartH - h, slot - 10, h), const Radius.circular(10));
      final on = i == sel;
      canvas.drawRRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: on ? [kC, kA] : [kA.withValues(alpha: 0.55), kA.withValues(alpha: 0.55)],
          ).createShader(r.outerRect),
      );
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(color: on ? p.ink : p.sub, fontSize: 11.5, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(i * slot + (slot - tp.width) / 2, top + chartH + 10));
      if (on && t > 0.6) {
        final vt = TextPainter(
          text: TextSpan(text: v[i].round().toString(), style: TextStyle(color: p.ink, fontSize: 12, fontWeight: FontWeight.w800)),
          textDirection: TextDirection.ltr,
        )..layout();
        vt.paint(canvas, Offset(i * slot + (slot - vt.width) / 2, top + chartH - h - 18));
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter o) => o.t != t || o.sel != sel || o.v != v || o.p != p;
}

/* Line ----------------------------------------------------------------- */
class LineChart extends StatefulWidget {
  const LineChart({super.key});
  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedBuilder(
        animation: c,
        builder: (_, _) => CustomPaint(
          size: const Size(double.infinity, 150),
          painter: _LinePainter(Curves.easeInOutCubic.transform(c.value), p),
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => c.forward(from: 0),
        child: const Text('↻ Gambar ulang', style: TextStyle(color: kB, fontWeight: FontWeight.w800, fontSize: 13)),
      ),
    ]);
  }
}

class _LinePainter extends CustomPainter {
  final double t;
  final Pal p;
  _LinePainter(this.t, this.p);
  static const data = [0.3, 0.55, 0.42, 0.7, 0.62, 0.9, 0.78, 0.95];
  @override
  void paint(Canvas canvas, Size size) {
    for (final g in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(0, size.height * g), Offset(size.width, size.height * g), Paint()..color = p.line);
    }
    final pts = [
      for (var i = 0; i < data.length; i++) Offset(8 + i / (data.length - 1) * (size.width - 16), size.height - 12 - data[i] * (size.height - 28)),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i], b = pts[i + 1];
      final mx = (a.dx + b.dx) / 2;
      path.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
    }
    final metric = path.computeMetrics().first;
    final shown = metric.extractPath(0, metric.length * t);
    final tangent = metric.getTangentForOffset(metric.length * t);

    // area
    final area = Path.from(shown);
    if (tangent != null) {
      area.lineTo(tangent.position.dx, size.height);
      area.lineTo(pts.first.dx, size.height);
      area.close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kB.withValues(alpha: 0.35), kB.withValues(alpha: 0)])
              .createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(shown, Paint()..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..color = kB);
    if (tangent != null) {
      canvas.drawCircle(tangent.position, 11, Paint()..color = kB.withValues(alpha: 0.25));
      canvas.drawCircle(tangent.position, 6, Paint()..color = p.card);
      canvas.drawCircle(tangent.position, 6, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = kB);
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) => o.t != t || o.p != p;
}

/* Donut ---------------------------------------------------------------- */
class DonutChart extends StatelessWidget {
  const DonutChart({super.key});
  static const parts = [('Kerja', 0.40, kA), ('Belajar', 0.25, kB), ('Olahraga', 0.20, kE), ('Santai', 0.15, kC)];
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: _DonutPainter(v, p),
            child: Center(child: Text('${(v * 100).round()}%', style: TextStyle(color: p.ink, fontSize: 24, fontWeight: FontWeight.w800))),
          ),
        ),
      ),
      const SizedBox(width: 22),
      Expanded(
        child: Column(children: [
          for (final e in parts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: e.$3, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 10),
                Expanded(child: Text(e.$1, style: TextStyle(color: p.ink, fontWeight: FontWeight.w700))),
                Text('${(e.$2 * 100).round()}%', style: TextStyle(color: p.sub, fontWeight: FontWeight.w700)),
              ]),
            ),
        ]),
      ),
    ]);
  }
}

class _DonutPainter extends CustomPainter {
  final double t;
  final Pal p;
  _DonutPainter(this.t, this.p);
  @override
  void paint(Canvas canvas, Size size) {
    const w = 20.0;
    final rect = Rect.fromLTWH(w / 2, w / 2, size.width - w, size.height - w);
    canvas.drawArc(rect, 0, math.pi * 2, false, Paint()..style = PaintingStyle.stroke..strokeWidth = w..color = p.card2);
    var start = -math.pi / 2;
    for (final e in DonutChart.parts) {
      final sweep = e.$2 * math.pi * 2 * t;
      canvas.drawArc(rect, start + 0.04, math.max(0, sweep - 0.08), false,
          Paint()..style = PaintingStyle.stroke..strokeWidth = w..strokeCap = StrokeCap.round..color = e.$3);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) => o.t != t || o.p != p;
}

/* Progress ------------------------------------------------------------- */
class ProgressRows extends StatelessWidget {
  const ProgressRows({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    const rows = [('💼', 'Kerja', 0.82, kA), ('🏃', 'Olahraga', 0.55, kE), ('📚', 'Belajar', 0.68, kB), ('😴', 'Tidur', 0.9, kC)];
    return Column(children: [
      for (var i = 0; i < rows.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${rows[i].$1} ${rows[i].$2}', style: TextStyle(color: p.ink, fontWeight: FontWeight.w700)),
              Text('${(rows[i].$3 * 100).round()}%', style: TextStyle(color: p.sub, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            Container(
              height: 10,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(5)),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: rows[i].$3),
                duration: Duration(milliseconds: 900 + i * 150),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => FractionallySizedBox(
                  widthFactor: v,
                  child: Container(decoration: BoxDecoration(color: rows[i].$4, borderRadius: BorderRadius.circular(5))),
                ),
              ),
            ),
          ]),
        ),
    ]);
  }
}
