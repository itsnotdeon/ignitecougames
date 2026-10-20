import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataToolsScreen extends StatefulWidget {
  const DataToolsScreen({super.key});

  @override
  State<DataToolsScreen> createState() => _DataToolsScreenState();
}

class _DataToolsScreenState extends State<DataToolsScreen> {
  final TextEditingController _importController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<Map<String, Object?>> _snapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final values = <String, Object?>{};
    for (final key in prefs.getKeys()) {
      values[key] = prefs.get(key);
    }
    return <String, Object?>{
      'format': 'ignite-flutter-backup',
      'version': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'preferences': values,
    };
  }

  Future<void> _copyBackup() async {
    setState(() => _busy = true);
    try {
      final json = const JsonEncoder.withIndent('  ').convert(await _snapshot());
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup JSON disalin ke clipboard. Simpan di tempat aman.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat backup: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _busy = true);
    try {
      final decoded = jsonDecode(_importController.text);
      if (decoded is! Map<String, dynamic> || decoded['format'] != 'ignite-flutter-backup' || decoded['preferences'] is! Map<String, dynamic>) {
        throw const FormatException('Format backup IGNITE tidak dikenali.');
      }
      final preferences = decoded['preferences'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      for (final entry in preferences.entries) {
        final value = entry.value;
        if (value is String) await prefs.setString(entry.key, value);
        else if (value is bool) await prefs.setBool(entry.key, value);
        else if (value is int) await prefs.setInt(entry.key, value);
        else if (value is double) await prefs.setDouble(entry.key, value);
        else if (value is List && value.every((item) => item is String)) await prefs.setStringList(entry.key, value.cast<String>());
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup berhasil dipulihkan. Tutup dan buka kembali layar terkait untuk memuat ulang state.')));
        _importController.clear();
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup tidak valid atau gagal dipulihkan: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetData() async {
    final approved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Reset seluruh data lokal?'),
      content: const Text('Tindakan ini menghapus profil, progres, kenangan, preferensi, dan topik custom yang tersimpan pada perangkat ini. Ekspor backup terlebih dahulu jika masih dibutuhkan.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus semua'))],
    ));
    if (approved != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data lokal dihapus. Restart aplikasi untuk memulai dari awal.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Data & Backup')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Backup ini mencakup key SharedPreferences yang digunakan oleh versi Flutter saat ini. Ini bukan konverter otomatis untuk file save game JSON dari versi HTML lama; format HTML perlu dimigrasikan terpisah agar struktur datanya tidak salah dibaca.', style: TextStyle(height: 1.5)),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: _busy ? null : _copyBackup, icon: const Icon(Icons.copy), label: const Text('Salin backup JSON')),
      const SizedBox(height: 22),
      TextField(controller: _importController, onChanged: (_) => setState(() {}), maxLines: 10, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'JSON backup IGNITE', hintText: 'Tempel JSON backup Flutter di sini')),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: _busy || _importController.text.trim().isEmpty ? null : _restoreBackup, icon: const Icon(Icons.restore), label: const Text('Pulihkan backup JSON')),
      const SizedBox(height: 26),
      OutlinedButton.icon(onPressed: _busy ? null : _resetData, icon: const Icon(Icons.delete_forever_outlined), label: const Text('Reset semua data lokal')),
    ]),
  );
}