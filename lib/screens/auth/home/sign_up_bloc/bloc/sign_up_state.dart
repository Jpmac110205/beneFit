part of 'sign_up_bloc.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpProcess extends SignUpState {}

class SignUpSuccess extends SignUpState {}

class SignUpFailure extends SignUpState {
  final String errorMessage;
  
  const SignUpFailure([this.errorMessage = 'Sign up failed']);
  
  @override
  List<Object> get props => [errorMessage];
}
