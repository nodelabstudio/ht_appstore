import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'features/challenges/presentation/notifiers/challenge_list_notifier.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/challenges/data/services/hive_service.dart';
import 'features/challenges/presentation/screens/challenge_detail_screen.dart';
import 'features/challenges/presentation/screens/home_screen.dart';
import 'features/monetization/data/services/revenue_cat_service.dart';
import 'features/notifications/data/services/notification_service.dart';
import 'features/widgets/data/services/widget_data_service.dart';

/// Global navigator key for deep link navigation from widget taps.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize timezone database
  tz.initializeTimeZones();

  // Initialize HiveService (registers adapters)
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize NotificationService
  await NotificationService().init();

  // Initialize RevenueCat SDK
  await RevenueCatService().init();

  // Initialize WidgetDataService for home screen widget
  await WidgetDataService().init();

  runApp(
    const ProviderScope(
      child: ChallengeTrackerApp(),
    ),
  );
}

class ChallengeTrackerApp extends ConsumerStatefulWidget {
  const ChallengeTrackerApp({super.key});

  @override
  ConsumerState<ChallengeTrackerApp> createState() => _ChallengeTrackerAppState();
}

class _ChallengeTrackerAppState extends ConsumerState<ChallengeTrackerApp> {
  Uri? _initialUri;
  bool _initialUriHandled = false;

  @override
  void initState() {
    super.initState();
    _handleWidgetLaunch();
    _listenForWidgetClicks();
  }

  /// Check if the app was initially launched from a home screen widget tap.
  /// Stores the URI to be handled by the build method once data is loaded.
  Future<void> _handleWidgetLaunch() async {
    final launchUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (launchUri != null) {
      setState(() {
        _initialUri = launchUri;
      });
    }
  }

  /// Listen for widget tap events while the app is running.
  void _listenForWidgetClicks() {
    HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        _navigateFromWidgetUri(uri);
      }
    });
  }

  /// Parse widget deep link URI and navigate to the appropriate screen.
  /// Expected format: challengetracker://challenge/{id}
  void _navigateFromWidgetUri(Uri uri) {
    if (uri.scheme == 'challengetracker' && uri.host == 'challenge') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty && pathSegments.first.isNotEmpty) {
        final challengeId = pathSegments.first;
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challengeId: challengeId),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    // Use ref.listen to handle the one-time navigation event when data loads.
    // This is the correct way to trigger side-effects in response to state changes.
    ref.listen(challengeListProvider, (previous, next) {
      // Only handle initial URI once, and only when challenges are first loaded.
      if (_initialUri != null && !_initialUriHandled && next.hasValue) {
        _navigateFromWidgetUri(_initialUri!);
        _initialUriHandled = true;
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '30-Day Challenge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
