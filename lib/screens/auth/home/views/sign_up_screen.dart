import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/components/my_text_field.dart';
import 'package:game/screens/auth/home/sign_up_bloc/bloc/sign_up_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  bool signUpRequired = false;

  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() {
            signUpRequired = false;
          });
        } else if (state is SignUpProcess) {
          setState(() {
            signUpRequired = true;
          });
        } else if (state is SignUpFailure) {
          return;
        }
      },
      child: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // The main form fields and buttons
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: MyTextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.black),
                          hintText: 'Email',
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(CupertinoIcons.mail_solid, color: Colors.black),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(val)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: MyTextField(
                          controller: usernameController,
                          style: TextStyle(color: Colors.black),
                          hintText: 'Username',
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(CupertinoIcons.person_crop_circle, color: Colors.black),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please choose a username';
                            } else if (val.length < 3 || val.length > 20) {
                              return 'Username must be 3–20 characters';
                            } else if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(val)) {
                              return 'Only letters, numbers, _ or . allowed';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: MyTextField(
                          controller: passwordController,
                          style: TextStyle(color: Colors.black),
                          hintText: 'Password',
                          obscureText: obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          prefixIcon: const Icon(CupertinoIcons.lock_fill, color: Colors.black),
                          onChanged: (val) {
                            if (val.contains(RegExp(r'[A-Z]'))) {
                              setState(() {
                                containsUpperCase = true;
                              });
                            } else {
                              setState(() {
                                containsUpperCase = false;
                              });
                            }
                            if (val.contains(RegExp(r'[a-z]'))) {
                              setState(() {
                                containsLowerCase = true;
                              });
                            } else {
                              setState(() {
                                containsLowerCase = false;
                              });
                            }
                            if (val.contains(RegExp(r'[0-9]'))) {
                              setState(() {
                                containsNumber = true;
                              });
                            } else {
                              setState(() {
                                containsNumber = false;
                              });
                            }
                            if (val.contains(RegExp(
                                r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])'))) {
                              setState(() {
                                containsSpecialChar = true;
                              });
                            } else {
                              setState(() {
                                containsSpecialChar = false;
                              });
                            }
                            if (val.length >= 8) {
                              setState(() {
                                contains8Length = true;
                              });
                            } else {
                              setState(() {
                                contains8Length = false;
                              });
                            }
                            return;
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                                if (obscurePassword) {
                                  iconPassword = CupertinoIcons.eye_fill;
                                } else {
                                  iconPassword = CupertinoIcons.eye_slash_fill;
                                }
                              });
                            },
                            icon: Icon(iconPassword),
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            } else if (!RegExp(
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$')
                                .hasMatch(val)) {
                              return 'Please enter a valid password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "⚈  1 uppercase",
                                style: TextStyle(
                                    color: containsUpperCase
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.onSurface),
                              ),
                              Text(
                                "⚈  1 lowercase",
                                style: TextStyle(
                                    color: containsLowerCase
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.onSurface),
                              ),
                              Text(
                                "⚈  1 number",
                                style: TextStyle(
                                    color: containsNumber
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "⚈  1 special character",
                                style: TextStyle(
                                    color: containsSpecialChar
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.onSurface),
                              ),
                              Text(
                                "⚈  8 minimum characters",
                                style: TextStyle(
                                    color: contains8Length
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: MyTextField(
                          style: TextStyle(color: Colors.black),
                          controller: nameController,
                          hintText: 'Name',
                          obscureText: false,
                          keyboardType: TextInputType.name,
                          prefixIcon: const Icon(CupertinoIcons.person_fill, color: Colors.black),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            } else if (val.length > 30) {
                              return 'Name too long';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      !signUpRequired
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    MyUser myUser = MyUser.empty;
                                    myUser.email = emailController.text;
                                    myUser.name = nameController.text;
                                    myUser.username = usernameController.text.toLowerCase();

                                    setState(() {
                                      context.read<SignUpBloc>().add(
                                            SignUpRequired(
                                              myUser,
                                              passwordController.text,
                                            ),
                                          );
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                    elevation: 3.0,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(60))),
                                child:  Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 5),
                                  child: Text(
                                    'Sign Up',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ],
                  ),

                  // Image at the bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Image.asset(
                      'images/A.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 100),
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
