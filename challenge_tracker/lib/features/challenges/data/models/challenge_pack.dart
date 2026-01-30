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

  static const read10Pages30 = ChallengePack(
    id: 'read_10_pages_30',
    name: 'Read 10 Pages 30',
    description: '30 days of reading 10 pages',
    emoji: '📚',
  );

  static const digitalDetox30 = ChallengePack(
    id: 'digital_detox_30',
    name: 'Digital Detox 30',
    description: '30 days without social media before bed',
    emoji: '📱🚫',
  );

  static const morningMeditation30 = ChallengePack(
    id: 'morning_meditation_30',
    name: 'Morning Meditation 30',
    description: '30 days of 5-minute morning meditation',
    emoji: '🧘‍♀️',
  );

  static const sketchADay30 = ChallengePack(
    id: 'sketch_a_day_30',
    name: 'Sketch a Day 30',
    description: '30 days of creating a small sketch',
    emoji: '✏️',
  );

  static const noAlcohol30 = ChallengePack(
    id: 'no_alcohol_30',
    name: 'No Alcohol 30',
    description: '30 days of no alcohol consumption',
    emoji: '🍷🚫',
  );

  static const journaling30 = ChallengePack(
    id: 'journaling_30',
    name: 'Journaling 30',
    description: '30 days of writing a journal entry',
    emoji: '✍️',
  );

  static const jogging30 = ChallengePack(
    id: 'jogging_30',
    name: 'Jogging 30',
    description: '30 days of daily jogging',
    emoji: '🏃‍♂️',
  );

  static const praying30 = ChallengePack(
    id: 'praying_30',
    name: 'Praying 30',
    description: '30 days of daily prayer',
    emoji: '🙏',
  );

  static const abstinence30 = ChallengePack(
    id: 'abstinence_30',
    name: 'Abstinence 30',
    description: '30 days of abstinence',
    emoji: '🚫❤️',
  );

  static const List<ChallengePack> presets = [
    noSugar30,
    dailyWalk30,
    read10Pages30,
    digitalDetox30,
    morningMeditation30,
    sketchADay30,
    noAlcohol30,
    journaling30,
    jogging30,
    praying30,
    abstinence30,
  ];

  static ChallengePack? getById(String id) {
    try {
      return presets.firstWhere((pack) => pack.id == id);
    } catch (_) {
      return null;
    }
  }
}


  static ChallengePack? getById(String id) {
    try {
      return presets.firstWhere((pack) => pack.id == id);
    } catch (_) {
      return null;
    }
  }
}
