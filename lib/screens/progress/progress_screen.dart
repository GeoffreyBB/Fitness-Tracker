import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/run.dart';
import '../../models/workout.dart';
import '../../providers/runs_provider.dart';
import '../../providers/workouts_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.directions_run), text: 'Running'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Workouts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _RunsProgress(runs: ref.watch(runsProvider)),
          _WorkoutsProgress(workouts: ref.watch(workoutsProvider)),
        ],
      ),
    );
  }
}

class _RunsProgress extends StatelessWidget {
  final List<Run> runs;
  const _RunsProgress({required this.runs});

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) {
      return const Center(child: Text('No runs logged yet.'));
    }

    final sorted = [...runs]..sort((a, b) => a.date.compareTo(b.date));
    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.distanceKm);
    }).toList();

    final totalKm = runs.fold(0.0, (s, r) => s + r.distanceKm);
    final avgPace = runs.fold(0.0, (s, r) => s + r.paceMinPerKm) / runs.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatChip(label: 'Total Runs', value: runs.length.toString()),
              const SizedBox(width: 8),
              _StatChip(label: 'Total km', value: totalKm.toStringAsFixed(1)),
              const SizedBox(width: 8),
              _StatChip(label: 'Avg pace', value: '${avgPace.toStringAsFixed(1)} /km'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Distance over time',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) =>
                          Text('${v.toStringAsFixed(0)}km',
                              style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= sorted.length) return const SizedBox.shrink();
                        return Text(
                          DateFormat('M/d').format(sorted[i].date),
                          style: const TextStyle(fontSize: 9),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Run History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...sorted.reversed.take(20).map((r) => ListTile(
                leading: const Icon(Icons.directions_run, color: Colors.blue),
                title: Text('${r.distanceKm} km'),
                subtitle: Text(DateFormat('EEE, MMM d').format(r.date)),
                trailing: Text(
                  r.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )),
        ],
      ),
    );
  }
}

class _WorkoutsProgress extends StatelessWidget {
  final List<Workout> workouts;
  const _WorkoutsProgress({required this.workouts});

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const Center(child: Text('No workouts logged yet.'));
    }

    final sorted = [...workouts]..sort((a, b) => a.date.compareTo(b.date));
    final volumeSpots = sorted.asMap().entries.map((e) {
      final volume = e.value.exercises.fold<double>(
        0,
        (s, ex) => s + (ex.sets * ex.reps * (ex.weightKg ?? 1)),
      );
      return FlSpot(e.key.toDouble(), volume);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatChip(
              label: 'Total Sessions', value: workouts.length.toString()),
          const SizedBox(height: 24),
          Text('Volume over time',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('(sets × reps × weight)',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                barGroups: volumeSpots
                    .map((s) => BarChartGroupData(
                          x: s.x.toInt(),
                          barRods: [
                            BarChartRodData(
                              toY: s.y,
                              color: Colors.deepOrange,
                              width: 12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ))
                    .toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= sorted.length) return const SizedBox.shrink();
                        return Text(
                          DateFormat('M/d').format(sorted[i].date),
                          style: const TextStyle(fontSize: 9),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Workout History',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...sorted.reversed.take(20).map((w) => ExpansionTile(
                leading: const Icon(Icons.fitness_center,
                    color: Colors.deepOrange),
                title: Text(w.name),
                subtitle: Text(DateFormat('EEE, MMM d').format(w.date)),
                children: w.exercises
                    .map((e) => ListTile(
                          dense: true,
                          title: Text(e.name),
                          trailing: Text(
                            e.weightKg != null
                                ? '${e.sets}×${e.reps} @ ${e.weightKg}kg'
                                : '${e.sets}×${e.reps}',
                          ),
                        ))
                    .toList(),
              )),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
