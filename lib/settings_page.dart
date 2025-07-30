import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_widgets/app_bar_widget.dart';
import 'common_widgets/app_snackbar_widget.dart';
import 'common_widgets/loader_widget.dart';
import 'common_widgets/settings_list_tile.dart';
import 'common_widgets/settings_dropdown_widget.dart';
import 'common_widgets/text_widgets.dart';
import 'features/account/presentation/account_cubit.dart';
import 'features/account/presentation/account_state.dart';
import 'features/account/presentation/reset_password_page.dart';
import 'features/locale/presentation/locale_cubit.dart';
import 'features/settings/data/preferences_service.dart';
import 'features/settings/domain/models/math_level.dart';
import 'features/subscription/presentation/subscription_page.dart';
import 'l10n/app_localizations.dart';
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
  MathLevel _selectedLevel = MathLevel.highSchool;
  bool _isLoadingMathLevel = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentMathLevel();
  }

  Future<void> _loadCurrentMathLevel() async {
    final prefs = await PreferencesService.getInstance();
    setState(() {
      _selectedLevel = prefs.getMathLevel();
      _isLoadingMathLevel = false;
    });
  }

  Future<void> _saveMathLevel(MathLevel level) async {
    final prefs = await PreferencesService.getInstance();
    await prefs.setMathLevel(level);
    setState(() {
      _selectedLevel = level;
    });

    if (mounted) {
      final localizations = AppLocalizations.of(context)!;
      String levelName;
      switch (level) {
        case MathLevel.elementary:
          levelName = localizations.elementary;
          break;
        case MathLevel.highSchool:
          levelName = localizations.highSchool;
          break;
        case MathLevel.college:
          levelName = localizations.college;
          break;
      }
      AppSnackBar.showSuccess(
        context,
        localizations.mathLevelUpdated(levelName),
      );
    }
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
      appBar: AppBarWidget(title: AppLocalizations.of(context)!.settings),
      body: SafeArea(
        child: BlocListener<AccountCubit, AccountState>(
          listener: (context, accountState) {
            if (accountState.errorMsg != null) {
              AppSnackBar.showError(
                context,
                AppLocalizations.of(context)!.somethingWentWrong,
              );
            } else if (accountState.isSignOut) {
              AppSnackBar.showSuccess(
                context,
                AppLocalizations.of(context)!.signOutSuccess,
              );
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
                    // Math Level Section
                    MathLevelDropdown(
                      selectedLevel: _selectedLevel,
                      isLoading: _isLoadingMathLevel,
                      onChanged: _saveMathLevel,
                    ),

                    // Language Section
                    BlocBuilder<LocaleCubit, Locale>(
                      builder: (context, currentLocale) {
                        return LanguageDropdown(
                          selectedLocale: currentLocale,
                          onChanged: (languageCode) async {
                            await context.read<LocaleCubit>().changeLocale(
                              languageCode,
                            );

                            final languageName = _getLanguageName(
                              context,
                              languageCode,
                            );
                            if (mounted) {
                              AppSnackBar.showSuccess(
                                context,
                                AppLocalizations.of(
                                  context,
                                )!.languageChangedTo(languageName),
                                duration: const Duration(seconds: 2),
                              );
                            }
                          },
                        );
                      },
                    ),

                    SettingsListTile(
                      text: AppLocalizations.of(context)!.getPremium,
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).colorScheme.secondary,
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
                      text: AppLocalizations.of(context)!.changeTheme,
                      icon: Icon(
                        Icons.brightness_4,
                        color: Theme.of(context).colorScheme.secondary,
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

                    SettingsListTile(
                      text: AppLocalizations.of(context)!.rateUs,
                      icon: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () async {
                        const url =
                            "https://itunes.apple.com/app/idid6739957932?action=write-review";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          if (context.mounted) {
                            AppSnackBar.showError(
                              context,
                              AppLocalizations.of(context)!.somethingWentWrong,
                            );
                          }
                        }
                      },
                    ),
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.shareWithFriends,
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () {
                        Share.share(AppLocalizations.of(context)!.shareAppText);
                      },
                    ),
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.privacyPolicyTerms,
                      icon: Icon(
                        Icons.privacy_tip,
                        color: Theme.of(context).colorScheme.secondary,
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
                            AppSnackBar.showError(
                              context,
                              AppLocalizations.of(
                                context,
                              )!.couldNotOpenPrivacyPolicy,
                            );
                          }
                        }
                      },
                    ),
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.support,
                      icon: Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.secondary,
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
                            AppSnackBar.showError(
                              context,
                              AppLocalizations.of(context)!.couldNotOpenTerms,
                            );
                          }
                        }
                      },
                    ),
                    if (user != null)
                      SettingsListTile(
                        text: AppLocalizations.of(context)!.signOut,
                        icon: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onTap: () async {
                          await accountCubit.signOut();
                        },
                      ),

                    if (user != null)
                      ExpansionTile(
                        title: BodyMediumText(
                          AppLocalizations.of(context)!.accountSettings,
                        ),
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            title: BodyMediumText(
                              AppLocalizations.of(context)!.deleteAccount,
                            ),
                            onTap: () async {
                              String confirmText = '';

                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    title: BodyMediumText(
                                      AppLocalizations.of(
                                        context,
                                      )!.deleteAccount,
                                    ),
                                    content: Column(
                                      spacing: 16,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        BodyMediumText(
                                          AppLocalizations.of(
                                            context,
                                          )!.deleteAccountConfirmation,
                                        ),
                                        TextField(
                                          onChanged:
                                              (value) => confirmText = value,
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                          cursorColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          decoration: InputDecoration(
                                            hintText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.typeDeleteHint,
                                            fillColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                            labelStyle: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
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
                                                    ).colorScheme.secondary,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
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
                                          AppLocalizations.of(context)!.cancel,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium!,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (confirmText ==
                                              AppLocalizations.of(
                                                context,
                                              )!.deleteText) {
                                            Navigator.pop(context, true);
                                          } else {
                                            AppSnackBar.showError(
                                              context,
                                              AppLocalizations.of(
                                                context,
                                              )!.deleteConfirmationError,
                                            );
                                          }
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.deleteAccount,
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
                            text: AppLocalizations.of(context)!.resetPassword,
                            icon: Icon(
                              Icons.logout,
                              color: Theme.of(context).colorScheme.secondary,
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

  String _getLanguageName(BuildContext context, String languageCode) {
    final localizations = AppLocalizations.of(context)!;
    switch (languageCode) {
      case 'en':
        return localizations.englishLanguage;
      case 'fr':
        return localizations.frenchLanguage;
      case 'es':
        return localizations.spanishLanguage;
      default:
        return languageCode.toUpperCase(); // Fallback
    }
  }
}
