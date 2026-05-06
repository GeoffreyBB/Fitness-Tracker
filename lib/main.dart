import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/recommendations_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('runs');
  await Hive.openBox('workouts');
  runApp(const ProviderScope(child: FitTrackApp()));
}

class FitTrackApp extends ConsumerStatefulWidget {
  const FitTrackApp({super.key});

  @override
  ConsumerState<FitTrackApp> createState() => _FitTrackAppState();
}

class _FitTrackAppState extends ConsumerState<FitTrackApp> {
  late final _router = buildRouter(ref);

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    final username = await loadUsername();
    if (username.isNotEmpty) {
      ref.read(usernameProvider.notifier).state = username;
    }
    final apiKey = await loadApiKey();
    if (apiKey.isNotEmpty) {
      ref.read(claudeApiKeyProvider.notifier).state = apiKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FitTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
