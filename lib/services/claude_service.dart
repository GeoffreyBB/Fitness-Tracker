import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/run.dart';
import '../models/workout.dart';

class ClaudeService {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  final String apiKey;

  ClaudeService(this.apiKey);

  Future<String> getRecommendations({
    required List<Run> recentRuns,
    required List<Workout> recentWorkouts,
  }) async {
    final runSummary = recentRuns.map((r) {
      final pace = r.paceMinPerKm.toStringAsFixed(2);
      return '- ${r.date.toIso8601String().substring(0, 10)}: ${r.distanceKm}km in ${r.formattedDuration} ($pace min/km)';
    }).join('\n');

    final workoutSummary = recentWorkouts.map((w) {
      final exercises = w.exercises.map((e) {
        final weight = e.weightKg != null ? ' @ ${e.weightKg}kg' : '';
        return '${e.name}: ${e.sets}x${e.reps}$weight';
      }).join(', ');
      return '- ${w.date.toIso8601String().substring(0, 10)} ${w.name}: $exercises';
    }).join('\n');

    final prompt = '''You are a personal fitness coach. Based on the user's recent training history, provide 3 specific, actionable workout recommendations that build progressively on what they've done.

Recent runs (last 2 weeks):
${runSummary.isEmpty ? 'None logged' : runSummary}

Recent workouts (last 2 weeks):
${workoutSummary.isEmpty ? 'None logged' : workoutSummary}

Provide exactly 3 recommendations in this JSON format:
[
  {
    "title": "Workout name",
    "type": "run|strength|rest",
    "description": "2-3 sentence description of what to do and why it builds on previous sessions",
    "details": "Specific sets/reps/distance/duration"
  }
]

Return only the JSON array, no other text.''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-6',
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Claude API error: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['content'] as List).first['text'] as String;
  }
}
