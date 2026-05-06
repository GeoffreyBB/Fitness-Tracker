import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/exercise.dart';
import '../../models/workout.dart';
import '../../providers/workouts_provider.dart';

class LogWorkoutScreen extends ConsumerStatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  ConsumerState<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends ConsumerState<LogWorkoutScreen> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final List<_ExerciseEntry> _exercises = [];
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _addExercise() {
    setState(() => _exercises.add(_ExerciseEntry()));
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Workout name required')));
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one exercise')));
      return;
    }

    final exercises = _exercises
        .where((e) => e.nameCtrl.text.isNotEmpty)
        .map((e) => Exercise(
              name: e.nameCtrl.text,
              sets: int.tryParse(e.setsCtrl.text) ?? 0,
              reps: int.tryParse(e.repsCtrl.text) ?? 0,
              weightKg: double.tryParse(e.weightCtrl.text),
            ))
        .toList();

    setState(() => _saving = true);
    final workout = Workout(
      id: const Uuid().v4(),
      date: _date,
      name: _nameCtrl.text,
      exercises: exercises,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );

    await ref.read(workoutsProvider.notifier).addWorkout(workout);
    if (mounted) context.pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Workout Name',
              hintText: 'e.g. Upper Body, Leg Day',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Exercises',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          ..._exercises.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return _ExerciseForm(
              entry: e,
              onRemove: () => setState(() => _exercises.removeAt(i)),
            );
          }),
          const SizedBox(height: 16),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const CircularProgressIndicator()
                : const Text('Save Workout'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseEntry {
  final nameCtrl = TextEditingController();
  final setsCtrl = TextEditingController();
  final repsCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
}

class _ExerciseForm extends StatelessWidget {
  final _ExerciseEntry entry;
  final VoidCallback onRemove;

  const _ExerciseForm({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Exercise',
                      hintText: 'e.g. Bench Press',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.setsCtrl,
                    decoration: const InputDecoration(labelText: 'Sets'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: entry.repsCtrl,
                    decoration: const InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: entry.weightCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      hintText: 'optional',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
