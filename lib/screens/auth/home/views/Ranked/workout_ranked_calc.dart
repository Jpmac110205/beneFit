
double oneRepMaxCalculator(double weight, int reps) {
  if (reps <= 0) return 0.0;
  return weight * (1 + (reps / 30));
}

String getRank(double normalizedScore, String exercise) {
  // You can customize per exercise if needed
  if (normalizedScore > 1.8) return 'Master';
  if (normalizedScore > 1.6) return 'Diamond';
  if (normalizedScore > 1.4) return 'Platinum';
  if (normalizedScore > 1.2) return 'Gold';
  if (normalizedScore > 1.0) return 'Silver';
  return 'Bronze';
}

int getPercentile(double normalizedScore) {
  if (normalizedScore > 1.8) return 5;
  if (normalizedScore > 1.6) return 10;
  if (normalizedScore > 1.4) return 25;
  if (normalizedScore > 1.2) return 50;
  if (normalizedScore > 1.0) return 75;
  return 90;
}
Map<String, dynamic> evaluateRank({
  required int liftWeight,
  required int reps,
  required double bodyweight,
  required String exercise,
}) {
  final oneRepMax = oneRepMaxCalculator(liftWeight.toDouble(), reps);
  final normalized = strengthScore(oneRepMax, bodyweight, exercise);
  final rank = getRank(normalized, exercise);
  final percentile = getPercentile(normalized);
  if (exercise == 'Pull-Up') {
  liftWeight = bodyweight.toInt();
}

  return {
    'oneRepMax': oneRepMax,
    'normalizedScore': normalized,
    'rank': rank,
    'percentile': percentile,
  };
}

double strengthScore(double oneRepMax, double bodyweight, String exercise) {
  final gold = goldStandards[exercise] ?? 1.0;
  final expectedMax = bodyweight * gold;
  return oneRepMax / expectedMax;
}

final Map<String, double> goldStandards = {
  'Bench Press': 0.8,
  'Squat': 1.3,
  'Deadlift': 1.8,
  'Overhead Press': 0.6,
  'Pull-Up': 1.0, 
};