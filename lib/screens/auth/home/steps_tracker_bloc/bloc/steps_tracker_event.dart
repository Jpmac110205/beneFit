abstract class StepEvent {}

class LoadTodaySteps extends StepEvent {}
class StepsLoaded extends StepEvent {
  final int steps;
  StepsLoaded(this.steps);
}
