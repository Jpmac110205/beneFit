class Exercise {
  String name;
  List<ExerciseSet> sets;
  bool isComplete;

  Exercise({
    required this.name,
    required this.sets,
    this.isComplete = false,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      sets: (map['sets'] as List<dynamic>? ?? [])
          .map((s) => ExerciseSet.fromMap(s))
          .toList(),
      isComplete: map['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets.map((s) => s.toMap()).toList(),
      'isComplete': isComplete,
    };
  }
}

class ExerciseSet {
  int? reps;
  int? weight;
  bool isComplete;

  ExerciseSet({this.reps, this.weight, this.isComplete = false});

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      reps: map['reps'],
      weight: map['weight'] != null ? (map['weight'] as num).toInt() : null,
      isComplete: map['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
      'isComplete': isComplete,
    };
  }
}
