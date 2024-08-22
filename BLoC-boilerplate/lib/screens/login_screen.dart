import 'package:bloc_boiler_plate/cubit/login_cubit.dart';
import 'package:bloc_boiler_plate/helper/routes.dart';
import 'package:bloc_boiler_plate/state/form_validate_state.dart';
import 'package:bloc_boiler_plate/widget/error_message_box_widget.dart';
import 'package:bloc_boiler_plate/widget/primary_button_widget.dart';
import 'package:bloc_boiler_plate/widget/primary_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginCubit = LoginCubit();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      String message =
          (ModalRoute.of(context)!.settings.arguments ?? "") as String;
      if (message.isNotEmpty) {
        loginCubit.showErrorMsg(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BlocBuilder<LoginCubit, FormValidateState>(
          bloc: loginCubit,
          builder: (context, state) {
            return Form(
              key: loginCubit.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  120.heightBox,
                  state.isShowMsg
                      ? ErrorMessageBoxWidget(
                          message: state.message,
                          isError: state.msgStatus,
                        )
                      : 30.heightBox,
                  20.heightBox,
                  PrimaryTextFieldWidget(
                    textInputAction: TextInputAction.next,
                    focus: loginCubit.emailFocus,
                    label: "Email",
                    controller: loginCubit.emailController,
                    onCompletd: (_) {
                      loginCubit.nextFocus(context);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "⚠️ Please enter your password";
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9.a-z_+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return "⚠️ Enter valid email";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    suffixIcon: const Icon(Icons.email),
                  ),
                  20.heightBox,
                  PrimaryTextFieldWidget(
                    textInputAction: TextInputAction.done,
                    focus: loginCubit.passwordFocus,
                    label: "Passowrd",
                    controller: loginCubit.passwordController,
                    onCompletd: (_) {
                      loginCubit.passwordDone(context);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "⚠️ Please enter your password";
                      } else if (value.length < 8) {
                        return "⚠️ Enter valid password";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  24.heightBox,
                  PrimaryButtonWidget(
                    isLoading: state.isLoading,
                    onTap: () {
                      if (state.isLoading) return;
                      loginCubit.validateForm().then((value) {
                        if (value) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, Routes.home, (Route<dynamic> route) {
                            return route.settings.name == Routes.home;
                          });
                        }
                      });
                    },
                    label: "Login",
                  ),
                  10.heightBox,
                ],
              ).pSymmetric(h: 30),
            );
          },
        ),
      ),
    );
  }
}
