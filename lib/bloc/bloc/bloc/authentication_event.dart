import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/src/models/user.dart';
import 'package:user_repository/src/user_repo.dart';

// EVENTS

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationUserChanged extends AuthenticationEvent {
  final MyUser user;

  const AuthenticationUserChanged(this.user);

  @override
  List<Object> get props => [user];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {
  const AuthenticationLogoutRequested();
}

// STATES

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final MyUser user;

  AuthenticationState._({
    required this.status,
    MyUser? user,
  }) : user = user ?? MyUser.empty;

  factory AuthenticationState.unknown() =>
      AuthenticationState._(status: AuthenticationStatus.unknown);

  factory AuthenticationState.authenticated(MyUser user) =>
      AuthenticationState._(status: AuthenticationStatus.authenticated, user: user);

  factory AuthenticationState.unauthenticated() =>
      AuthenticationState._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object> get props => [status, user];
}

// BLOC

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<MyUser?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
      : super(AuthenticationState.unknown()) {
    _userSubscription = userRepository.user.listen((user) {
      add(AuthenticationUserChanged(user ?? MyUser.empty));
    });

    on<AuthenticationUserChanged>(_onUserChanged);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
  }

  void _onUserChanged(
      AuthenticationUserChanged event,
      Emitter<AuthenticationState> emit,
      ) {
    if (event.user == MyUser.empty) {
      emit(AuthenticationState.unauthenticated());
    } else {
      emit(AuthenticationState.authenticated(event.user));
    }
  }

  Future<void> _onLogoutRequested(
      AuthenticationLogoutRequested event,
      Emitter<AuthenticationState> emit,
      ) async {
    await userRepository.logout();
    // No need to emit here; the authStateChanges stream triggers AuthenticationUserChanged.
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
