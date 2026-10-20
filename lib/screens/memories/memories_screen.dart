import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/memory_item.dart';
import '../../providers/app_provider.dart';
import '../../providers/memories_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/gradient_button.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final memories = context.watch<MemoriesProvider>().memories;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Our Memories'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemoryDialog(context),
        backgroundColor: isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary,
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
        label: const Text('Tambah Kenangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: memories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📸', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada kenangan tersimpan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Abadikan momen manis pertama kalian sekarang.'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: memories.length + 1,
                itemBuilder: (context, index) {
                  if (index == memories.length) {
                    return const SizedBox(height: 80); // padding for FAB
                  }

                  final item = memories[index];
                  final formattedDate = DateFormat('dd MMMM yyyy').format(item.date);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CustomCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(item.emoji, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: item.isFavorite ? AppColors.loveRed : null,
                                  size: 20,
                                ),
                                onPressed: () {
                                  context.read<MemoriesProvider>().toggleFavorite(item.id);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.note,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              InkWell(
                                onTap: () {
                                  context.read<MemoriesProvider>().deleteMemory(item.id);
                                },
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(fontSize: 12, color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showAddMemoryDialog(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCategory = 'Romance';
    String selectedEmoji = '📸';

    final categories = ['Romance', 'First Date', 'Travel', 'Anniversary', 'Funny Moment'];
    final emojis = ['📸', '☕', '🌅', '✈️', '🥂', '💖', '🍿', '🌹'];

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simpan Kenangan Baru',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Emojis row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: emojis.map((em) {
                          final isSel = selectedEmoji == em;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedEmoji = em),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSel
                                    ? (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withValues(alpha: 0.2)
                                    : Colors.transparent,
                                border: isSel
                                    ? Border.all(color: isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary)
                                    : null,
                              ),
                              child: Text(em, style: const TextStyle(fontSize: 20)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Categories chip selector
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSel = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSel,
                              onSelected: (_) => setModalState(() => selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Kenangan',
                        border: OutlineInputBorder(),
                        hintText: 'Misal: Makan malam di bawah bintang...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Cerita Singkat',
                        border: OutlineInputBorder(),
                        hintText: 'Apa yang membuat momen ini begitu spesial?',
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: 'Simpan ke Album 💕',
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;

                          final newMem = MemoryItem(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            note: noteController.text.trim(),
                            date: DateTime.now(),
                            category: selectedCategory,
                            emoji: selectedEmoji,
                          );

                          context.read<MemoriesProvider>().addMemory(newMem);
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}