import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuessOurSongScreen extends StatefulWidget {
  const GuessOurSongScreen({super.key});

  @override
  State<GuessOurSongScreen> createState() => _GuessOurSongScreenState();
}

class _GuessOurSongScreenState extends State<GuessOurSongScreen> {
  static const _songs = <({String title, String artist, String clue})>[
    (title: 'Perfect', artist: 'Ed Sheeran', clue: 'Lagu pop romantis tentang menemukan pasangan yang terasa tepat dan membayangkan masa depan bersama.'),
    (title: 'A Thousand Years', artist: 'Christina Perri', clue: 'Balada soundtrack film tentang menunggu cinta dan berani melangkah meski takut.'),
    (title: 'Can’t Help Falling in Love', artist: 'Elvis Presley', clue: 'Lagu klasik yang menggambarkan jatuh cinta sebagai sesuatu yang sulit dihindari.'),
    (title: 'All of Me', artist: 'John Legend', clue: 'Piano ballad tentang mencintai pasangan dengan segala kelebihan dan kekurangannya.'),
    (title: 'Yellow', artist: 'Coldplay', clue: 'Lagu rock alternatif yang menggunakan warna sebagai simbol rasa kagum dan kasih sayang.'),
  ];
  final _random = Random();
  final _guess = TextEditingController();
  List<String> _playlist = [];
  int _round = 0;
  int _score = 0;
  bool _revealed = false;
  String? _feedback;

  @override
  void initState() { super.initState(); _loadPlaylist(); }
  @override
  void dispose() { _guess.dispose(); super.dispose(); }
  Future<void> _loadPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _playlist = prefs.getStringList('ignite_couple_playlist') ?? <String>[]);
  }
  Future<void> _savePlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ignite_couple_playlist', _playlist);
  }
  Future<void> _addSong() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(title: const Text('Tambah lagu kenangan'), content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Judul — Artis')), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Tambah'))]));
    controller.dispose();
    if (result == null || result.isEmpty) return;
    if (_playlist.any((song) => song.toLowerCase() == result.toLowerCase())) return;
    setState(() => _playlist = [..._playlist, result]);
    await _savePlaylist();
  }
  void _checkGuess() {
    final song = _songs[_round % _songs.length];
    final correct = _guess.text.trim().toLowerCase() == song.title.toLowerCase();
    setState(() { _revealed = true; _feedback = correct ? 'Benar! +1 poin 🎉' : 'Belum tepat—jawabannya ditampilkan di bawah.'; if (correct) _score++; });
  }
  void _nextRound() {
    setState(() { _round = (_round + 1 + _random.nextInt(_songs.length - 1)) % _songs.length; _guess.clear(); _revealed = false; _feedback = null; });
  }

  @override
  Widget build(BuildContext context) {
    final song = _songs[_round % _songs.length];
    return DefaultTabController(length: 2, child: Scaffold(appBar: AppBar(title: const Text('Guess Our Song'), bottom: const TabBar(tabs: [Tab(text: '🎵 Tebak Lagu'), Tab(text: 'Our Playlist 🎵')])), body: TabBarView(children: [
      ListView(padding: const EdgeInsets.all(20), children: [Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B1730), Color(0xFF24152F)]), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('PETUNJUK LAGU', style: TextStyle(color: Color(0xFFF37597), fontWeight: FontWeight.bold, letterSpacing: 1.4)), const SizedBox(height: 18), Text(song.clue, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5)), const SizedBox(height: 22), TextField(controller: _guess, enabled: !_revealed, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Tebak judul lagu', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF37597))))), if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_feedback!, style: const TextStyle(color: Colors.white))), if (_revealed) Padding(padding: const EdgeInsets.only(top: 10), child: Text('${song.title} — ${song.artist}', style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 18))), const SizedBox(height: 14), if (!_revealed) FilledButton(onPressed: _checkGuess, child: const Text('Periksa jawaban')) else FilledButton.tonal(onPressed: _nextRound, child: const Text('Lagu berikutnya'))])), const SizedBox(height: 16), Text('Skor: $_score', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
      ListView(padding: const EdgeInsets.all(20), children: [Text('Daftar lagu yang punya cerita untuk kalian. Tambahkan judul dan artis secara manual.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5)), const SizedBox(height: 12), FilledButton.icon(onPressed: _addSong, icon: const Icon(Icons.add), label: const Text('Tambah lagu')), const SizedBox(height: 8), if (_playlist.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Playlist masih kosong. Tambahkan lagu pertama kalian.', textAlign: TextAlign.center)) else ..._playlist.map((song) => Card(child: ListTile(leading: const Icon(Icons.music_note), title: Text(song), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { setState(() => _playlist.remove(song)); await _savePlaylist(); }))))]),
    ])));
  }
}