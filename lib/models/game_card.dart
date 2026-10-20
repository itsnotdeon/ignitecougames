enum CardType { truth, dare }
enum CardCategory { romantic, deep, spicy }

class GameCard {
  final String id;
  final CardType type;
  final CardCategory category;
  final String text;
  final int xpReward;
  final bool isAfterDark;

  const GameCard({
    required this.id,
    required this.type,
    required this.category,
    required this.text,
    this.xpReward = 15,
    this.isAfterDark = false,
  });
}