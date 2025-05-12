import 'dart:convert';

import 'package:chat/constants.dart';
import 'package:chat/screens/auth/forgot_password_screen.dart';
import 'package:chat/screens/auth/sign_up_screen.dart';
import 'package:chat/screens/main/main_screen.dart';
import 'package:chat/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  bool isSnackbarVisible = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  SvgPicture.asset(
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? logoDarkTheme
                        : logoLightTheme,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Text(
                    "Sign In",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: usernameController,
                          validator:
                          RequiredValidator(errorText: requiredField),
                          decoration:
                          const InputDecoration(hintText: 'Username'),
                          keyboardType: TextInputType.text,
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            validator:
                            RequiredValidator(errorText: requiredField),
                            decoration:
                            const InputDecoration(hintText: 'Password'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String username = usernameController.text.trim();
                              String password = passwordController.text;

                              String? loginResult = await ApiService.login(username, password);

                              if (loginResult == null) return;
                              final data = json.decode(loginResult);

                              final RxInt countdown = 2.obs; // Đếm ngược 2 giây

                              if (data['error'] != null) {
                                Get.snackbar(
                                  "Account is invalid",
                                  "Error",
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                  snackPosition: SnackPosition.TOP,
                                );
                              } else {
                                Get.closeAllSnackbars();

                                Get.snackbar(
                                  "Sign in successful",
                                  "Success",
                                  backgroundColor: Colors.greenAccent,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                  snackPosition: SnackPosition.TOP,
                                );

                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('accessToken', data['accessToken']);
                                await prefs.setString('username', username);

                                // Delay 1.5s before navigating to MainScreen
                                Future.delayed(const Duration(milliseconds: 3000), () {
                                  Get.offAll(() => MainScreen());
                                });
                              }
                            }
                          },
                          child: const Text("Sign in"),
                        ),
                        const SizedBox(height: defaultPadding),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(0.64),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Don’t have an account? ",
                              children: [
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(0.64),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

