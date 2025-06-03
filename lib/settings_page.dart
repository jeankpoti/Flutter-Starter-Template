import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_widgets/app_bar_widget.dart';
import 'common_widgets/body_medium_text_widget.dart';
import 'common_widgets/error_message_widget.dart';
import 'common_widgets/loader_widget.dart';
import 'common_widgets/settings_list_tile.dart';
import 'features/account/presentation/account_cubit.dart';
import 'features/account/presentation/account_state.dart';
import 'features/account/presentation/reset_password_page.dart';
import 'features/subscription/presentation/subscription_page.dart';
import 'main.dart';
import 'theme/theme_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Keep local UI-only state for the theme switch
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Load the todos when this page is first built
  }

  @override
  Widget build(BuildContext context) {
    final accountCubit = context.read<AccountCubit>();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });

    return Scaffold(
      appBar: const AppBarWidget(title: 'Settings'),
      body: SafeArea(
        child: BlocListener<AccountCubit, AccountState>(
          listener: (context, accountState) {
            if (accountState.errorMsg != null) {
              ErrorMessageWidget.showError(context, 'Something went wrong!');
            } else if (accountState.isSignOut) {
              ErrorMessageWidget.showError(context, 'Sign out successfully!');
              // accountCubit.resetSignOut();

              context.goNamed(AppRoute.signInPage.name);

              // Reset the sign out state after navigation
              Future.microtask(() => accountCubit.resetSignOut());
            }
          },
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, accountState) {
              if (accountState.isLoading) {
                return const Center(child: LoaderWidget());
              }

              final user = FirebaseAuth.instance.currentUser;

              return SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SettingsListTile(
                      text: 'Change theme',
                      icon: Icon(
                        Icons.brightness_4,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      switcher: Switch(
                        value: _isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      ),
                    ),

                    if (user != null)
                      SettingsListTile(
                        text: 'Sign out',
                        icon: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: () async {
                          await accountCubit.signOut();
                        },
                      ),
                    SettingsListTile(
                      text: 'Get Premium',
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap:
                          () => PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: SubscriptionPage(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          ),
                    ),
                    SettingsListTile(
                      text: 'Rate Us',
                      icon: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        const url =
                            "https://itunes.apple.com/app/id\id6739957932?action=write-review";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          if (context.mounted) {
                            ErrorMessageWidget.showError(
                              context,
                              'Something went wrong!',
                            );
                          }
                        }
                      },
                    ),
                    SettingsListTile(
                      text: 'Share with Friends',
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        Share.share(
                          'Check out this amazing app: https://apps.apple.com/app/id6739957932',
                        );
                      },
                    ),
                    SettingsListTile(
                      text: 'Privacy Policy & Terms of Use',
                      icon: Icon(
                        Icons.privacy_tip,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        const url =
                            "https://snapanimalai.jeankpoti.com/privacy-policy";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (context.mounted) {
                            ErrorMessageWidget.showError(
                              context,
                              'Could not open Privacy Policy',
                            );
                          }
                        }
                      },
                    ),
                    SettingsListTile(
                      text: 'Support',
                      icon: Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        const url =
                            "https://snapanimalai.jeankpoti.com/support";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (context.mounted) {
                            ErrorMessageWidget.showError(
                              context,
                              'Could not open Terms of Use',
                            );
                          }
                        }
                      },
                    ),

                    if (user != null)
                      ExpansionTile(
                        title: const BodyMediumTextWidget(
                          text: 'Account Settings',
                        ),
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: const BodyMediumTextWidget(
                              text: 'Delete Account',
                            ),
                            onTap: () async {
                              String confirmText = '';

                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    title: const BodyMediumTextWidget(
                                      text: 'Delete Account',
                                    ),
                                    content: Column(
                                      spacing: 16,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const BodyMediumTextWidget(
                                          text:
                                              'This action cannot be undone. All your data will be deleted.  Please type "DELETE" to confirm.',
                                        ),
                                        TextField(
                                          onChanged:
                                              (value) => confirmText = value,
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          cursorColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          decoration: InputDecoration(
                                            hintText: 'Type DELETE',
                                            fillColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            labelStyle: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                            focusColor: Colors.white,
                                            hintStyle:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium!,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: Text(
                                          'Cancel',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium!,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (confirmText == 'DELETE') {
                                            Navigator.pop(context, true);
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please type DELETE to confirm',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Delete Account',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium!,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true && context.mounted) {
                                await accountCubit.deleteUserWithHisData(
                                  context,
                                );
                              }
                            },
                          ),
                          SettingsListTile(
                            text: 'Reset Password',
                            icon: Icon(
                              Icons.logout,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ResetPasswordPage(),
                                  ),
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
