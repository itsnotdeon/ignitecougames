import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import 'truth_or_dare_screen.dart';
import 'snake_ladder_screen.dart';
import 'this_or_that_screen.dart';
import 'know_your_partner_screen.dart';
import 'would_you_rather_screen.dart';
import 'story_continues_screen.dart';
import 'two_minute_challenge_screen.dart';
import 'couple_charades_screen.dart';
import 'dare_wheel_screen.dart';
import 'gratitude_jar_screen.dart';
import 'dream_planning_screen.dart';
import 'couple_spa_screen.dart';
import 'love_contract_screen.dart';
import 'guess_our_song_screen.dart';
import 'kartu_talk_screen.dart';
import 'king_slave_screen.dart';
import 'roulette_screen.dart';
import 'roleplay_screen.dart';
import 'chess_command_screen.dart';
import 'html_snake_ladder_screen.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Permainan untuk Berdua'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          indicatorPadding: const EdgeInsets.symmetric(vertical: 5),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelColor: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
          unselectedLabelColor: isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '✨ Semua'),
            Tab(text: '🃏 Kuis & Tebak'),
            Tab(text: '⏱️ Aksi & Tantangan'),
            Tab(text: '🌙 Koneksi & Ritual'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: ALL GAMES
            _buildAllGamesList(context, isAfterDark),

            // TAB 2: KUIS & TEBAK
            _buildCategoryList(context, isAfterDark, [
              _GameItem(
                emoji: '🃏',
                title: 'Truth or Dare: Couple',
                category: isAfterDark ? '🌙 After Dark & Intimate' : '🌹 Romantic & Deep Talk',
                desc: 'Ratusan pertanyaan jujur dan tantangan manis untuk saling mengenal lebih dalam.',
                xpLabel: '+20-40 XP',
                destination: const TruthOrDareScreen(),
              ),
              _GameItem(
                emoji: '🧠',
                title: 'This or That (Couple)',
                category: '⚡ Pilihan Kilat',
                desc: 'Pilih antara 2 opsi romantis sekaligus dan bandingkan jawaban kalian!',
                xpLabel: '+20 XP',
                destination: const ThisOrThatScreen(),
              ),
              _GameItem(
                emoji: '🔮',
                title: 'Know Your Partner Quiz',
                category: '❤️ Uji Keintiman',
                desc: '20 pertanyaan tentang pasangan untuk mengukur seberapa dalam kamu mengenalnya.',
                xpLabel: '+5 XP / benar',
                destination: const KnowYourPartnerScreen(),
              ),
              _GameItem(
                emoji: '🎴',
                title: 'Would You Rather',
                category: '🤔 Dilema Cinta',
                desc: '15 skenario romantis dan menggelitik yang memancing obrolan seru.',
                xpLabel: '+15 XP',
                destination: const WouldYouRatherScreen(),
              ),
              _GameItem(
                emoji: '🎵',
                title: 'Guess Our Song',
                category: '🎶 Nostalgia Musik',
                desc: 'Tebak judul lagu cinta dari potongan lirik + simpan playlist kenangan berdua.',
                xpLabel: '+15 XP',
                destination: const GuessOurSongScreen(),
              ),
            ]),

            // TAB 3: AKSI & TANTANGAN
            _buildCategoryList(context, isAfterDark, [
              _GameItem(
                emoji: '🎲',
                title: 'Snake & Ladder: Love Board',
                category: '🎯 Papan Interaktif',
                desc: 'Papan ular tangga 36 petak dengan tangga cinta dan misi romantis spesial.',
                xpLabel: '+80 XP',
                destination: const SnakeLadderScreen(),
              ),
              _GameItem(
                emoji: '⏱️',
                title: '2-Minute Challenge',
                category: '🔥 Misi Waktu',
                desc: '20 tantangan fisik singkat dengan countdown timer interaktif 2 menit.',
                xpLabel: '+25 XP',
                destination: const TwoMinuteChallengeScreen(),
              ),
              _GameItem(
                emoji: '🎭',
                title: 'Couple Charades',
                category: '🎬 Tebak Gaya',
                desc: 'Peragakan kata cinta tanpa suara selama 60 detik untuk ditebak pasangan!',
                xpLabel: '+10 XP / kata',
                destination: const CoupleCharadesScreen(),
              ),
              _GameItem(
                emoji: '🎡',
                title: 'Dare Wheel (Roulette)',
                category: '🎲 Roda Keberuntungan',
                desc: 'Putar roda roulette untuk mendapatkan tantangan Manis, Lucu, Berani, atau Intim.',
                xpLabel: '+20 XP',
                destination: const DareWheelScreen(),
              ),
            ]),

            // TAB 4: KONEKSI & RITUAL
            _buildCategoryList(context, isAfterDark, [
              _GameItem(
                emoji: '📖',
                title: 'Story Continues',
                category: '✨ Cerita Bersama',
                desc: 'Bangun dongeng cinta fiksi bergantian kalimat demi kalimat bersama pasangan.',
                xpLabel: '+30 XP',
                destination: const StoryContinuesScreen(),
              ),
              _GameItem(
                emoji: '🌟',
                title: 'Gratitude Jar',
                category: '💌 Toples Syukur',
                desc: 'Tulis apresiasi harian untuk pasangan dan buka bersama saat kencan.',
                xpLabel: '+10 XP / pesan',
                destination: const GratitudeJarScreen(),
              ),
              _GameItem(
                emoji: '💭',
                title: 'Dream Planning',
                category: '🗺️ Visi Masa Depan',
                desc: 'Rencanakan impian liburan, rumah idaman, dan tujuan hidup bersama berdua.',
                xpLabel: '+50 XP',
                destination: const DreamPlanningScreen(),
              ),
              _GameItem(
                emoji: '💆',
                title: 'Couple Spa Night',
                category: '🌿 Panduan Relaksasi',
                desc: 'Sesi pijat romantis terpandu dengan timer santai dan ritual sentuhan hangat.',
                xpLabel: '+40 XP',
                destination: const CoupleSpaScreen(),
              ),
              _GameItem(
                emoji: '📜',
                title: 'Love Contract',
                category: '✍️ Perjanjian Manja',
                desc: 'Buat kesepakatan cinta lucu & bermakna yang ditandatangani berdua secara digital.',
                xpLabel: '+30 XP',
                destination: const LoveContractScreen(),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAllGamesList(BuildContext context, bool isAfterDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        _buildSectionHeader(context, '🔥 Mode Utama dari HTML IGNITE'),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🐍',
          title: 'Ular Tangga Cinta — HTML',
          category: '🎲 Papan 100 petak',
          desc: 'Versi migrasi dari HTML dengan papan 1–100, tangga, ular, giliran, dan petak topik spesial.',
          xpLabel: 'Mode utama',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HtmlSnakeLadderScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '💬',
          title: 'Kartu Talk',
          category: '🃏 Kartu Biasa & topik obrolan',
          desc: 'Kartu topik yang bersumber dari HTML IGNITE, dengan kategori obrolan dan kartu berikutnya.',
          xpLabel: 'Mode utama',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KartuTalkScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '👑',
          title: 'King & Slave',
          category: '👑 Command Card & Power Card',
          desc: 'Ronde peran, kartu perintah, power card, dan persetujuan kedua pemain.',
          xpLabel: 'Mode utama',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KingSlaveScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🔫',
          title: 'Russian Roulette Cinta',
          category: '🎲 Roulette virtual',
          desc: 'Peluang digital, pergantian giliran, dan hitungan hasil virtual tanpa senjata nyata.',
          xpLabel: 'Mode utama',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IgniteRouletteScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🎭',
          title: 'Roleplay',
          category: '🎭 Peran & skenario',
          desc: 'Acak skenario atau tulis skenario custom bersama.',
          xpLabel: 'Mode utama',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IgniteRoleplayScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '♟️',
          title: 'Chess & Command',
          category: '♟️ Papan & Command Card',
          desc: 'Papan catur interaktif dan command card dengan gerbang persetujuan.',
          xpLabel: 'Mode utama',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChessCommandScreen())),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, '🎲 Papan & Klasik'),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🎲',
          title: 'Snake & Ladder: Love Board',
          category: '🎯 Papan Interaktif',
          desc: 'Papan dadu 36 petak dengan tangga cinta, perangkap ular, dan petak aksi romantis.',
          xpLabel: '+80 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SnakeLadderScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🃏',
          title: 'Truth or Dare: Couple',
          category: isAfterDark ? '🌙 After Dark & Intimate' : '🌹 Romantic & Deep Talk',
          desc: 'Ratusan pertanyaan jujur dan tantangan manis untuk saling mengenal lebih dalam.',
          xpLabel: '+20-40 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TruthOrDareScreen())),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader(context, '🧠 Kuis & Tebak-Tebakan'),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🧠',
          title: 'This or That',
          category: '⚡ Pilihan Kilat',
          desc: 'Pilih antara 2 opsi romantis secara simultan dan bandingkan kecocokan kalian!',
          xpLabel: '+20 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThisOrThatScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🔮',
          title: 'Know Your Partner Quiz',
          category: '❤️ Uji Keintiman',
          desc: '20 pertanyaan tentang pasangan untuk mengukur seberapa dalam saling mengenal.',
          xpLabel: '+5 XP / benar',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KnowYourPartnerScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🎴',
          title: 'Would You Rather',
          category: '🤔 Dilema Cinta',
          desc: 'Pilih antara dua skenario hubungan yang menantang dan memancing diskusi manis.',
          xpLabel: '+15 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WouldYouRatherScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🎵',
          title: 'Guess Our Song',
          category: '🎶 Nostalgia Musik',
          desc: 'Tebak lagu dari potongan lirik & bangun playlist lagu bermakna berdua.',
          xpLabel: '+15 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuessOurSongScreen())),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader(context, '⏱️ Aksi & Tantangan'),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '⏱️',
          title: '2-Minute Challenge',
          category: '🔥 Misi Waktu',
          desc: 'Tantangan fisik ringan dengan countdown timer 2 menit yang interaktif.',
          xpLabel: '+25 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TwoMinuteChallengeScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🎭',
          title: 'Couple Charades',
          category: '🎬 Tebak Gaya',
          desc: 'Peragakan kata-kata romantis tanpa suara dalam 60 detik.',
          xpLabel: '+10 XP / kata',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoupleCharadesScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🎡',
          title: 'Dare Wheel (Roulette)',
          category: '🎲 Roda Putar',
          desc: 'Putar roda roulette beranimasi untuk mendapatkan tantangan Manis hingga Intim.',
          xpLabel: '+20 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DareWheelScreen())),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader(context, '🌙 Koneksi Mendalam & Ritual'),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '📖',
          title: 'Story Continues',
          category: '✨ Dongeng Berdua',
          desc: 'Membangun cerita romantis bersama secara bergantian kalimat demi kalimat.',
          xpLabel: '+30 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryContinuesScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '🌟',
          title: 'Gratitude Jar',
          category: '💌 Toples Syukur',
          desc: 'Simpan ucapan syukur harian untuk pasangan dan buka bersama saat berkencan.',
          xpLabel: '+10 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GratitudeJarScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '💭',
          title: 'Dream Planning',
          category: '🗺️ Visi Masa Depan',
          desc: 'Jawab bersama impian perjalanan, rumah idaman, dan masa depan hubungan.',
          xpLabel: '+50 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DreamPlanningScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '💆',
          title: 'Couple Spa Night',
          category: '🌿 Panduan Relaksasi',
          desc: 'Panduan step-by-step sesi spa & pijat berdua dengan timer yang menenangkan.',
          xpLabel: '+40 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoupleSpaScreen())),
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          context,
          isAfterDark,
          emoji: '📜',
          title: 'Love Contract',
          category: '✍️ Perjanjian Cinta',
          desc: 'Tanda tangani kontrak lucu dan manis yang dapat disesuaikan klausulnya.',
          xpLabel: '+30 XP',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoveContractScreen())),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context, bool isAfterDark, List<_GameItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(
          context,
          isAfterDark,
          emoji: item.emoji,
          title: item.title,
          category: item.category,
          desc: item.desc,
          xpLabel: item.xpLabel,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.destination)),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    bool isAfterDark, {
    required String emoji,
    required String title,
    required String category,
    required String desc,
    required String xpLabel,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 19, color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                xpLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameItem {
  final String emoji;
  final String title;
  final String category;
  final String desc;
  final String xpLabel;
  final Widget destination;

  const _GameItem({
    required this.emoji,
    required this.title,
    required this.category,
    required this.desc,
    required this.xpLabel,
    required this.destination,
  });
}