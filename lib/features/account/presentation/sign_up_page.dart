import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io' show Platform;

import '../../../common_widgets/apple_signin_button_widget.dart';
import '../../../common_widgets/body_medium_text_widget.dart';
import '../../../common_widgets/google_signin_button_widget.dart';
import '../../../common_widgets/loader_widget.dart';
import '../../../common_widgets/text_form_field_widget.dart';
import '../../../common_widgets/title_large_text_widget.dart';
import '../../../constants/terms_conditions_widget.dart';
import '../../../helpers/validator.dart';
import '../../../utils/responsive.dart';
import 'account_cubit.dart';
import 'account_state.dart';
import 'sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // * TextEditingControllers should be always disposed
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void validateAndSave(BuildContext context) {
    final form = _formKey.currentState!;
    if (form.validate()) {
      final accountCubit = context.read<AccountCubit>();
      accountCubit.signUpWithEmailAndPassword(
        _fullNameController.text,
        _emailController.text,
        _passwordController.text,
        context,
      );

      _fullNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    final accountCubit = context.read<AccountCubit>();

    return Scaffold(
      // appBar: const AppBarWidget(title: 'Sign Up'),
      body: SafeArea(
        // We can combine a BlocListener (for errors) + BlocBuilder (for UI)
        child: BlocListener<AccountCubit, AccountState>(
          listener: (context, accountState) {
            // If there's an error message, show a SnackBar (optional)
            if (accountState.errorMsg != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(accountState.errorMsg!)));
            } else if (accountState.isSuccess) {
              // context.goNamed(AppRoute.signInPage.name);

              // SuccessMessageWidget.showSucess(
              //   context,
              //   'Account created successfully! An email was sent to your the email provided. Please click on the link to validate your email and sign in.',
              // );
            }
          },
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, accountState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Center(
                          child: Column(
                            children: [
                              const TitleLargeTextWidget(text: 'Sign Up'),
                              const SizedBox(height: 25),
                              const BodyMediumTextWidget(
                                text: 'Create an account',
                              ),
                              const SizedBox(height: 5),
                              const BodyMediumTextWidget(
                                text:
                                    'Enter your full name, email, and password',
                              ),
                              const SizedBox(height: 45),
                              Form(
                                key: _formKey,
                                child: SizedBox(
                                  width: isTablet ? 500 : 375,
                                  child: Column(
                                    children: [
                                      TextFormFieldWidget(
                                        controller: _fullNameController,
                                        labelText: 'Full Name',
                                        validator:
                                            (value) =>
                                                value!.isEmpty
                                                    ? 'Please provide your full name'
                                                    : null,
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormFieldWidget(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        labelText: 'Email',
                                        validator:
                                            (value) =>
                                                Validator.validateEmail(value!),
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormFieldWidget(
                                        controller: _passwordController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        obscureText:
                                            true, // or bind to a local bool if you prefer
                                        labelText: 'Password',
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please provide a password';
                                          } else if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormFieldWidget(
                                        controller: _confirmPasswordController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        obscureText: true,
                                        labelText: 'Confirm Password',
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please confirm your password';
                                          } else if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 45),
                                      // If loading, show loader; otherwise show button
                                      accountState.isLoading
                                          ? const LoaderWidget()
                                          : GoogleSigninButtonWidget(
                                            width: isTablet ? 500 : 375,

                                            icon: FaIcon(
                                              FontAwesomeIcons
                                                  .arrowRightToBracket,
                                              size: 25,
                                              color:
                                                  Colors
                                                      .white, // This color will be used as a mask
                                            ),
                                            onPressed:
                                                () => validateAndSave(context),
                                            text: Text(
                                              ' Sign Up',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),

                                      // ElevatedButtonWidget(
                                      //   onPressed:
                                      //       () => validateAndSave(context),
                                      //   text: ' Sign Up',
                                      // ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const BodyMediumTextWidget(
                                            text: 'Already have an account? ',
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const SignInPage(),
                                                  ),
                                                ),
                                            child: const BodyMediumTextWidget(
                                              text: 'Sign In ',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Divider(
                                              thickness: 1,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              'Or sign up with',
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Divider(
                                              thickness: 1,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      GoogleSigninButtonWidget(
                                        width: isTablet ? 500 : 375,

                                        onPressed:
                                            () => accountCubit.signUpWithGoogle(
                                              context,
                                            ),
                                        text: Text(
                                          ' Google',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                      if (Platform.isIOS)
                                        const SizedBox(height: 25),
                                      if (Platform.isIOS)
                                        AppleSigninButtonWidget(
                                          width: isTablet ? 500 : 375,

                                          onPressed:
                                              () => accountCubit
                                                  .signUpWithApple(context),
                                          text: Text(
                                            ' Apple',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  const BodyMediumTextWidget(
                                    text: 'By signing up, you agree to our ',
                                  ),
                                  GestureDetector(
                                    onTap:
                                        () => {
                                          TermsConditionsWidget.termsConditionsWidget(
                                            context: context,
                                          ),
                                        },
                                    child: Text(
                                      'Terms and Conditions',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // You can add an "I accept the terms" etc. if needed
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
