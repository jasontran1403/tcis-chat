import 'dart:convert';

import 'package:chat/screens/auth/sign_in_screen.dart';
import 'package:chat/screens/auth/verification_screen.dart';
import 'package:chat/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../main/main_screen.dart';

class SignUpScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _fullname = '';
  String _phone = '';
  String _email = '';
  SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.08),
                SvgPicture.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? logoDarkTheme
                      : logoLightTheme,
                ),
                SizedBox(height: constraints.maxHeight * 0.08),
                Text(
                  "Sign Up",
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
                        validator: RequiredValidator(errorText: requiredField),
                        decoration: const InputDecoration(hintText: 'Username'),
                        onSaved: (username) => _username = username ?? '',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: defaultPadding),
                        child: TextFormField(
                          validator: passwordValidator,
                          decoration: const InputDecoration(hintText: 'Password'),
                          obscureText: true,
                          onSaved: (password) => _password = password ?? '',
                        ),
                      ),
                      TextFormField(
                        validator: RequiredValidator(errorText: requiredField),
                        decoration: const InputDecoration(hintText: 'Full name'),
                        onSaved: (name) => _fullname = name ?? '',
                      ),
                      const SizedBox(height: defaultPadding),
                      TextFormField(
                        validator: RequiredValidator(errorText: requiredField),
                        decoration: const InputDecoration(hintText: 'Email'),
                        onSaved: (email) => _email = email ?? '',
                      ),
                      const SizedBox(height: defaultPadding),
                      TextFormField(
                        validator: RequiredValidator(errorText: requiredField),
                        decoration: const InputDecoration(hintText: 'Phone'),
                        keyboardType: TextInputType.phone,
                        onSaved: (phone) => _phone = phone ?? '',
                      ),
                      const SizedBox(height: defaultPadding),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              try {
                                final result = await ApiService.register(
                                  _username,
                                  _password,
                                  _email,
                                  _phone,
                                  _fullname,
                                );

                                final decoded = json.decode(result);
                                if (decoded != null && decoded['accessToken'] != null) {
                                  Get.closeAllSnackbars();

                                  Get.snackbar(
                                    "Sign up successful, redirecting...",
                                    "Success",
                                    backgroundColor: Colors.greenAccent,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(16),
                                    duration: const Duration(seconds: 2),
                                    snackPosition: SnackPosition.TOP,
                                  );

                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('accessToken', decoded['accessToken']);
                                  await prefs.setString('username', _username);

                                  Future.delayed(const Duration(milliseconds: 3000), () {
                                    Get.offAll(() => MainScreen());
                                  });
                                }

                              } catch (e) {
                                String errorMessage = "Register account failed.";

                                if (e is Exception && e.toString().contains('{')) {
                                  try {
                                    // Tách JSON từ message Exception
                                    final errorJson = e.toString().split('{').last;
                                    final parsed = jsonDecode('{$errorJson') as Map<String, dynamic>;

                                    errorMessage = parsed.values.join('\n');
                                  } catch (_) {
                                    // fallback: dùng toString nếu parse lỗi
                                    errorMessage = e.toString();
                                  }
                                }

                                Get.snackbar(
                                  "$errorMessage",
                                  "Error",
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                  snackPosition: SnackPosition.TOP,
                                );
                              }
                            }
                          },
                          child: const Text("Sign Up"),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            children: [
                              TextSpan(
                                text: "Sign in",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
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
        }),
      ),
    );
  }
}

// only for demo
List<DropdownMenuItem<String>>? countries = [
  "Bangladesh",
  "Switzerland",
  'Canada',
  'Japan',
  'Germany',
  'Australia',
  'Sweden',
].map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(value: value, child: Text(value));
}).toList();
