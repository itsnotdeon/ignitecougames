import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

class SnakeLadderScreen extends StatefulWidget {
  const SnakeLadderScreen({super.key});

  @override
  State<SnakeLadderScreen> createState() => _SnakeLadderScreenState();
}

class _SnakeLadderScreenState extends State<SnakeLadderScreen> {
  static const int totalTiles = 36; // 6x6 Board

  // Ladders: Start -> End (climb up)
  final Map<int, int> ladders = {
    4: 14,
    9: 22,
    17: 29,
    21: 33,
  };

  // Snakes: Head -> Tail (slide down)
  final Map<int, int> snakes = {
    15: 5,
    23: 11,
    31: 19,
    35: 18,
  };

  // Romantic Couple Special Action Tiles
  final Map<int, String> coupleActions = {
    7: 'Kecup pipi pasangan dengan lembut 💋',
    13: 'Bisikkan satu kata cinta paling manis 🍯',
    20: 'Peluk erat dari belakang selama 15 detik 🫂',
    27: 'Pijat lembut tangan pasanganmu ✨',
  };

  int _player1Pos = 1;
  int _player2Pos = 1;
  int _currentTurn = 1; // 1 or 2
  int _lastDice = 1;
  bool _isRolling = false;
  String _statusMessage = 'Lempar dadu untuk memulai!';
  bool _hasWon = false;

  void _rollDice() async {
    if (_isRolling || _hasWon) return;

    setState(() {
      _isRolling = true;
    });

    final random = Random();
    int dice = 1;
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 70));
      if (!mounted) return;
      setState(() {
        dice = random.nextInt(6) + 1;
        _lastDice = dice;
      });
    }

    if (!mounted) return;
    final couple = context.read<CoupleProvider>().profile;
    final activeName = _currentTurn == 1 ? couple.partner1 : couple.partner2;

    int currentPos = _currentTurn == 1 ? _player1Pos : _player2Pos;
    int nextPos = currentPos + dice;

    if (nextPos > totalTiles) {
      setState(() {
        _isRolling = false;
        _statusMessage = '$activeName butuh pas untuk mencapai petak $totalTiles!';
        _currentTurn = _currentTurn == 1 ? 2 : 1;
      });
      return;
    }

    String actionMsg = '$activeName maju $dice langkah!';

    // Check Ladder
    if (ladders.containsKey(nextPos)) {
      final dest = ladders[nextPos]!;
      actionMsg += ' 🪜 Naik Tangga Cinta ke petak $dest!';
      nextPos = dest;
    }
    // Check Snake
    else if (snakes.containsKey(nextPos)) {
      final dest = snakes[nextPos]!;
      actionMsg += ' 🐍 Kena Ular! Meluncur ke petak $dest.';
      nextPos = dest;
    }
    // Check Couple Action
    else if (coupleActions.containsKey(nextPos)) {
      actionMsg += '\n💕 Misi: ${coupleActions[nextPos]}';
    }

    setState(() {
      if (_currentTurn == 1) {
        _player1Pos = nextPos;
      } else {
        _player2Pos = nextPos;
      }
      _statusMessage = actionMsg;
      _isRolling = false;
    });

    // Check Win
    if (nextPos == totalTiles) {
      setState(() {
        _hasWon = true;
        _statusMessage = '🏆 Selamat! $activeName memenangkan Snake & Ladder!';
      });
      context.read<BondProvider>().addXp(80);
      context.read<BondProvider>().unlockAchievement('board_champions');
      _showWinDialog(activeName);
      return;
    }

    // Switch turn
    setState(() {
      _currentTurn = _currentTurn == 1 ? 2 : 1;
    });
  }

  void _showWinDialog(String winnerName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 Juara Cinta!'),
          content: Text(
            '$winnerName berhasil mencapai garis akhir!\n\nKalian mendapatkan +80 XP Bond dan lencana Juara Papan!',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _player1Pos = 1;
                  _player2Pos = 1;
                  _hasWon = false;
                  _currentTurn = 1;
                  _statusMessage = 'Game baru dimulai!';
                });
              },
              child: const Text('Main Lagi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final couple = context.watch<CoupleProvider>().profile;
    final activeName = _currentTurn == 1 ? couple.partner1 : couple.partner2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake & Ladder: Couple'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // --- SCOREBOARD ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isAfterDark ? AppColors.darkCard : AppColors.normalCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAfterDark ? AppColors.darkBorder : AppColors.normalBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Player 1
                    Row(
                      children: [
                        Text(couple.emoji1, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              couple.partner1,
                              style: TextStyle(
                                fontWeight: _currentTurn == 1 ? FontWeight.bold : FontWeight.normal,
                                color: _currentTurn == 1 ? AppColors.normalPrimary : null,
                              ),
                            ),
                            Text('Petak: $_player1Pos', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const VerticalDivider(),
                    // Player 2
                    Row(
                      children: [
                        Text(couple.emoji2, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              couple.partner2,
                              style: TextStyle(
                                fontWeight: _currentTurn == 2 ? FontWeight.bold : FontWeight.normal,
                                color: _currentTurn == 2 ? AppColors.darkAccent : null,
                              ),
                            ),
                            Text('Petak: $_player2Pos', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- 6x6 GAME BOARD ---
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAfterDark ? const Color(0xFF160B21) : const Color(0xFFFFF2F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAfterDark ? AppColors.darkBorder : AppColors.normalBorder,
                      width: 1.5,
                    ),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: totalTiles,
                    itemBuilder: (context, index) {
                      // Boustrophedon (Snake) layout 6x6
                      final row = index ~/ 6;
                      final col = index % 6;
                      final actualRow = 5 - row;
                      final actualCol = actualRow % 2 == 1 ? 5 - col : col;
                      final tileNum = actualRow * 6 + actualCol + 1;

                      final hasP1 = _player1Pos == tileNum;
                      final hasP2 = _player2Pos == tileNum;
                      final isLadder = ladders.containsKey(tileNum);
                      final isSnake = snakes.containsKey(tileNum);
                      final isAction = coupleActions.containsKey(tileNum);

                      Color tileBg = isAfterDark ? const Color(0xFF231233) : Colors.white;
                      if (tileNum == 36) {
                        tileBg = AppColors.gold.withOpacity(0.3);
                      } else if (isLadder) {
                        tileBg = Colors.green.withOpacity(0.18);
                      } else if (isSnake) {
                        tileBg = Colors.red.withOpacity(0.18);
                      } else if (isAction) {
                        tileBg = (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.2);
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: tileBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isAfterDark ? AppColors.darkBorder : AppColors.normalBorder).withOpacity(0.4),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 2,
                              left: 3,
                              child: Text(
                                '$tileNum',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isLadder)
                              const Positioned(
                                top: 2,
                                right: 2,
                                child: Text('🪜', style: TextStyle(fontSize: 10)),
                              ),
                            if (isSnake)
                              const Positioned(
                                top: 2,
                                right: 2,
                                child: Text('🐍', style: TextStyle(fontSize: 10)),
                              ),
                            if (isAction)
                              const Positioned(
                                bottom: 2,
                                right: 2,
                                child: Text('💖', style: TextStyle(fontSize: 10)),
                              ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (hasP1)
                                    Text(couple.emoji1, style: const TextStyle(fontSize: 16)),
                                  if (hasP2)
                                    Text(couple.emoji2, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --- STATUS & DICE ROLLER ---
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dice Visual Box
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isAfterDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_lastDice',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientButton(
                      text: _isRolling ? 'Mengocok...' : 'Lempar Dadu ($activeName)',
                      icon: Icons.casino_rounded,
                      onPressed: _rollDice,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}