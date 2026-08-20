import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.login(email, password);
      emit(AuthSuccess());
    } catch (e) {
      // Remove the "Exception: " prefix if present from generic exceptions
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthFailure(errorMessage));
    }
  }

  void logout() async {
    await _authService.logout();
    emit(AuthInitial());
  }
}
