class Exercise {
  final String name;
  final int sets;
  final int reps;
  final double? weightKg;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weightKg,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        if (weightKg != null) 'weightKg': weightKg,
      };

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        name: m['name'] as String,
        sets: m['sets'] as int,
        reps: m['reps'] as int,
        weightKg: (m['weightKg'] as num?)?.toDouble(),
      );
}
