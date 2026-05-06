import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';

const _boxName = 'workouts';

class WorkoutsNotifier extends StateNotifier<List<Workout>> {
  WorkoutsNotifier() : super([]) {
    _load();
  }

  void _load() {
    final box = Hive.box(_boxName);
    state = box.values
        .map((v) => Workout.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addWorkout(Workout workout) async {
    await Hive.box(_boxName).put(workout.id, workout.toMap());
    _load();
  }

  Future<void> deleteWorkout(String id) async {
    await Hive.box(_boxName).delete(id);
    _load();
  }
}

final workoutsProvider =
    StateNotifierProvider<WorkoutsNotifier, List<Workout>>(
        (_) => WorkoutsNotifier());
