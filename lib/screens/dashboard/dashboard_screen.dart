import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/runs_provider.dart';
import '../../providers/workouts_provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(runsProvider);
    final workouts = ref.watch(workoutsProvider);
    final username = ref.watch(usernameProvider);

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(username.isNotEmpty ? 'Hey, $username 👋' : 'FitTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await clearUsername();
              ref.read(usernameProvider.notifier).state = '';
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            () {
              final weekRuns =
                  runs.where((r) => r.date.isAfter(weekStart)).toList();
              final totalKm =
                  weekRuns.fold(0.0, (s, r) => s + r.distanceKm);
              return _WeeklyCard(
                icon: Icons.directions_run,
                label: 'Runs',
                value: weekRuns.length.toString(),
                sub: '${totalKm.toStringAsFixed(1)} km total',
                color: Colors.blue,
              );
            }(),
            const SizedBox(height: 8),
            () {
              final weekWorkouts =
                  workouts.where((w) => w.date.isAfter(weekStart)).toList();
              return _WeeklyCard(
                icon: Icons.fitness_center,
                label: 'Workouts',
                value: weekWorkouts.length.toString(),
                sub: 'sessions logged',
                color: Colors.deepOrange,
              );
            }(),
            const SizedBox(height: 24),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            () {
              final combined = [
                ...runs.map((r) => (
                      date: r.date,
                      label: '${r.distanceKm} km run',
                      icon: Icons.directions_run,
                      color: Colors.blue
                    )),
                ...workouts.map((w) => (
                      date: w.date,
                      label: w.name,
                      icon: Icons.fitness_center,
                      color: Colors.deepOrange
                    )),
              ]..sort((a, b) => b.date.compareTo(a.date));

              if (combined.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No activity yet. Log a run or workout!'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: combined.take(10).length,
                itemBuilder: (ctx, i) {
                  final item = combined[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.color.withValues(alpha: 0.15),
                      child: Icon(item.icon, color: item.color),
                    ),
                    title: Text(item.label),
                    subtitle:
                        Text(DateFormat('EEE, MMM d').format(item.date)),
                  );
                },
              );
            }(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'run',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onPressed: () => context.push('/log-run'),
            child: const Icon(Icons.directions_run),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'workout',
            onPressed: () => context.push('/log-workout'),
            child: const Icon(Icons.fitness_center),
          ),
        ],
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _WeeklyCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              radius: 28,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(sub, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
