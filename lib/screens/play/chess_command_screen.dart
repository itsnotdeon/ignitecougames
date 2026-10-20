import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';

class ChessCommandScreen extends StatefulWidget {
  const ChessCommandScreen({super.key});

  @override
  State<ChessCommandScreen> createState() => _ChessCommandScreenState();
}

class _ChessCommandScreenState extends State<ChessCommandScreen> {
  static const List<String> _initial = [
    '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
    '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
    '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '',
    '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
    '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖',
  ];

  late List<String> _board;
  int? _selected;
  bool _whiteTurn = true;
  bool _consent = false;
  String? _command;
  final List<List<String>> _history = <List<String>>[];
  final List<bool> _turnHistory = <bool>[];
  final Random _random = Random();

  final List<String> _commands = [
    'Ambil satu apresiasi dari pasangan dan ucapkan dengan tulus.',
    'Pilih tantangan obrolan ringan untuk lawan.',
    'Ceritakan satu hal yang ingin kalian lakukan bersama.',
    'Berikan lawan kesempatan memilih topik obrolan berikutnya.',
  ];

  @override
  void initState() {
    super.initState();
    _board = List<String>.from(_initial);
  }

  bool _isWhite(String piece) => '♙♖♘♗♕♔'.contains(piece) && piece.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final primary = dark ? AppColors.darkAccent : AppColors.normalPrimary;
    final muted = dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final foreground = dark ? AppColors.darkText : AppColors.normalText;
    final surface = dark ? AppColors.darkCard : AppColors.normalCard;
    final activeColor = _whiteTurn
        ? (dark ? AppColors.darkPrimary : AppColors.normalPrimary)
        : (dark ? AppColors.darkSecondary : AppColors.normalSecondary);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Chess & Command')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Satu langkah, satu kejutan.', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Bergiliran di papan dan buka Command Card saat bidak lawan tertangkap. Sepakati batas permainan terlebih dahulu.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: dark ? AppColors.darkBorder : AppColors.normalBorder),
                      ),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _consent,
                        activeColor: primary,
                        onChanged: (value) => setState(() {
                          _consent = value ?? false;
                          if (!_consent) _selected = null;
                        }),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Kami berdua setuju dengan aturan dan batas permainan.'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? const [Color(0xFF342039), Color(0xFF1A101F)]
                              : const [Color(0xFFFFE5EB), Color(0xFFFFF5EC)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: dark ? AppColors.darkBorder : AppColors.normalBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.grid_view_rounded, color: primary, size: 18),
                              const SizedBox(width: 8),
                              Text('PAPAN PERMAINAN', style: TextStyle(color: primary, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                              const Spacer(),
                              Text('64 petak', style: TextStyle(color: muted, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                                    itemCount: 64,
                                    itemBuilder: (context, index) {
                                      final row = index ~/ 8;
                                      final col = index % 8;
                                      final light = (row + col).isEven;
                                      final picked = _selected == index;
                                      final piece = _board[index];
                                      final isWhite = _isWhite(piece);
                                      final squareColor = picked
                                          ? primary
                                          : light
                                              ? (dark ? const Color(0xFF60465A) : const Color(0xFFFFE7DA))
                                              : (dark ? const Color(0xFF2B1A2C) : const Color(0xFF9B718A));
                                      return Semantics(
                                        button: true,
                                        label: 'Petak baris ${row + 1}, kolom ${col + 1}${piece.isEmpty ? ', kosong' : ', bidak $piece'}',
                                        child: GestureDetector(
                                          onTap: !_consent ? null : () => setState(() => _tap(index)),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 130),
                                            decoration: BoxDecoration(
                                              color: squareColor,
                                              border: Border.all(color: primary.withValues(alpha: picked ? 0.95 : 0.08), width: picked ? 2 : 0.5),
                                            ),
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                piece,
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  color: piece.isEmpty ? Colors.transparent : isWhite ? const Color(0xFFFFF8F0) : const Color(0xFF261724),
                                                  shadows: const [Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1))],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: activeColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: activeColor, size: 12),
                                const SizedBox(width: 10),
                                Expanded(child: Text('Giliran ${_whiteTurn ? 'Putih' : 'Hitam'}', style: TextStyle(color: foreground, fontWeight: FontWeight.w700))),
                                Text('${_history.length} langkah', style: TextStyle(color: muted, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_command != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: dark ? const [Color(0xFF442038), Color(0xFF211326)] : const [Color(0xFFFFDDE5), Color(0xFFFFEEF0)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: primary.withValues(alpha: 0.28)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Icon(Icons.auto_awesome_rounded, color: primary), const SizedBox(width: 8), Text('COMMAND CARD', style: TextStyle(color: primary, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w800))]),
                            const SizedBox(height: 10),
                            Text(_command!, style: TextStyle(color: foreground, fontSize: 17, height: 1.45, fontWeight: FontWeight.w600)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => setState(() => _command = null),
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Selesai'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _history.isEmpty ? null : () => setState(() {
                            _board = List<String>.from(_history.removeLast());
                            _whiteTurn = _turnHistory.removeLast();
                            _selected = null;
                            _command = null;
                          }),
                          icon: const Icon(Icons.undo_rounded),
                          label: const Text('Urungkan'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _board = List<String>.from(_initial);
                            _history.clear();
                            _turnHistory.clear();
                            _selected = null;
                            _whiteTurn = true;
                            _command = null;
                          }),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reset papan'),
                        ),
                        FilledButton.icon(
                          onPressed: !_consent ? null : () => setState(() => _command = _commands[_random.nextInt(_commands.length)]),
                          icon: const Icon(Icons.style_rounded),
                          label: const Text('Ambil Command Card'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Catatan: versi ini menggunakan gerakan papan sederhana dan belum memvalidasi seluruh aturan catur resmi. Command Card hanya pemantik interaksi yang boleh dilewati.',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tap(int index) {
    if (_selected == null) {
      if (_board[index].isNotEmpty && _isWhite(_board[index]) == _whiteTurn) {
        _selected = index;
      }
      return;
    }
    if (_selected == index) {
      _selected = null;
      return;
    }
    if (_board[index].isNotEmpty && _isWhite(_board[index]) == _whiteTurn) {
      _selected = index;
      return;
    }

    _history.add(List<String>.from(_board));
    _turnHistory.add(_whiteTurn);
    final captured = _board[index].isNotEmpty;
    _board[index] = _board[_selected!];
    _board[_selected!] = '';
    _selected = null;
    _whiteTurn = !_whiteTurn;
    if (captured) {
      _command = _commands[_random.nextInt(_commands.length)];
    }
  }
}
