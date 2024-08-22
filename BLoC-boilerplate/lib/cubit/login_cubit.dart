import 'package:bloc_boiler_plate/helper/routes.dart';
import 'package:bloc_boiler_plate/state/form_validate_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A Cubit that manages the state of the login form.
class LoginCubit extends Cubit<FormValidateState> {
  /// The global key for the form state.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// The text editing controller for the email field.
  final TextEditingController emailController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  /// The text editing controller for the password field.
  final TextEditingController passwordController = TextEditingController();

  LoginCubit() : super(FormValidateState());

  /// Submits the login form.
  Future<bool> submitForm() async {
    emit(state.copyWith(
      isShowMsg: false,
    ));
    if (formKey.currentState!.validate()) {
      emit(state.copyWith(isLoading: true));

      emit(state.copyWith(isLoading: false));

      return true;
    } else {
      return false;
    }
  }

  void nextFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(passwordFocus);
  }

  void passwordDone(BuildContext context) async {
    if (state.isLoading) return;
    validateForm().then((value) {
      if (value) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.home,
            (Route<dynamic> route) {
          return route.settings.name == Routes.home;
        });
      }
    });
  }

  /// Shows an error message.
  void showErrorMsg(String message) {
    emit(state.copyWith(
      message: message,
      isShowMsg: true,
      msgStatus: MsgStatus.success,
    ));
  }

  /// Validates the login form.
  Future<bool> validateForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    formKey.currentState!.validate();
    List messages =
        formKey.currentState!.validateGranularly().toList().where((e) {
      return e.errorText?.contains("⚠️") ?? false;
    }).toList();
    if (messages.length >= 2) {
      emit(state.copyWith(
        isShowMsg: true,
        message: "Incorrect email or password.\nPlease try again.",
        isValid: false,
      ));
      return false;
    } else {
      emit(state.copyWith(isValid: true, isShowMsg: false, message: ""));
      return await submitForm();
    }
  }
}
