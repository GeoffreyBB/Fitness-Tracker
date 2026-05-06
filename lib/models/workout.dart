import 'exercise.dart';

class Workout {
  final String id;
  final DateTime date;
  final String name;
  final List<Exercise> exercises;
  final String? notes;

  Workout({
    required this.id,
    required this.date,
    required this.name,
    required this.exercises,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'name': name,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        if (notes != null) 'notes': notes,
      };

  factory Workout.fromMap(Map<String, dynamic> m) => Workout(
        id: m['id'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        name: m['name'] as String,
        exercises: (m['exercises'] as List<dynamic>)
            .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        notes: m['notes'] as String?,
      );
}
