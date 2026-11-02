import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui.dart';

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

int strength(String pw) {
  var s = 0;
  if (pw.length >= 8) s++;
  if (RegExp(r'[A-Z]').hasMatch(pw) && RegExp(r'[a-z]').hasMatch(pw)) s++;
  if (RegExp(r'\d').hasMatch(pw)) s++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) s++;
  return s;
}

class FormTab extends StatelessWidget {
  const FormTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Section(
        title: 'Form pendaftaran',
        hint: 'Form + TextFormField: validator, TextInputAction.next, autofillHints, keyboard per jenis input, getar saat salah',
        child: SignupForm(),
      ),
      Section(title: 'Dialog & sheet adaptif', hint: 'showAdaptiveDialog, CupertinoActionSheet, date picker Material vs Cupertino', child: AdaptiveDemo()),
    ]);
  }
}

/* Form ----------------------------------------------------------------- */
class SignupForm extends StatefulWidget {
  const SignupForm({super.key});
  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController(), phone = TextEditingController(), pw = TextEditingController();
  DateTime dob = DateTime(2000, 1, 1);
  bool terms = false, showTermsErr = false, done = false, submitted = false, hide = true;
  late final AnimationController shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

  @override
  void initState() {
    super.initState();
    pw.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [name, email, phone, pw]) {
      c.dispose();
    }
    shake.dispose();
    super.dispose();
  }

  void submit() {
    FocusScope.of(context).unfocus();
    setState(() {
      submitted = true;
      showTermsErr = !terms;
    });
    final ok = formKey.currentState!.validate() && terms;
    if (ok) {
      setState(() => done = true);
    } else {
      shake.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  InputDecoration deco(Pal p, String hint, String icon, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.sub),
        filled: true,
        fillColor: p.card2,
        prefixIcon: Padding(padding: const EdgeInsets.only(left: 14, right: 8), child: Center(widthFactor: 1, child: Text(icon))),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kA, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2)),
        errorStyle: const TextStyle(color: Color(0xFFFF4D6D), fontWeight: FontWeight.w600),
      );

  Widget label(Pal p, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: TextStyle(color: p.sub, fontSize: 12, fontWeight: FontWeight.w800)),
      );

  Future<void> pickDate() async {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIos) {
      var temp = dob;
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) => Container(
          height: 280,
          color: CupertinoColors.systemBackground.resolveFrom(ctx),
          child: Column(children: [
            Align(alignment: Alignment.centerRight, child: CupertinoButton(child: const Text('Selesai'), onPressed: () => Navigator.pop(ctx))),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: dob,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (d) {
                  temp = d;
                  setState(() => dob = temp);
                },
              ),
            ),
          ]),
        ),
      );
    } else {
      final d = await showDatePicker(context: context, initialDate: dob, firstDate: DateTime(1920), lastDate: DateTime.now());
      if (d != null) setState(() => dob = d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    if (done) {
      return Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.elasticOut,
          builder: (_, v, child) => Transform.scale(scale: v.clamp(0.0, 1.2), child: child),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [
              const Text('🎉', style: TextStyle(fontSize: 54)),
              const SizedBox(height: 8),
              Text('Selamat datang, ${name.text.trim().split(' ').first}!', style: TextStyle(color: p.ink, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(email.text, style: TextStyle(color: p.sub)),
              const SizedBox(height: 16),
              GradBtn(
                label: 'Ulangi',
                onTap: () => setState(() {
                  done = false;
                  submitted = false;
                  terms = false;
                  for (final c in [name, email, phone, pw]) {
                    c.clear();
                  }
                }),
              ),
            ]),
          ),
        ),
      );
    }

    final s = strength(pw.text);
    const labels = ['Terlalu pendek', 'Lemah', 'Cukup', 'Kuat', 'Sangat kuat'];
    final cols = [const Color(0xFFFF4D6D), const Color(0xFFFF4D6D), kD, kE, kE];
    final mode = submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled;

    return AnimatedBuilder(
      animation: shake,
      builder: (_, child) => Transform.translate(offset: Offset(math.sin(shake.value * math.pi * 6) * 8 * (1 - shake.value), 0), child: child),
      child: Form(
        key: formKey,
        autovalidateMode: mode,
        child: AutofillGroup(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            label(p, 'NAMA LENGKAP'),
            TextFormField(
              controller: name,
              style: TextStyle(color: p.ink),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              textCapitalization: TextCapitalization.words,
              decoration: deco(p, 'Ibra Real', '👤'),
              validator: (v) => (v ?? '').trim().length < 3 ? 'Nama minimal 3 huruf' : null,
            ),
            const SizedBox(height: 14),
            label(p, 'EMAIL'),
            TextFormField(
              controller: email,
              style: TextStyle(color: p.ink),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: deco(p, 'nama@email.com', '✉️'),
              validator: (v) => _email.hasMatch(v ?? '') ? null : 'Format email belum benar',
            ),
            const SizedBox(height: 14),
            label(p, 'NOMOR HP'),
            TextFormField(
              controller: phone,
              style: TextStyle(color: p.ink),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))],
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: deco(p, '0812 3456 7890', '📱'),
              validator: (v) => RegExp(r'^(\+62|0)8\d{8,11}$').hasMatch((v ?? '').replaceAll(RegExp(r'[\s-]'), '')) ? null : 'Nomor HP Indonesia, mis. 0812 3456 7890',
            ),
            const SizedBox(height: 14),
            label(p, 'KATA SANDI'),
            TextFormField(
              controller: pw,
              style: TextStyle(color: p.ink),
              obscureText: hide,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => submit(),
              decoration: deco(p, 'Minimal 8 karakter', '🔒',
                  suffix: IconButton(
                      icon: Icon(hide ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: p.sub, size: 20),
                      onPressed: () => setState(() => hide = !hide))),
              validator: (v) => strength(v ?? '') < 2 ? 'Kata sandi terlalu lemah' : null,
            ),
            if (pw.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 5,
                      margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                      decoration: BoxDecoration(color: i < s ? cols[s] : p.line, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(labels[s], style: TextStyle(color: cols[s], fontSize: 11.5, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 14),
            label(p, 'TANGGAL LAHIR'),
            GestureDetector(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(16)),
                child: Text('📅  ${dob.day}/${dob.month}/${dob.year}', style: TextStyle(color: p.ink, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Text('Saya setuju dengan syarat & ketentuan', style: TextStyle(color: p.ink, fontSize: 14))),
              Switch.adaptive(
                value: terms,
                activeTrackColor: kA,
                onChanged: (v) => setState(() {
                  terms = v;
                  if (v) showTermsErr = false;
                }),
              ),
            ]),
            if (showTermsErr)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('Setujui syarat dan ketentuan', style: TextStyle(color: Color(0xFFFF4D6D), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: Center(child: GradBtn(label: 'Daftar', small: false, onTap: submit))),
          ]),
        ),
      ),
    );
  }
}

/* Dialog adaptif ------------------------------------------------------- */
class AdaptiveDemo extends StatefulWidget {
  const AdaptiveDemo({super.key});
  @override
  State<AdaptiveDemo> createState() => _AdaptiveDemoState();
}

class _AdaptiveDemoState extends State<AdaptiveDemo> {
  String log = 'Belum ada aksi';
  bool forceIos = false;

  TargetPlatform get platform => forceIos ? TargetPlatform.iOS : TargetPlatform.android;

  Future<void> confirm() async {
    final r = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => Theme(
        // Memaksa platform agar bentuk iOS vs Android bisa dibandingkan dari satu perangkat.
        data: Theme.of(ctx).copyWith(platform: platform),
        child: AlertDialog.adaptive(
          title: const Text('Hapus 3 foto?'),
          content: const Text('Tindakan ini tidak bisa dibatalkan.'),
          actions: [
            adaptiveAction(ctx, 'Batal', false),
            adaptiveAction(ctx, 'Hapus', true, destructive: true),
          ],
        ),
      ),
    );
    setState(() => log = r == true ? 'Dihapus' : 'Dibatalkan');
  }

  Widget adaptiveAction(BuildContext ctx, String t, bool v, {bool destructive = false}) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoDialogAction(isDestructiveAction: destructive, onPressed: () => Navigator.pop(ctx, v), child: Text(t));
    }
    return TextButton(onPressed: () => Navigator.pop(ctx, v), child: Text(t, style: destructive ? const TextStyle(color: Color(0xFFFF4D6D)) : null));
  }

  Future<void> sheet() async {
    final opts = ['Ambil foto', 'Pilih dari galeri', 'Hapus foto'];
    final r = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Foto profil'),
        actions: [
          for (var i = 0; i < opts.length; i++)
            CupertinoActionSheetAction(isDestructiveAction: i == 2, onPressed: () => Navigator.pop(ctx, opts[i]), child: Text(opts[i])),
        ],
        cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
      ),
    );
    if (r != null) setState(() => log = 'Action sheet: $r');
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, runSpacing: 6, children: [
        Pill(label: 'Gaya Android', on: !forceIos, onTap: () => setState(() => forceIos = false)),
        Pill(label: 'Gaya iOS', color: kC, on: forceIos, onTap: () => setState(() => forceIos = true)),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: [
        GradBtn(label: 'Dialog konfirmasi', onTap: confirm),
        GradBtn(label: 'Action sheet', colors: const [kB, kA], onTap: sheet),
      ]),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('HASIL', style: TextStyle(color: p.sub, fontSize: 12, fontWeight: FontWeight.w800)),
          Text(log, style: TextStyle(color: p.ink, fontWeight: FontWeight.w700)),
        ]),
      ),
      const SizedBox(height: 12),
      Text(
        'Flutter tidak memakai komponen asli sistem: ia menggambar sendiri versi Material dan versi Cupertino. '
        'Karena itu tombol "Gaya iOS" bisa memperlihatkan dialog ala iOS bahkan di Android atau browser — '
        'tetapi bentuknya hasil tiruan, bukan UIAlertController yang sebenarnya.',
        style: TextStyle(color: p.sub, fontSize: 12.5, height: 1.5),
      ),
    ]);
  }
}
