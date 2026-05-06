import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/run.dart';

const _boxName = 'runs';

class RunsNotifier extends StateNotifier<List<Run>> {
  RunsNotifier() : super([]) {
    _load();
  }

  void _load() {
    final box = Hive.box(_boxName);
    state = box.values
        .map((v) => Run.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addRun(Run run) async {
    await Hive.box(_boxName).put(run.id, run.toMap());
    _load();
  }

  Future<void> deleteRun(String id) async {
    await Hive.box(_boxName).delete(id);
    _load();
  }
}

final runsProvider =
    StateNotifierProvider<RunsNotifier, List<Run>>((_) => RunsNotifier());
