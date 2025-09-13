import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/signup_usecase.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupUseCase signupUseCase;

  SignupBloc({
    required this.signupUseCase,
  }) : super(const SignupInitial()) {
    on<SignupRequested>(_onSignupRequested);
  }

  void _onSignupRequested(SignupRequested event, Emitter<SignupState> emit) async {
    emit(const SignupLoading());

    final result = await signupUseCase(
      SignupParams(
        firstName: event.firstName,
        email: event.email,
        password: event.password,
        location: event.location,
      ),
    );

    result.fold(
          (failure) => emit(SignupError(failure.toString())),
          (user) => emit(SignupSuccess(user)),
    );
  }
}