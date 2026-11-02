import 'package:flutter/material.dart';
import 'anim_tab.dart';
import 'chart_tab.dart';
import 'components_tab.dart';
import 'gesture_tab.dart';
import 'layout_tab.dart';
import 'pro_tab.dart';
import 'stress_tab.dart';
import 'ui.dart';

void main() => runApp(const ShowcaseApp());

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});
  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  bool dark = true;

  ThemeData theme(Pal p, Brightness b) => ThemeData(
        useMaterial3: true,
        brightness: b,
        scaffoldBackgroundColor: p.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: kA, brightness: b),
        splashFactory: InkSparkle.splashFactory,
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI Showcase',
      debugShowCheckedModeBanner: false,
      theme: theme(Pal.light, Brightness.light),
      darkTheme: theme(Pal.dark, Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 400),
      home: Home(dark: dark, onTheme: (v) => setState(() => dark = v)),
    );
  }
}

class Home extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onTheme;
  const Home({super.key, required this.dark, required this.onTheme});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;
  static const tabs = [
    ('✨', 'Animasi'),
    ('👆', 'Gestur'),
    ('🧩', 'Komponen'),
    ('📐', 'Layout'),
    ('📈', 'Grafik'),
    ('⚡', 'Pro'),
    ('🔥', 'Beban'),
  ];
  static const pages = [AnimTab(), GestureTab(), ComponentsTab(), LayoutTab(), ChartTab(), ProTab(), StressTab()];

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('FLUTTER', style: TextStyle(color: p.sub, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                      Text('UI Showcase', style: TextStyle(color: p.ink, fontSize: 28, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  Text(widget.dark ? '🌙' : '☀️', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Switch(value: widget.dark, onChanged: widget.onTheme, activeThumbColor: Colors.white, activeTrackColor: kA),
                ]),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(a), child: child),
                  ),
                  child: SingleChildScrollView(
                    key: ValueKey(index),
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                    child: pages[index],
                  ),
                ),
              ),
              _NavBar(index: index, onTap: (i) => setState(() => index = i), tabs: tabs),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<(String, String)> tabs;
  const _NavBar({required this.index, required this.onTap, required this.tabs});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(26), border: Border.all(color: p.line)),
      child: Stack(children: [
        AnimatedAlign(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          alignment: Alignment(-1 + 2 * index / (tabs.length - 1), 0),
          child: FractionallySizedBox(
            widthFactor: 1 / tabs.length,
            heightFactor: 1,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  gradient: const LinearGradient(colors: [kA, kC], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),
            ),
          ),
        ),
        Row(children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(tabs[i].$1, style: const TextStyle(fontSize: 17)),
                  const SizedBox(height: 2),
                  Text(tabs[i].$2, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: i == index ? Colors.white : p.sub)),
                ]),
              ),
            ),
        ]),
      ]),
    );
  }
}
