class WorkoutSetModel {
  final String exerciseName;
  final int setNumber;
  final double weightKg;
  final int reps;

  WorkoutSetModel({
    required this.exerciseName,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
  });

  Map<String, dynamic> toJson() => {
    'exercise_name': exerciseName,
    'set_number': setNumber,
    'weight_kg': weightKg,
    'reps': reps,
  };

  factory WorkoutSetModel.fromJson(Map<String, dynamic> json) => WorkoutSetModel(
    exerciseName: json['exercise_name'] ?? '',
    setNumber: json['set_number'] ?? 1,
    weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
    reps: json['reps'] ?? 0,
  );
}

class WorkoutSessionModel {
  final int id;
  final String date;
  final String dayName;
  final String routineFocus;
  final String? photoPath;
  final String? notes;
  final List<WorkoutSetModel> sets;

  WorkoutSessionModel({
    required this.id,
    required this.date,
    required this.dayName,
    required this.routineFocus,
    this.photoPath,
    this.notes,
    required this.sets,
  });

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      routineFocus: json['routine_focus'] ?? '',
      photoPath: json['photo_path'],
      notes: json['notes'],
      sets: (json['sets'] as List? ?? [])
          .map((s) => WorkoutSetModel.fromJson(s))
          .toList(),
    );
  }
}
