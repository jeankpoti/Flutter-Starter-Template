import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

import '../../../common_widgets/apple_signin_button_widget.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../../../common_widgets/google_signin_button_widget.dart';
import '../../../common_widgets/loader_widget.dart';
import '../../../common_widgets/text_form_field_widget.dart';
import '../../../common_widgets/text_widgets.dart';

import '../../../main.dart';
import '../../../utils/responsive.dart';
import 'account_cubit.dart';
import 'account_state.dart';
import 'reset_password_page.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isPasswordVisible =
      true; // Keep local state for toggling password visibility

  @override
  void dispose() {
    // * TextEditingControllers should be always disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void validateAndSave(BuildContext context) {
    final form = _formKey.currentState!;
    if (form.validate()) {
      final accountCubit = context.read<AccountCubit>();
      accountCubit.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        context,
      );

      _emailController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    final accountCubit = context.read<AccountCubit>();

    return Scaffold(
      // appBar: const AppBarWidget(title: 'Sign In'),
      body: SafeArea(
        // 1. Use a BlocListener for errors (optional)
        child: BlocListener<AccountCubit, AccountState>(
          listener: (context, accountState) {
            if (accountState.errorMsg != null && accountState.errorMsg!.isNotEmpty) {
              AppSnackBar.showError(context, accountState.errorMsg!);
            } else if (accountState.isSuccess) {
              context.goNamed(AppRoute.mainPage.name);
            }
          },
          // 2. Use BlocBuilder for UI based on state
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
                              TitleLargeText(
                                AppLocalizations.of(context)!.signIn,
                              ),
                              const SizedBox(height: 25),
                              BodyMediumText(
                                AppLocalizations.of(context)!.connectToAccount,
                              ),
                              const SizedBox(height: 5),
                              BodyMediumText(
                                AppLocalizations.of(context)!.signInDescription,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 45),
                              Form(
                                key: _formKey,
                                child: SizedBox(
                                  width: isTablet ? 500 : 375,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      TextFormFieldWidget(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        labelText:
                                            AppLocalizations.of(context)!.email,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return AppLocalizations.of(
                                              context,
                                            )!.emailRequired;
                                          }
                                          // Basic email validation
                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(value)) {
                                            return AppLocalizations.of(
                                              context,
                                            )!.invalidEmail;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormFieldWidget(
                                        controller: _passwordController,
                                        obscureText: isPasswordVisible,
                                        labelText:
                                            AppLocalizations.of(
                                              context,
                                            )!.password,
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isPasswordVisible =
                                                  !isPasswordVisible;
                                            });
                                          },
                                          child: Icon(
                                            isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ),
                                        validator:
                                            (value) =>
                                                value!.isEmpty
                                                    ? AppLocalizations.of(
                                                      context,
                                                    )!.passwordRequired
                                                    : null,
                                      ),
                                      const SizedBox(height: 15),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const ResetPasswordPage(),
                                              ),
                                            ),
                                        child: BodyMediumText(
                                          AppLocalizations.of(
                                            context,
                                          )!.forgotPassword,
                                        ),
                                      ),
                                      const SizedBox(height: 45),
                                      // Conditionally show loader or button
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
                                              ' ${AppLocalizations.of(context)!.signIn}',
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
                                      //   height: 50,
                                      //   width: 375,

                                      //   onPressed:
                                      //       () => validateAndSave(context),
                                      //   text: ' Sign In',
                                      // ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          BodyMediumText(
                                            AppLocalizations.of(
                                              context,
                                            )!.noAccount,
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const SignUpPage(),
                                                  ),
                                                ),
                                            child: BodyMediumText(
                                              AppLocalizations.of(
                                                context,
                                              )!.signUp,
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
                                            child: BodyMediumText(
                                              AppLocalizations.of(
                                                context,
                                              )!.orSignInWith,
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
                                            () => accountCubit
                                                .signInWithGooogle(context),
                                        text: Text(
                                          ' ${AppLocalizations.of(context)!.google}',
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
                                                  .signInWithApple(context),
                                          text: Text(
                                            ' ${AppLocalizations.of(context)!.apple}',
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
