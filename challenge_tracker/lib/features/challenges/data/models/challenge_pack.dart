class ChallengePack {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const ChallengePack({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });

  // V1 Preset Packs
  static const noSugar30 = ChallengePack(
    id: 'no_sugar_30',
    name: 'No Sugar 30',
    description: '30 days without added sugar',
    emoji: '🍬',
  );

  static const dailyWalk30 = ChallengePack(
    id: 'daily_walk_30',
    name: 'Daily Walk 30',
    description: '30 days of daily walks',
    emoji: '🚶',
  );

  static const read10Pages30 = ChallengePack(
    id: 'read_10_pages_30',
    name: 'Read 10 Pages 30',
    description: '30 days of reading 10 pages',
    emoji: '📚',
  );

  static const List<ChallengePack> presets = [
    noSugar30,
    dailyWalk30,
    read10Pages30,
  ];

  static ChallengePack? getById(String id) {
    try {
      return presets.firstWhere((pack) => pack.id == id);
    } catch (_) {
      return null;
    }
  }
}
