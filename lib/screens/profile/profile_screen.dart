import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/gradient_button.dart';
import 'data_tools_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final couple = context.watch<CoupleProvider>().profile;
    final formattedAnniversary = DateFormat('dd MMMM yyyy').format(couple.anniversaryDate);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            // --- COUPLE PROFILE CARD ---
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAvatarCircle(context, couple.emoji1, couple.partner1),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('💞', style: TextStyle(fontSize: 26)),
                      ),
                      _buildAvatarCircle(context, couple.emoji2, couple.partner2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    couple.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Anniversary: $formattedAnniversary',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Edit Data Pasangan',
                    icon: Icons.edit_rounded,
                    isSecondary: true,
                    height: 40,
                    onPressed: () => _showEditProfileDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- VISUAL THEME SELECTION (NORMAL vs AFTER DARK) ---
            Text(
              'Mode Visual',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // Normal Mode Card
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => context.read<AppProvider>().setAfterDark(false),
                    border: Border.all(
                      color: !isAfterDark ? AppColors.normalPrimary : Colors.transparent,
                      width: 2,
                    ),
                    backgroundColor: Colors.white,
                    child: Column(
                      children: [
                        const Text('🌸', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        const Text(
                          'Normal Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF381E24),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Warm blush, rose & champagne',
                          style: TextStyle(fontSize: 11, color: Color(0xFF85626A)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (!isAfterDark)
                          const Icon(Icons.check_circle_rounded, color: AppColors.normalPrimary, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // After Dark Mode Card
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => context.read<AppProvider>().setAfterDark(true),
                    border: Border.all(
                      color: isAfterDark ? AppColors.darkPrimary : Colors.transparent,
                      width: 2,
                    ),
                    backgroundColor: const Color(0xFF1B0B24),
                    child: Column(
                      children: [
                        const Text('🌙', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        const Text(
                          'After Dark',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFFCE7EE),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Intimate wine, plum & obsidian',
                          style: TextStyle(fontSize: 11, color: Color(0xFFA58D9E)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (isAfterDark)
                          const Icon(Icons.check_circle_rounded, color: AppColors.darkAccent, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // --- APP SETTINGS & INFO ---
            Text(
              'Pengaturan & Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            const CustomCard(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.security_rounded),
                    title: Text('Local-First Data'),
                    subtitle: Text('Data profil & kenangan aman di HP Anda'),
                    trailing: Icon(Icons.lock_outline_rounded, size: 18),
                  ),
                  Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('Tentang IGNITE'),
                    subtitle: Text('Versi 1.0.0 (Flutter Android)'),
                  ),
                ],
              ),
            ),

            CustomCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataToolsScreen())),
              padding: const EdgeInsets.all(16),
              child: const Row(children: [
                Icon(Icons.backup_rounded),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Data & Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Ekspor, pulihkan, atau reset data lokal IGNITE.'),
                ])),
                Icon(Icons.chevron_right_rounded),
              ]),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(BuildContext context, String emoji, String name) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: AppColors.normalPrimary, width: 1.5),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final couple = context.read<CoupleProvider>().profile;
    final p1Controller = TextEditingController(text: couple.partner1);
    final p2Controller = TextEditingController(text: couple.partner2);
    DateTime selectedDate = couple.anniversaryDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isAfterDark = ctx.watch<AppProvider>().isAfterDark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isAfterDark ? AppColors.darkCard : AppColors.normalSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Profil Pasangan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: p1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pasangan 1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: p2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pasangan 2',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Jadian / Anniversary', style: TextStyle(fontSize: 12)),
                          Text(
                            DateFormat('dd MMMM yyyy').format(selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: const Text('Pilih'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: 'Simpan Perubahan',
                      onPressed: () {
                        context.read<CoupleProvider>().updateProfile(
                          partner1: p1Controller.text.trim(),
                          partner2: p2Controller.text.trim(),
                          anniversaryDate: selectedDate,
                        );
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}