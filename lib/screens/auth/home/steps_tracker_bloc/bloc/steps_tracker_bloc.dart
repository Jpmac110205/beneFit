import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/screens/auth/home/steps_tracker_bloc/bloc/steps_tracker_event.dart';
import 'package:game/screens/auth/home/steps_tracker_bloc/bloc/steps_tracker_state.dart';
import 'package:health/health.dart';

int extractSteps(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  try {
    final numValue = (val as dynamic).numericValue;
    if (numValue is num) return numValue.toInt();
  } catch (_) {}
  return 0;
}

class StepBloc extends Bloc<StepEvent, StepState> {
  final Health health = Health();

  StepBloc() : super(StepInitial()) {
    on<LoadTodaySteps>((event, emit) async {
      emit(StepLoadInProgress());

      await health.configure();

      bool? authorized = await health.requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );

      if (authorized != true) {
        emit(StepLoadFailure("Authorization denied"));
        return;
      }

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      try {
        final data = await health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: start,
          endTime: now,
        );

        final totalSteps = data.fold<int>(
          0,
          (sum, item) => sum + extractSteps(item.value),
        );

        emit(StepLoadSuccess(totalSteps));
      } catch (e) {
        emit(StepLoadFailure(e.toString()));
      }
    });
  }
}
