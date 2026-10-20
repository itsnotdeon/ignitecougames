import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../providers/couple_provider.dart';
import '../../providers/memories_provider.dart';
import '../../models/memory_item.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/gradient_button.dart';

// ─────────────────────────────────────────────
//  Data
// ─────────────────────────────────────────────

class _Genre {
  final String emoji;
  final String label;
  final String key;
  const _Genre({required this.emoji, required this.label, required this.key});
}

const List<_Genre> _genres = [
  _Genre(emoji: '🌹', label: 'Romantis', key: 'romantic'),
  _Genre(emoji: '⚔️', label: 'Petualangan', key: 'adventure'),
  _Genre(emoji: '😂', label: 'Komedi', key: 'comedy'),
  _Genre(emoji: '✨', label: 'Fantasi', key: 'fantasy'),
  _Genre(emoji: '🔮', label: 'Misteri', key: 'mystery'),
];

const int _totalRounds = 10;
const int _storyXp = 30;

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────

class StoryContinuesScreen extends StatefulWidget {
  const StoryContinuesScreen({super.key});

  @override
  State<StoryContinuesScreen> createState() => _StoryContinuesScreenState();
}

class _StoryContinuesScreenState extends State<StoryContinuesScreen>
    with TickerProviderStateMixin {
  _Genre? _selectedGenre;
  int _currentTurn = 1; // 1 or 2
  final List<Map<String, String>> _storySegments = []; // {player, text}
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComplete = false;
  bool _isSaving = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _fullStory =>
      _storySegments.map((s) => s['text'] ?? '').join(' ');

  int get _currentRound => _storySegments.length + 1;

  String _playerName(int player) {
    final profile = context.read<CoupleProvider>().profile;
    if (player == 1) {
      return profile.partner1.isNotEmpty ? profile.partner1 : 'Player 1';
    }
    return profile.partner2.isNotEmpty ? profile.partner2 : 'Player 2';
  }

  String get _turnPrompt {
    if (_storySegments.isEmpty) {
      return '${_playerName(1)}, mulai cerita! Tulis kalimat pembuka yang menarik 📖';
    }
    if (_currentTurn == 1) {
      return '${_playerName(1)}, lanjutkan ceritanya! ✍️';
    }
    return '${_playerName(2)}, giliranmu melanjutkan! ✍️';
  }

  void _submitSegment() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _storySegments.add({'player': '$_currentTurn', 'text': text});
      _textController.clear();

      if (_storySegments.length >= _totalRounds) {
        _isComplete = true;
        context.read<BondProvider>().addXp(_storyXp);
        _saveStoryToPrefs();
        Future.delayed(const Duration(milliseconds: 300), _showCompletionDialog);
      } else {
        _currentTurn = _currentTurn == 1 ? 2 : 1;
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveStoryToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = _storySegments.map((s) => '${s['player']}||${s['text']}').toList();
      await prefs.setStringList('story_continues_last', entries);
      await prefs.setString('story_continues_genre', _selectedGenre?.key ?? '');
      await prefs.setString(
          'story_continues_date', DateTime.now().toIso8601String());
    } catch (_) {}
  }

  void _saveAsMemory() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final genre = _selectedGenre;
    final storyText = _fullStory;
    final p1 = _playerName(1);
    final p2 = _playerName(2);

    const uuid = Uuid();
    final memory = MemoryItem(
      id: uuid.v4(),
      title:
          'Cerita Bersama${genre != null ? ' - ${genre.label}' : ''} ${genre?.emoji ?? '📖'}',
      note: '$p1 & $p2 menulis cerita bersama:\n\n$storyText',
      date: DateTime.now(),
      category: 'Story',
      isFavorite: false,
      emoji: genre?.emoji ?? '📖',
    );

    if (mounted) {
      await context.read<MemoriesProvider>().addMemory(memory);
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cerita disimpan sebagai Kenangan! 💕'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop(); // close dialog
        Navigator.of(context).pop(); // back to play screen
      }
    }
  }

  void _showCompletionDialog() {
    if (!mounted) return;
    final isAfterDark = context.read<AppProvider>().isAfterDark;
    final p1 = _playerName(1);
    final p2 = _playerName(2);
    final genre = _selectedGenre;

    final bgColor = isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final cardBg = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final borderColor = isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Text(
                    genre?.emoji ?? '📖',
                    style: const TextStyle(fontSize: 44),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cerita Selesai!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Karya $p1 & $p2',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),

            // Story scroll
            Container(
              height: 260,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _storySegments.map((seg) {
                      final p = int.tryParse(seg['player'] ?? '1') ?? 1;
                      final pName = p == 1 ? p1 : p2;
                      final pColor = p == 1
                          ? primaryColor
                          : (isAfterDark
                              ? AppColors.darkSecondary
                              : AppColors.normalSecondary);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: pColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              seg['text'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // XP & CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                '+$_storyXp XP earned! ⭐',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Cerita kalian luar biasa! Simpan sebagai kenangan spesial? 💕',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: mutedColor, height: 1.4),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: _isSaving ? 'Menyimpan...' : 'Simpan sebagai Kenangan 💕',
                  onPressed: _saveAsMemory,
                  icon: Icons.favorite_rounded,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Selesai',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;

    final bgTop = isAfterDark ? AppColors.darkBgTop : AppColors.normalBgTop;
    final bgBottom =
        isAfterDark ? AppColors.darkBgBottom : AppColors.normalBgBottom;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Story Continues 📖',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Bangun cerita bersama',
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedGenre != null && !_isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_storySegments.length} / $_totalRounds',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Genre selection or game area
              Expanded(
                child: _selectedGenre == null
                    ? _GenreSelectionView(
                        isAfterDark: isAfterDark,
                        onSelect: (genre) {
                          setState(() => _selectedGenre = genre);
                        },
                      )
                    : _GameView(
                        genre: _selectedGenre!,
                        storySegments: _storySegments,
                        currentTurn: _currentTurn,
                        currentRound: _currentRound,
                        totalRounds: _totalRounds,
                        turnPrompt: _turnPrompt,
                        textController: _textController,
                        scrollController: _scrollController,
                        isComplete: _isComplete,
                        isAfterDark: isAfterDark,
                        onSubmit: _submitSegment,
                        getPlayerName: _playerName,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Genre Selection View
// ─────────────────────────────────────────────

class _GenreSelectionView extends StatelessWidget {
  final bool isAfterDark;
  final void Function(_Genre) onSelect;

  const _GenreSelectionView({
    required this.isAfterDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('📖', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 12),
                Text(
                  'Story Continues',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bangun sebuah cerita bersama pasanganmu!\nSaling bergantian menulis dan ciptakan kisah yang tak terlupakan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: mutedColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '+$_storyXp XP untuk menyelesaikan cerita!',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pilih Genre Cerita',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          ...List.generate(_genres.length, (i) {
            final genre = _genres[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSelect(genre),
                child: CustomCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(genre.emoji,
                              style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              genre.label,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              _genreDescription(genre.key),
                              style: TextStyle(
                                  fontSize: 12, color: mutedColor, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 16, color: mutedColor),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _genreDescription(String key) {
    switch (key) {
      case 'romantic':
        return 'Cerita penuh cinta, kehangatan, dan momen berharga';
      case 'adventure':
        return 'Petualangan seru dengan tantangan dan kejutan';
      case 'comedy':
        return 'Kisah lucu yang bikin kalian tertawa bersama';
      case 'fantasy':
        return 'Dunia magis dengan makhluk dan kekuatan ajaib';
      case 'mystery':
        return 'Teka-teki gelap yang harus dipecahkan bersama';
      default:
        return '';
    }
  }
}

// ─────────────────────────────────────────────
//  Game View
// ─────────────────────────────────────────────

class _GameView extends StatelessWidget {
  final _Genre genre;
  final List<Map<String, String>> storySegments;
  final int currentTurn;
  final int currentRound;
  final int totalRounds;
  final String turnPrompt;
  final TextEditingController textController;
  final ScrollController scrollController;
  final bool isComplete;
  final bool isAfterDark;
  final VoidCallback onSubmit;
  final String Function(int) getPlayerName;

  const _GameView({
    required this.genre,
    required this.storySegments,
    required this.currentTurn,
    required this.currentRound,
    required this.totalRounds,
    required this.turnPrompt,
    required this.textController,
    required this.scrollController,
    required this.isComplete,
    required this.isAfterDark,
    required this.onSubmit,
    required this.getPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final secondaryColor =
        isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary;
    final cardBg = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final borderColor =
        isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

    return Column(
      children: [
        // Genre + Progress header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(genre.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      genre.label,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!isComplete)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: storySegments.length / totalRounds,
                      backgroundColor: primaryColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 6,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Story scroll area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: storySegments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              genre.emoji,
                              style: const TextStyle(fontSize: 52),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Cerita belum dimulai...',
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mulai dengan kalimat pembuka!',
                              style: TextStyle(
                                  color: mutedColor.withValues(alpha: 0.6),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: storySegments.length,
                        itemBuilder: (_, i) {
                          final seg = storySegments[i];
                          final p = int.tryParse(seg['player'] ?? '1') ?? 1;
                          final pName = getPlayerName(p);
                          final pColor =
                              p == 1 ? primaryColor : secondaryColor;
                          final isRight = p == 2;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: isRight
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isRight) ...[
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        pColor.withValues(alpha: 0.2),
                                    child: Text(
                                      pName.isNotEmpty
                                          ? pName[0].toUpperCase()
                                          : 'P',
                                      style: TextStyle(
                                        color: pColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: pColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                            isRight ? 16 : 4),
                                        topRight: Radius.circular(
                                            isRight ? 4 : 16),
                                        bottomLeft:
                                            const Radius.circular(16),
                                        bottomRight:
                                            const Radius.circular(16),
                                      ),
                                      border: Border.all(
                                          color:
                                              pColor.withValues(alpha: 0.25)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isRight
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: pColor,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          seg['text'] ?? '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textColor,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isRight) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        pColor.withValues(alpha: 0.2),
                                    child: Text(
                                      pName.isNotEmpty
                                          ? pName[0].toUpperCase()
                                          : 'P',
                                      style: TextStyle(
                                        color: pColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Input area
        if (!isComplete)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Turn indicator
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentTurn == 1
                            ? primaryColor
                            : secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        turnPrompt,
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Text field + send button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          controller: textController,
                          style: TextStyle(color: textColor, fontSize: 14),
                          maxLines: 5,
                          minLines: 2,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => onSubmit(),
                          decoration: InputDecoration(
                            hintText: currentRound == 1
                                ? 'Tulis kalimat pembuka...'
                                : 'Lanjutkan ceritanya...',
                            hintStyle: TextStyle(
                                color: mutedColor.withValues(alpha: 0.5),
                                fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onSubmit,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}