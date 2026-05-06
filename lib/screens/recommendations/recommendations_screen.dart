import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/runs_provider.dart';
import '../../providers/workouts_provider.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsProvider);
    final apiKey = ref.watch(claudeApiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            onPressed: () => _showApiKeyDialog(context, ref, apiKey),
          ),
        ],
      ),
      body: recsAsync.when(
        data: (recs) {
          if (recs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.smart_toy_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      apiKey.isEmpty
                          ? 'Set your Claude API key to get recommendations'
                          : 'Tap the button below to generate recommendations based on your recent training',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recs.length,
            itemBuilder: (ctx, i) => _RecommendationCard(rec: recs[i]),
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing your training...'),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _fetchRecommendations(ref),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Get Recommendations'),
      ),
    );
  }

  void _fetchRecommendations(WidgetRef ref) {
    final runs = ref.read(runsProvider);
    final workouts = ref.read(workoutsProvider);
    ref.read(recommendationsProvider.notifier).fetch(
          runs: runs,
          workouts: workouts,
        );
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Claude API Key'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: 'sk-ant-...',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final key = ctrl.text.trim();
              ref.read(claudeApiKeyProvider.notifier).state = key;
              await saveApiKey(key);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;
  const _RecommendationCard({required this.rec});

  IconData get _icon => switch (rec.type) {
        'run' => Icons.directions_run,
        'rest' => Icons.bedtime,
        _ => Icons.fitness_center,
      };

  Color get _color => switch (rec.type) {
        'run' => Colors.blue,
        'rest' => Colors.green,
        _ => Colors.deepOrange,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _color.withValues(alpha: 0.15),
                  child: Icon(_icon, color: _color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rec.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(rec.description),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.checklist, size: 16, color: _color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec.details,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
