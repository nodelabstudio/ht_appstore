import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'features/challenges/data/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize timezone database
  tz.initializeTimeZones();

  // Initialize HiveService (registers adapters)
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    const ProviderScope(
      child: ChallengeTrackerApp(),
    ),
  );
}

class ChallengeTrackerApp extends StatelessWidget {
  const ChallengeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '30-Day Challenge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Challenge Tracker')),
      ),
    );
  }
}
