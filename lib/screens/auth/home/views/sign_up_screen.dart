import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/components/my_text_field.dart';
import 'package:game/screens/privacy_policy.dart';
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
  String? errorMessage;

  // New privacy policy checkbox state
  bool agreedToPolicy = false;

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
            errorMessage = null;
          });
        } else if (state is SignUpProcess) {
          setState(() {
            signUpRequired = true;
            errorMessage = null;
          });
        } else if (state is SignUpFailure) {
          setState(() {
            signUpRequired = false;
            errorMessage = state.errorMessage;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const SizedBox(height: 40),
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join BeneFIT and start your fitness journey today',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          _buildFieldLabel('Full Name'),
                          const SizedBox(height: 8),
                          MyTextField(
                            controller: nameController,
                            style: TextStyle(color: colorScheme.onSurface),
                            hintText: 'Enter your full name',
                            obscureText: false,
                            keyboardType: TextInputType.name,
                            prefixIcon: Icon(
                              CupertinoIcons.person_fill,
                              color: colorScheme.primary,
                            ),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your name';
                              } else if (val.length > 30) {
                                return 'Name too long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Username Field
                          _buildFieldLabel('Username'),
                          const SizedBox(height: 8),
                          MyTextField(
                            controller: usernameController,
                            style: TextStyle(color: colorScheme.onSurface),
                            hintText: 'Choose a unique username',
                            obscureText: false,
                            keyboardType: TextInputType.text,
                            prefixIcon: Icon(
                              CupertinoIcons.person_crop_circle,
                              color: colorScheme.primary,
                            ),
                            onChanged: (val) {
                              if (errorMessage != null && errorMessage!.contains('Username')) {
                                setState(() {
                                  errorMessage = null;
                                });
                              }
                            },
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
                          const SizedBox(height: 20),

                          // Email Field
                          _buildFieldLabel('Email'),
                          const SizedBox(height: 8),
                          MyTextField(
                            controller: emailController,
                            style: TextStyle(color: colorScheme.onSurface),
                            hintText: 'Enter your email address',
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icon(
                              CupertinoIcons.mail_solid,
                              color: colorScheme.primary,
                            ),
                            onChanged: (val) {
                              if (errorMessage != null && errorMessage!.contains('Email')) {
                                setState(() {
                                  errorMessage = null;
                                });
                              }
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          _buildFieldLabel('Password'),
                          const SizedBox(height: 8),
                          MyTextField(
                            controller: passwordController,
                            style: TextStyle(color: colorScheme.onSurface),
                            hintText: 'Create a strong password',
                            obscureText: obscurePassword,
                            keyboardType: TextInputType.visiblePassword,
                            prefixIcon: Icon(
                              CupertinoIcons.lock_fill,
                              color: colorScheme.primary,
                            ),
                            onChanged: (val) {
                              setState(() {
                                containsUpperCase = val.contains(RegExp(r'[A-Z]'));
                                containsLowerCase = val.contains(RegExp(r'[a-z]'));
                                containsNumber = val.contains(RegExp(r'[0-9]'));
                                containsSpecialChar = val.contains(RegExp(r'[!@#$&*~`)%\-(_+=;:,.<>/?"[{\]}\|^]'));
                                contains8Length = val.length >= 8;
                              });
                            },
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                  iconPassword = obscurePassword
                                      ? CupertinoIcons.eye_fill
                                      : CupertinoIcons.eye_slash_fill;
                                });
                              },
                              icon: Icon(iconPassword, color: colorScheme.primary),
                            ),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter a password';
                              } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$').hasMatch(val)) {
                                return 'Please enter a valid password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Requirements
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password Requirements',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildRequirementItem('Uppercase letter', containsUpperCase),
                                          _buildRequirementItem('Lowercase letter', containsLowerCase),
                                          _buildRequirementItem('Number', containsNumber),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildRequirementItem('Special character', containsSpecialChar),
                                          _buildRequirementItem('8+ characters', contains8Length),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Privacy Policy Checkbox
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: agreedToPolicy,
                                  onChanged: (value) {
                                    setState(() {
                                      agreedToPolicy = value ?? false;
                                    });
                                  },
                                  activeColor: colorScheme.primary,
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                      children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const PrivacyPolicyPage(),
                                              ),
                                            );
                                          },
                                      ),
                                    ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Error Message
                          if (errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.exclamationmark_triangle_fill,
                                    color: Colors.red.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: agreedToPolicy && !signUpRequired
                                  ? () {
                                      if (_formKey.currentState!.validate()) {
                                        MyUser myUser = MyUser.empty;
                                        myUser.email = emailController.text;
                                        myUser.name = nameController.text;
                                        myUser.username = usernameController.text.toLowerCase();

                                        context.read<SignUpBloc>().add(
                                              SignUpRequired(
                                                myUser,
                                                passwordController.text,
                                              ),
                                            );

                                        // Initialize user document in Firestore
                                      }

                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
                                disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
                              ),
                              child: signUpRequired
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Create Account',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
            color: isMet ? Colors.green : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isMet 
                  ? Colors.green 
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
