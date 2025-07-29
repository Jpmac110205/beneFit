import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:game/bloc/bloc/bloc/authentication_event.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:async';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<MyUser?> _userSubscription;

  AuthenticationBloc({
    required this.userRepository,
  }) : super(const AuthenticationState.unknown()) {
    // Listen for user changes from the repository
    _userSubscription = userRepository.user.listen(
      (user) => add(AuthenticationUserChanged(user ?? MyUser.empty)),
    );

    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != MyUser.empty) {
        emit(AuthenticationState.authenticated(event.user));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });

    // Register the logout event handler!
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    await userRepository.logout();
    // No need to emit here — state changes come from the user stream
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
