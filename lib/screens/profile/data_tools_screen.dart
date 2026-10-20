import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data portability for Flutter backups and HTML-era IGNITE topic/save files.
///
/// HTML files are kept as structured JSON rather than flattened into the Flutter
/// preferences map, so category metadata and roleplay objects survive round trips.
class DataToolsScreen extends StatefulWidget {
  const DataToolsScreen({super.key});

  @override
  State<DataToolsScreen> createState() => _DataToolsScreenState();
}

class _DataToolsScreenState extends State<DataToolsScreen> {
  static const String _htmlTopicsKey = 'ignite_html_compatible_topics_snapshot';
  static const String _htmlSaveKey = 'ignite_html_compatible_save_snapshot';
  static const String _kartuTalkKey = 'ignite_html_kartu_talk_custom_topics';

  final TextEditingController _importController = TextEditingController();
  bool _busy = false;
  String _status = 'Backup Flutter mencakup preferensi lokal. File topik/save HTML disimpan terpisah agar struktur aslinya tidak hilang.';

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<Map<String, Object?>> _snapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final values = <String, Object?>{};
    for (final key in prefs.getKeys()) {
      if (key == _htmlTopicsKey || key == _htmlSaveKey) continue;
      values[key] = prefs.get(key);
    }
    return <String, Object?>{
      'format': 'ignite-flutter-backup',
      'version': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'preferences': values,
    };
  }

  Future<void> _copyJson(Map<String, Object?> data, String message) async {
    await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)));
    if (mounted) {
      setState(() => _status = message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _copyFlutterBackup() async {
    setState(() => _busy = true);
    try {
      await _copyJson(await _snapshot(), 'Backup Flutter disalin ke clipboard.');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat backup: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyHtmlTopics() async {
    setState(() => _busy = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_htmlTopicsKey);
      if (raw == null || raw.trim().isEmpty) {
        throw const FormatException('Belum ada file topik HTML yang diimpor. Impor JSON topik dari IGNITE HTML terlebih dahulu.');
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) throw const FormatException('Snapshot topik tersimpan tidak valid.');
      await _copyJson(Map<String, Object?>.from(decoded), 'Snapshot topik kompatibel HTML disalin ke clipboard.');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyHtmlSave() async {
    setState(() => _busy = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_htmlSaveKey);
      if (raw == null || raw.trim().isEmpty) {
        throw const FormatException('Belum ada save game HTML yang diimpor.');
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) throw const FormatException('Snapshot save tersimpan tidak valid.');
      await _copyJson(Map<String, Object?>.from(decoded), 'Snapshot save game HTML disalin ke clipboard.');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreJson() async {
    setState(() => _busy = true);
    try {
      final decoded = jsonDecode(_importController.text);
      if (decoded is! Map<String, dynamic>) throw const FormatException('JSON harus berupa objek.');

      final prefs = await SharedPreferences.getInstance();
      final format = decoded['format'];

      if (format == 'ignite-flutter-backup' && decoded['preferences'] is Map<String, dynamic>) {
        final preferences = decoded['preferences'] as Map<String, dynamic>;
        // Validate all supported preference values before changing local data.
        for (final entry in preferences.entries) {
          final value = entry.value;
          if (value is! String && value is! bool && value is! int && value is! double &&
              !(value is List && value.every((item) => item is String))) {
            throw FormatException('Tipe data tidak didukung pada key "${entry.key}".');
          }
        }
        for (final entry in preferences.entries) {
          final value = entry.value;
          if (value is String) await prefs.setString(entry.key, value);
          else if (value is bool) await prefs.setBool(entry.key, value);
          else if (value is int) await prefs.setInt(entry.key, value);
          else if (value is double) await prefs.setDouble(entry.key, value);
          else if (value is List<String>) await prefs.setStringList(entry.key, value);
        }
        if (mounted) setState(() => _status = 'Backup Flutter berhasil dipulihkan.');
      } else if (format == 'ignite-couple-game-topics-export') {
        _validateHtmlTopics(decoded);
        await prefs.setString(_htmlTopicsKey, jsonEncode(decoded));
        // Seed the current Kartu Talk custom list from ordinary HTML card topics.
        final categories = decoded['categories'] as List<dynamic>;
        final prompts = <String>[];
        for (final category in categories) {
          if (category is Map && category['topics'] is List) {
            prompts.addAll((category['topics'] as List).whereType<String>());
          }
        }
        if (prompts.isNotEmpty) {
          await prefs.setStringList(_kartuTalkKey, prompts.toSet().toList());
        }
        if (mounted) setState(() => _status = 'Topik HTML berhasil diimpor dan struktur kategorinya disimpan. Konten mode eksplisit tidak digabung ke mode biasa.');
      } else if (format == 'ignite-couple-game-save' && decoded['state'] is Map<String, dynamic>) {
        final state = decoded['state'] as Map<String, dynamic>;
        if (state['categories'] is! List) throw const FormatException('Save game tidak memiliki daftar kategori yang valid.');
        await prefs.setString(_htmlSaveKey, jsonEncode(decoded));
        final categories = state['categories'] as List<dynamic>;
        final prompts = <String>[];
        for (final category in categories) {
          if (category is Map && category['topics'] is List) {
            prompts.addAll((category['topics'] as List).whereType<String>());
          }
        }
        if (prompts.isNotEmpty) await prefs.setStringList(_kartuTalkKey, prompts.toSet().toList());
        if (mounted) setState(() => _status = 'Save game HTML tersimpan sebagai snapshot kompatibilitas. Progres sesi HTML belum dipetakan penuh ke semua layar Flutter.');
      } else {
        throw const FormatException('Format tidak dikenali. Gunakan backup Flutter, "ignite-couple-game-topics-export", atau "ignite-couple-game-save".');
      }

      if (mounted) {
        _importController.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_status)));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impor gagal: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _validateHtmlTopics(Map<String, dynamic> data) {
    if (data['version'] != 1 || data['categories'] is! List) {
      throw const FormatException('Versi atau daftar kategori topik HTML tidak valid.');
    }
    for (final key in ['categories', 'explicitCategories', 'totCategories']) {
      final value = data[key];
      if (value == null) continue;
      if (value is! List) throw FormatException('Field "$key" harus berupa daftar.');
      for (final category in value) {
        if (category is! Map || category['topics'] is! List ||
            !(category['topics'] as List).every((topic) => topic is String)) {
          throw FormatException('Struktur kategori "$key" tidak valid.');
        }
      }
    }
    for (final key in ['ksCommands', 'ksCommandsExplicit']) {
      final value = data[key];
      if (value != null && (value is! List || !value.every((topic) => topic is String))) {
        throw FormatException('Field "$key" tidak valid.');
      }
    }
  }

  Future<void> _resetData() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset seluruh data lokal?'),
        content: const Text('Tindakan ini menghapus profil, progres, kenangan, preferensi, topik custom, dan snapshot HTML di perangkat ini. Salin backup terlebih dahulu jika masih dibutuhkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus semua')),
        ],
      ),
    );
    if (approved != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) setState(() => _status = 'Data lokal dihapus. Restart aplikasi untuk memulai dari awal.');
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data lokal dihapus. Restart aplikasi untuk memulai dari awal.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Data & Backup')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(_status, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 18),
        Text('Ekspor', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _busy ? null : _copyFlutterBackup,
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Salin backup Flutter JSON'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : _copyHtmlTopics,
          icon: const Icon(Icons.topic_outlined),
          label: const Text('Salin snapshot topik HTML'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : _copyHtmlSave,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Salin snapshot save HTML'),
        ),
        const SizedBox(height: 22),
        Text('Impor JSON', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Menerima backup Flutter, ekspor topik HTML, atau save game HTML. Data HTML disimpan dalam bentuk snapshot asli; progres sesi belum sepenuhnya diterjemahkan ke semua layar Flutter.', style: TextStyle(height: 1.5)),
        const SizedBox(height: 10),
        TextField(
          controller: _importController,
          onChanged: (_) => setState(() {}),
          maxLines: 10,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Tempel JSON di sini',
            hintText: 'Paste isi file .json dari IGNITE',
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _busy || _importController.text.trim().isEmpty ? null : _restoreJson,
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Validasi & impor JSON'),
        ),
        const SizedBox(height: 26),
        OutlinedButton.icon(
          onPressed: _busy ? null : _resetData,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Reset semua data lokal'),
        ),
      ],
    ),
  );
}
