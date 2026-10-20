import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const IgniteApp());

class IgnitePalette {
  static const normalBg = Color(0xFFFFF1F3);
  static const normalSurface = Color(0xFFFFF8F8);
  static const normalPrimary = Color(0xFFE26D7D);
  static const normalAccent = Color(0xFFD97706);
  static const normalText = Color(0xFF381E24);
  static const normalMuted = Color(0xFF85626A);
  static const normalBorder = Color(0xFFF4CFD6);
  static const darkBg = Color(0xFF100816);
  static const darkSurface = Color(0xFF21132C);
  static const darkPrimary = Color(0xFFD43A60);
  static const darkAccent = Color(0xFFB55FE6);
  static const darkText = Color(0xFFFCE7EE);
  static const darkMuted = Color(0xFFA58D9E);
  static const darkBorder = Color(0xFF3D2352);
}

class IgniteApp extends StatefulWidget {
  const IgniteApp({super.key});
  @override
  State<IgniteApp> createState() => _IgniteAppState();
}

class _IgniteAppState extends State<IgniteApp> {
  bool afterDark = false;

  @override
  Widget build(BuildContext context) {
    final p = afterDark ? const Palette.dark() : const Palette.normal();
    return MaterialApp(
      title: 'IGNITE Couple Games',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: afterDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: p.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: p.primary, brightness: afterDark ? Brightness.dark : Brightness.light, surface: p.surface),
        appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, foregroundColor: p.text, elevation: 0),
      ),
      home: IgniteShell(afterDark: afterDark, p: p, onThemeChanged: (v) => setState(() => afterDark = v)),
    );
  }
}

class Palette {
  const Palette({required this.bg, required this.surface, required this.primary, required this.accent, required this.text, required this.muted, required this.border});
  final Color bg, surface, primary, accent, text, muted, border;
  const Palette.normal()
      : bg = IgnitePalette.normalBg, surface = IgnitePalette.normalSurface, primary = IgnitePalette.normalPrimary,
        accent = IgnitePalette.normalAccent, text = IgnitePalette.normalText, muted = IgnitePalette.normalMuted, border = IgnitePalette.normalBorder;
  const Palette.dark()
      : bg = IgnitePalette.darkBg, surface = IgnitePalette.darkSurface, primary = IgnitePalette.darkPrimary,
        accent = IgnitePalette.darkAccent, text = IgnitePalette.darkText, muted = IgnitePalette.darkMuted, border = IgnitePalette.darkBorder;
}

class IgniteShell extends StatefulWidget {
  const IgniteShell({required this.afterDark, required this.p, required this.onThemeChanged, super.key});
  final bool afterDark;
  final Palette p;
  final ValueChanged<bool> onThemeChanged;
  @override
  State<IgniteShell> createState() => _IgniteShellState();
}

class _IgniteShellState extends State<IgniteShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(p: widget.p, onPlay: () => setState(() => tab = 1)),
      GamesPage(p: widget.p),
      InfoPage(p: widget.p, icon: Icons.photo_library_rounded, title: 'Our Memories', subtitle: 'Simpan momen kecil yang ingin kalian ingat selamanya.'),
      InfoPage(p: widget.p, icon: Icons.local_fire_department_rounded, title: 'Bond Progress', subtitle: 'Lihat perjalanan dan kebiasaan yang membangun kedekatan kalian.'),
      ProfilePage(p: widget.p, afterDark: widget.afterDark, onThemeChanged: widget.onThemeChanged),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        backgroundColor: widget.p.surface,
        indicatorColor: widget.p.primary.withValues(alpha: .15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports_rounded), label: 'Play'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library_rounded), label: 'Memories'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department_rounded), label: 'Bond'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({required this.p, required this.onPlay, super.key});
  final Palette p;
  final VoidCallback onPlay;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.favorite_rounded, color: Colors.white)),
        const SizedBox(width: 12),
        Text('IGNITE', style: TextStyle(color: p.text, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3)),
        const Spacer(), Icon(Icons.auto_awesome_rounded, color: p.accent),
      ]),
      const SizedBox(height: 30),
      Text('A little closer,\nevery day.', style: TextStyle(color: p.text, fontSize: 35, height: 1.08, fontWeight: FontWeight.w800, letterSpacing: -1)),
      const SizedBox(height: 12),
      Text('Make room for meaningful conversations, playful moments, and memories made together.', style: TextStyle(color: p.muted, fontSize: 15, height: 1.5)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [p.primary, Color.lerp(p.primary, p.accent, .45)!]), borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR MOMENT TO CONNECT', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Put the phones down.\nPick each other.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          FilledButton.tonal(onPressed: onPlay, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: p.primary), child: const Text('Find a game  →')),
        ]),
      ),
      const SizedBox(height: 28),
      Text('Made for two', style: TextStyle(color: p.text, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _Feature(p: p, icon: Icons.chat_bubble_rounded, title: 'Deep talks', subtitle: 'Ask & listen')),
        const SizedBox(width: 12),
        Expanded(child: _Feature(p: p, icon: Icons.casino_rounded, title: 'Play together', subtitle: 'Laugh & explore')),
      ]),
    ],
  );
}

class _Feature extends StatelessWidget {
  const _Feature({required this.p, required this.icon, required this.title, required this.subtitle});
  final Palette p; final IconData icon; final String title, subtitle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.border), borderRadius: BorderRadius.circular(22)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: p.primary, size: 25), const SizedBox(height: 18),
      Text(title, style: TextStyle(color: p.text, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: p.muted, fontSize: 12)),
    ]),
  );
}

class GameInfo {
  const GameInfo(this.emoji, this.title, this.description);
  final String emoji, title, description;
}

const gameCatalog = [
  GameInfo('💬', 'Kartu Talk', 'Pertanyaan untuk percakapan yang lebih dekat.'),
  GameInfo('🎲', 'Ular Tangga', 'Lempar dadu dan buka tantangan berdua.'),
  GameInfo('❤️', 'Truth or Dare', 'Pilih jujur atau tantangan untuk pasangan.'),
  GameInfo('👑', 'King & Slave', 'Role-based couple challenges.'),
  GameInfo('🎡', 'Roulette', 'Biarkan roda memilih momen berikutnya.'),
  GameInfo('🌙', 'Roleplay', 'Ciptakan skenario dan karakter bersama.'),
  GameInfo('♟️', 'Chess & Command', 'Strategi ringan dengan perintah pasangan.'),
  GameInfo('🧠', 'Know Your Partner', 'Seberapa baik kalian saling mengenal?'),
  GameInfo('🎵', 'Guess Our Song', 'Uji memori musik dan lagu kalian.'),
  GameInfo('✨', 'Gratitude Jar', 'Catat hal kecil yang kalian syukuri.'),
  GameInfo('🌱', 'Dream Planning', 'Rancang mimpi yang ingin dicapai bersama.'),
  GameInfo('🎭', 'Couple Charades', 'Tebak gaya dan ekspresi pasangan.'),
  GameInfo('💌', 'Love Contract', 'Buat komitmen kecil yang berarti.'),
  GameInfo('🫶', 'Couple Spa', 'Jeda lembut untuk merawat satu sama lain.'),
];

class GamesPage extends StatelessWidget {
  const GamesPage({required this.p, super.key});
  final Palette p;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Play together', style: TextStyle(color: p.text, fontSize: 29, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('Pilih suasana. Sisanya, nikmati waktu berdua.', style: TextStyle(color: p.muted)),
      const SizedBox(height: 20),
      for (final game in gameCatalog)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: p.surface, borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => game.title == 'Truth or Dare' ? TruthOrDarePage(p: p) : GameIntroPage(p: p, game: game),
              )),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(border: Border.all(color: p.border), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: p.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Text(game.emoji, style: const TextStyle(fontSize: 23))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(game.title, style: TextStyle(color: p.text, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4), Text(game.description, style: TextStyle(color: p.muted, fontSize: 12, height: 1.3)),
                  ])),
                  Icon(Icons.chevron_right_rounded, color: p.muted),
                ]),
              ),
            ),
          ),
        ),
    ],
  );
}

class GameIntroPage extends StatelessWidget {
  const GameIntroPage({required this.p, required this.game, super.key});
  final Palette p; final GameInfo game;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(game.title)),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(game.emoji, style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 20),
      Text(game.title, style: TextStyle(color: p.text, fontSize: 30, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(game.description, style: TextStyle(color: p.muted, fontSize: 16, height: 1.5)),
      const SizedBox(height: 20),
      Text('Mode ini akan diintegrasikan dari source Flutter dan diaudit terhadap versi IGNITE sebelumnya.', style: TextStyle(color: p.muted, height: 1.5)),
    ])),
  );
}

class TruthOrDarePage extends StatefulWidget {
  const TruthOrDarePage({required this.p, super.key});
  final Palette p;
  @override
  State<TruthOrDarePage> createState() => _TruthOrDarePageState();
}

class _TruthOrDarePageState extends State<TruthOrDarePage> {
  final random = Random();
  bool dare = false;
  int round = 0;
  String prompt = 'Pilih Truth atau Dare untuk memulai ronde kalian.';
  static const truths = ['Apa hal kecil yang selalu membuatmu merasa dicintai?', 'Kapan kamu merasa paling dekat denganku?', 'Apa kenangan kita yang ingin kamu ulangi?', 'Apa satu hal yang ingin lebih sering kita lakukan bersama?', 'Apa yang pertama kali membuatmu tertarik padaku?'];
  static const dares = ['Berikan pasanganmu pelukan selama 20 detik.', 'Sebutkan tiga hal yang kamu kagumi dari pasanganmu.', 'Pilih satu lagu yang mengingatkanmu pada hubungan kalian.', 'Tatap mata pasanganmu selama 15 detik tanpa tertawa.', 'Buat pasanganmu tersenyum dalam 30 detik.'];

  void next(bool isDare) {
    setState(() {
      dare = isDare;
      round++;
      final list = isDare ? dares : truths;
      prompt = list[random.nextInt(list.length)];
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Truth or Dare')),
    body: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('ROUND ' + (round + 1).toString(), textAlign: TextAlign.center, style: TextStyle(color: widget.p.muted, letterSpacing: 2, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Expanded(child: Container(
        alignment: Alignment.center, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.p.primary, Color.lerp(widget.p.primary, widget.p.accent, .4)!]), borderRadius: BorderRadius.circular(30)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(dare ? '🔥 DARE' : (round == 0 ? '💗 READY?' : '💗 TRUTH'), style: const TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text(prompt, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, height: 1.35, fontWeight: FontWeight.w700)),
        ]),
      )),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: FilledButton(onPressed: () => next(false), style: FilledButton.styleFrom(backgroundColor: widget.p.primary, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('💗 Truth'))),
        const SizedBox(width: 12),
        Expanded(child: FilledButton(onPressed: () => next(true), style: FilledButton.styleFrom(backgroundColor: widget.p.accent, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('🔥 Dare'))),
      ]),
      const SizedBox(height: 10),
      TextButton(onPressed: () => next(dare), child: Text('Another prompt ↻', style: TextStyle(color: widget.p.muted))),
    ])),
  );
}

class InfoPage extends StatelessWidget {
  const InfoPage({required this.p, required this.icon, required this.title, required this.subtitle, super.key});
  final Palette p; final IconData icon; final String title, subtitle;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 54, color: p.primary), const SizedBox(height: 18),
      Text(title, style: TextStyle(color: p.text, fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10), Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: p.muted, height: 1.5)),
      const SizedBox(height: 20),
      Text('Area ini akan diintegrasikan dengan provider dan penyimpanan dari source Flutter.', textAlign: TextAlign.center, style: TextStyle(color: p.muted)),
    ]),
  ));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.p, required this.afterDark, required this.onThemeChanged, super.key});
  final Palette p; final bool afterDark; final ValueChanged<bool> onThemeChanged;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(22), children: [
    Text('Your space', style: TextStyle(color: p.text, fontSize: 29, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), Text('Atur suasana yang paling terasa seperti kalian.', style: TextStyle(color: p.muted)),
    const SizedBox(height: 24),
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: p.border)),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero, value: afterDark, onChanged: onThemeChanged,
        title: Text('After Dark', style: TextStyle(color: p.text, fontWeight: FontWeight.bold)),
        subtitle: Text(afterDark ? 'Deep elegant · wine & obsidian' : 'Sweet elegant · warm rose & blush', style: TextStyle(color: p.muted)),
        secondary: Icon(afterDark ? Icons.dark_mode_rounded : Icons.wb_twilight_rounded, color: p.primary),
      ),
    ),
    const SizedBox(height: 18),
    Text('IGNITE Couple Games', style: TextStyle(color: p.text, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6), Text('A little closer, every day.', style: TextStyle(color: p.muted)),
  ]);
}
