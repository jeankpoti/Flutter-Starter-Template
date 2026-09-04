import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/google_signin_button_widget.dart';
import '../../../common_widgets/loader_widget.dart';
import '../../../common_widgets/text_form_field_widget.dart';
import '../../../helpers/validator.dart';
import '../../../utils/responsive.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  void validateAndSend(BuildContext buildContext) {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      // final accountCubit = context.read<AccountCubit>();
      // accountCubit.resetPassword(
      //   context,
      //   _emailController.text.trim(),
      // );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: const AppBarWidget(title: 'Reset Password'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 45),

                        // const TitleLargeTextWidget(text: 'Reset password'),
                        // const SizedBox(height: 25),
                        const BodyMediumText(
                          'Please enter your email, and we will send you a verification code to your email.',
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
                                  keyboardType: TextInputType.emailAddress,
                                  labelText: 'Email',
                                  validator:
                                      (value) =>
                                          Validator.validateEmail(value!),
                                ),
                                const SizedBox(height: 45),
                                isLoading
                                    ? LoaderWidget()
                                    : GoogleSigninButtonWidget(
                                      width: isTablet ? 500 : 375,

                                      icon: FaIcon(
                                        FontAwesomeIcons.paperPlane,
                                        size: 25,
                                        color:
                                            Colors
                                                .white, // This color will be used as a mask
                                      ),
                                      onPressed: () => validateAndSend(context),
                                      text: Text(
                                        'Send',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),

                                // ElevatedButtonWidget(
                                //   onPressed: () => validateAndSend(context),
                                //   text: 'Send'.toUpperCase(),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
