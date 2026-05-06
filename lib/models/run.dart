class Run {
  final String id;
  final DateTime date;
  final double distanceKm;
  final int durationSeconds;
  final String? notes;

  Run({
    required this.id,
    required this.date,
    required this.distanceKm,
    required this.durationSeconds,
    this.notes,
  });

  double get paceMinPerKm =>
      distanceKm > 0 ? (durationSeconds / 60) / distanceKm : 0;

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'distanceKm': distanceKm,
        'durationSeconds': durationSeconds,
        if (notes != null) 'notes': notes,
      };

  factory Run.fromMap(Map<String, dynamic> m) => Run(
        id: m['id'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        distanceKm: (m['distanceKm'] as num).toDouble(),
        durationSeconds: m['durationSeconds'] as int,
        notes: m['notes'] as String?,
      );
}
