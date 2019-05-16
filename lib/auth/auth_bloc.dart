import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:open_copyright_platform/auth/index.dart';
import 'package:rails_api_connection/rails_api_connection.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({@required this.userRepository}) : assert(userRepository != null);

  @override
  AuthState get initialState => AuthUninitialized();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AppStarted) {
      final bool hasHeaders = await userRepository.hasHeaders();

      if (hasHeaders) {
        yield AuthAuthenticated();
      } else {
        yield AuthUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthLoading();
      await userRepository.persistHeaders(event.user);
      yield AuthAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthLoading();
      await userRepository.deleteHeaders();
      yield AuthUnauthenticated();
    }

    if (event is RegisteredIn) {
      yield AuthLoading();
      await userRepository.persistHeaders(event.user);
      yield AuthAuthenticated();
    }

    if (event is RegisterButtonPress) {
      yield AuthUnregistered();
    }

    if (event is LoginButtonPress) {
      yield AuthUnauthenticated();
    }
  }
}
