import 'package:game/screens/auth/home/views/workoutTracker/workout_tracker.dart';
import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/workoutTracker/lift_stored.dart';
import 'exercise.dart';

class CreateNewWorkout extends StatefulWidget {
  const CreateNewWorkout({super.key});

  @override
  State<CreateNewWorkout> createState() => _CreateNewWorkoutState();
}

class _CreateNewWorkoutState extends State<CreateNewWorkout> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Exercise> exercises = [];
  List<String> filteredExercises = List.from(commonGymLifts);
  final TextEditingController _searchController = TextEditingController();

  void _filterExercises(String query) {
    setState(() {
      filteredExercises = commonGymLifts
          .where((exercise) => exercise.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addExercise(String exerciseName) {
    if (exercises.any((e) => e.name == exerciseName)) return;

    setState(() {
      exercises.add(Exercise(name: exerciseName, sets: [ExerciseSet()]));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      exercises[exerciseIndex].sets.add(ExerciseSet());
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      if (exercises[exerciseIndex].sets.length > 1) {
        exercises[exerciseIndex].sets.removeAt(setIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Workout'),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout name input
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Workout Name',
                    labelStyle: textTheme.bodyMedium,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),

                // Workout description input
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Workout Description',
                    labelStyle: textTheme.bodyMedium,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),

                // Search bar for exercises
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Exercises',
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.7)),
                    labelStyle: textTheme.bodyMedium,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  style: textTheme.bodyLarge,
                  onChanged: _filterExercises,
                ),
                const SizedBox(height: 10),

                // List of filtered exercises to add
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exerciseName = filteredExercises[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            side: BorderSide(color: colorScheme.primary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(exerciseName, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                          onPressed: () {
                            _addExercise(exerciseName);
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // List of added exercises with editable sets
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exercises.length,
                  itemBuilder: (context, exerciseIndex) {
                    final exercise = exercises[exerciseIndex];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Exercise title with delete button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  exercise.name,
                                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: colorScheme.error),
                                  onPressed: () => _removeExercise(exerciseIndex),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // List of sets
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: exercise.sets.length,
                              itemBuilder: (context, setIndex) {
                                final set = exercise.sets[setIndex];
                                return Row(
                                  children: [
                                    // Reps input
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: set.reps?.toString() ?? '',
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Reps',
                                          labelStyle: textTheme.bodyMedium,
                                          border: const OutlineInputBorder(),
                                        ),
                                        style: textTheme.bodyLarge,
                                        onChanged: (val) {
                                          final reps = int.tryParse(val) ?? set.reps;
                                          setState(() {
                                            set.reps = reps;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Weight input
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: set.weight?.toString() ?? '',
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: 'Weight',
                                          suffixText: 'lbs',
                                          labelStyle: textTheme.bodyMedium,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                                          ),
                                        ),
                                        style: textTheme.bodyLarge,
                                        onChanged: (val) {
                                          final weight = int.tryParse(val) ?? set.weight;
                                          setState(() {
                                            set.weight = weight;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Remove set button (only if more than 1 set)
                                    if (exercise.sets.length > 1)
                                      IconButton(
                                        icon: Icon(Icons.delete, color: colorScheme.error),
                                        onPressed: () => _removeSet(exerciseIndex, setIndex),
                                      ),
                                    const SizedBox(height: 65),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            // Add set button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: Icon(Icons.add, color: colorScheme.primary),
                                label: Text('Add Set', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                                onPressed: () {
                                  _addSet(exerciseIndex);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      side: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    child: Text('Save Workout', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                    onPressed: () {
                      WorkoutStats workoutToReturn = WorkoutStats(
                        name: _nameController.text,
                        description: _descriptionController.text,
                        timesCompleted: 0,
                        daysSinceLast: 0,
                        exercises: exercises,
                      );
                      Navigator.of(context).pop(workoutToReturn);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
