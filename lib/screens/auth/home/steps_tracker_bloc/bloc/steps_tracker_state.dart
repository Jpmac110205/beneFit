abstract class StepState {}

class StepInitial extends StepState {}
class StepLoadInProgress extends StepState {}
class StepLoadSuccess extends StepState {
  final int steps;
  StepLoadSuccess(this.steps);
}
class StepLoadFailure extends StepState {
  final String message;
  StepLoadFailure(this.message);
}
