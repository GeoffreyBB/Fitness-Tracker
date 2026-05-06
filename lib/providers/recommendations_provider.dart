import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/claude_service.dart';
import '../models/run.dart';
import '../models/workout.dart';

const _apiKeyPrefKey = 'claude_api_key';

final claudeApiKeyProvider = StateProvider<String>((ref) => '');

final claudeServiceProvider = Provider<ClaudeService?>((ref) {
  final key = ref.watch(claudeApiKeyProvider);
  if (key.isEmpty) return null;
  return ClaudeService(key);
});

class Recommendation {
  final String title;
  final String type;
  final String description;
  final String details;

  Recommendation({
    required this.title,
    required this.type,
    required this.description,
    required this.details,
  });

  factory Recommendation.fromJson(Map<String, dynamic> j) => Recommendation(
        title: j['title'] as String,
        type: j['type'] as String,
        description: j['description'] as String,
        details: j['details'] as String,
      );
}

class RecommendationsNotifier
    extends AsyncNotifier<List<Recommendation>> {
  @override
  Future<List<Recommendation>> build() async => [];

  Future<void> fetch({
    required List<Run> runs,
    required List<Workout> workouts,
  }) async {
    final service = ref.read(claudeServiceProvider);
    if (service == null) {
      state = const AsyncValue.error('No API key set', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final cutoff = DateTime.now().subtract(const Duration(days: 14));
      final recentRuns = runs.where((r) => r.date.isAfter(cutoff)).toList();
      final recentWorkouts =
          workouts.where((w) => w.date.isAfter(cutoff)).toList();

      final json = await service.getRecommendations(
        recentRuns: recentRuns,
        recentWorkouts: recentWorkouts,
      );
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}

final recommendationsProvider =
    AsyncNotifierProvider<RecommendationsNotifier, List<Recommendation>>(
        RecommendationsNotifier.new);

Future<void> saveApiKey(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_apiKeyPrefKey, key);
}

Future<String> loadApiKey() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_apiKeyPrefKey) ?? '';
}
