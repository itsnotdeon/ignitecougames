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

  final TextEditingController _importController = TextEditingController();
  bool _busy = false;
  Map<String, dynamic>? _topicSnapshot;
  String _status = 'Backup Flutter mencakup preferensi lokal. File topik/save HTML disimpan terpisah agar struktur aslinya tidak hilang.';

  @override
  void initState() {
    super.initState();
    _loadSavedTopicSnapshot();
  }

  Future<void> _loadSavedTopicSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_htmlTopicsKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> && mounted) {
        setState(() => _topicSnapshot = decoded);
      }
    } catch (_) {
      // Keep data tools available even if an older snapshot is malformed.
    }
  }

  Future<void> _persistTopicSnapshot() async {
    final snapshot = _topicSnapshot;
    if (snapshot == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_htmlTopicsKey, jsonEncode(snapshot));
    if (mounted) setState(() => _status = 'Perubahan kategori dan topik HTML disimpan di perangkat ini.');
  }

  Future<void> _addTopic(String categoryKey, int categoryIndex) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah topik'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          maxLength: 700,
          decoration: const InputDecoration(hintText: 'Tulis topik baru…'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Simpan')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty || !mounted || _topicSnapshot == null) return;
    final categories = _topicSnapshot![categoryKey] as List<dynamic>;
    final category = Map<String, dynamic>.from(categories[categoryIndex] as Map);
    final topics = List<String>.from((category['topics'] as List).whereType<String>());
    if (topics.any((topic) => topic.toLowerCase() == value.trim().toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Topik yang sama sudah ada di kategori ini.')));
      return;
    }
    topics.add(value.trim());
    category['topics'] = topics;
    categories[categoryIndex] = category;
    setState(() {});
    await _persistTopicSnapshot();
  }

  Future<void> _deleteTopic(String categoryKey, int categoryIndex, int topicIndex) async {
    if (_topicSnapshot == null) return;
    final categories = _topicSnapshot![categoryKey] as List<dynamic>;
    final category = Map<String, dynamic>.from(categories[categoryIndex] as Map);
    final topics = List<String>.from((category['topics'] as List).whereType<String>());
    if (topicIndex < 0 || topicIndex >= topics.length) return;
    topics.removeAt(topicIndex);
    category['topics'] = topics;
    categories[categoryIndex] = category;
    setState(() {});
    await _persistTopicSnapshot();
  }

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
          else if (value is List && value.every((item) => item is String)) {
            await prefs.setStringList(entry.key, value.cast<String>());
          }
        }
        if (mounted) setState(() => _status = 'Backup Flutter berhasil dipulihkan.');
      } else if (format == 'ignite-couple-game-topics-export') {
        _validateHtmlTopics(decoded);
        await prefs.setString(_htmlTopicsKey, jsonEncode(decoded));
        if (mounted) setState(() {
          _topicSnapshot = Map<String, dynamic>.from(decoded);
          _status = 'Topik HTML berhasil diimpor dan struktur kategorinya disimpan. Konten mode eksplisit tidak digabung ke mode biasa.';
        });
      } else if (format == 'ignite-couple-game-save' && decoded['state'] is Map<String, dynamic>) {
        final state = decoded['state'] as Map<String, dynamic>;
        if (state['categories'] is! List) throw const FormatException('Save game tidak memiliki daftar kategori yang valid.');
        await prefs.setString(_htmlSaveKey, jsonEncode(decoded));
        final topicSnapshot = <String, dynamic>{
          'format': 'ignite-couple-game-topics-export',
          'version': 1,
          'exportId': decoded['exportId'],
          'exportedAt': decoded['savedAt'] ?? DateTime.now().millisecondsSinceEpoch,
          for (final key in [
            'categories',
            'explicitCategories',
            'totCategories',
            'ksCommands',
            'ksCommandsExplicit',
            'roleplayBuiltInRoles',
            'roleplayBuiltInRolesExplicit',
            'roleplayCustomItems',
            'roleplayCustomItemsExplicit',
            'roleplayMode',
          ])
            if (state.containsKey(key)) key: state[key],
        };
        _validateHtmlTopics(topicSnapshot);
        await prefs.setString(_htmlTopicsKey, jsonEncode(topicSnapshot));
        if (mounted) setState(() {
          _topicSnapshot = topicSnapshot;
          _status = 'Save game HTML tersimpan. Topik kartu biasa dipetakan ke Kartu Talk; snapshot sesi lain dipertahankan untuk kompatibilitas.';
        });
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

  Widget _buildTopicManager() {
    final snapshot = _topicSnapshot;
    if (snapshot == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Pengelola kategori HTML akan muncul setelah kalian mengimpor JSON topik atau save game dari versi HTML.'),
        ),
      );
    }
    final sections = <(String, String)>[
      ('categories', 'Kartu Biasa'),
      ('explicitCategories', 'Kategori Eksplisit'),
      ('totCategories', 'Truth or Dare'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pengelola topik HTML', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text('Tambah atau hapus topik per kategori. Perubahan tersimpan di perangkat dan ikut dalam ekspor snapshot topik.', style: TextStyle(height: 1.45)),
        const SizedBox(height: 8),
        for (final section in sections)
          if (snapshot[section.$1] is List)
            for (var categoryIndex = 0; categoryIndex < (snapshot[section.$1] as List).length; categoryIndex++)
              Builder(builder: (context) {
                final category = (snapshot[section.$1] as List)[categoryIndex];
                if (category is! Map || category['topics'] is! List) return const SizedBox.shrink();
                final topics = (category['topics'] as List).whereType<String>().toList();
                final categoryName = (category['name'] ?? section.$2).toString();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Text(categoryName),
                    subtitle: Text('${topics.length} topik'),
                    childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _busy ? null : () => _addTopic(section.$1, categoryIndex),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Tambah topik'),
                        ),
                      ),
                      if (topics.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Align(alignment: Alignment.centerLeft, child: Text('Belum ada topik di kategori ini.')),
                        ),
                      for (var topicIndex = 0; topicIndex < topics.length; topicIndex++)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(topics[topicIndex]),
                          trailing: IconButton(
                            tooltip: 'Hapus topik',
                            onPressed: _busy ? null : () => _deleteTopic(section.$1, categoryIndex, topicIndex),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ),
                    ],
                  ),
                );
              }),
      ],
    );
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
        _buildTopicManager(),
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
