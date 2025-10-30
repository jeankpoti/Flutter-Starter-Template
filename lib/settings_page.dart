import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_widgets/app_bar_widget.dart';
import 'common_widgets/app_snackbar_widget.dart';
import 'common_widgets/delete_account_dialog_widget.dart';
import 'common_widgets/loader_widget.dart';
import 'common_widgets/settings_list_tile.dart';
import 'common_widgets/settings_dropdown_widget.dart';
import 'common_widgets/settings_section_header_widget.dart';
import 'features/account/presentation/account_cubit.dart';
import 'features/account/presentation/account_state.dart';
import 'features/account/presentation/reset_password_page.dart';
import 'features/locale/presentation/locale_cubit.dart';
import 'features/settings/data/preferences_service.dart';
import 'features/settings/domain/models/math_level.dart';
import 'features/settings/domain/models/response_length.dart';
import 'features/solve_math/data/repository/gemini_solve_math_repo.dart';
import 'features/subscription/presentation/subscription_page.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'theme/theme_cubit.dart';
import 'core/services/app_review_service.dart';

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
  ResponseLength _selectedResponseLength = ResponseLength.short;
  bool _isLoadingResponseLength = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentMathLevel();
    _loadCurrentResponseLength();
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
        case MathLevel.middleSchool:
          levelName = localizations.middleSchool;
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

  Future<void> _loadCurrentResponseLength() async {
    final prefs = await PreferencesService.getInstance();
    setState(() {
      _selectedResponseLength = prefs.getResponseLength();
      _isLoadingResponseLength = false;
    });
  }

  Future<void> _saveResponseLength(ResponseLength length) async {
    final prefs = await PreferencesService.getInstance();
    await prefs.setResponseLength(length);
    setState(() {
      _selectedResponseLength = length;
    });

    // Reinitialize the Gemini model with new settings
    final geminiRepo = GeminiSolveMathRepo();
    await geminiRepo.reinitialize();

    if (mounted) {
      final localizations = AppLocalizations.of(context)!;
      String lengthName;
      switch (length) {
        case ResponseLength.short:
          lengthName = localizations.responseLengthShort;
          break;
        case ResponseLength.medium:
          lengthName = localizations.responseLengthMedium;
          break;
        case ResponseLength.long:
          lengthName = localizations.responseLengthLong;
          break;
      }
      AppSnackBar.showSuccess(
        context,
        'Response length updated to $lengthName',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountCubit = context.read<AccountCubit>();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
      } else {}
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Preferences Section
                    SettingsSectionHeaderWidget(
                      isDeco: false,
                      title: AppLocalizations.of(context)!.aiPreferences,
                      icon: Icons.psychology,
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    ),
                    MathLevelDropdown(
                      selectedLevel: _selectedLevel,
                      isLoading: _isLoadingMathLevel,
                      onChanged: _saveMathLevel,
                    ),
                    const SizedBox(height: 8),
                    ResponseLengthDropdown(
                      selectedLength: _selectedResponseLength,
                      isLoading: _isLoadingResponseLength,
                      onChanged: _saveResponseLength,
                    ),

                    // App Preferences Section
                    SettingsSectionHeaderWidget(
                      isDeco: true,
                      title: AppLocalizations.of(context)!.appPreferences,
                      icon: Icons.settings,
                    ),
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
                    const SizedBox(height: 8),
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

                    // Premium Section
                    SettingsSectionHeaderWidget(
                      isDeco: true,

                      title: AppLocalizations.of(context)!.premium,
                      icon: Icons.star,
                    ),
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.getPremium,
                      icon: Icon(
                        Icons.diamond,
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

                    // Support & Feedback Section
                    SettingsSectionHeaderWidget(
                      isDeco: true,

                      title: AppLocalizations.of(context)!.supportAndFeedback,
                      icon: Icons.help_outline,
                    ),
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.rateUs,
                      icon: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () async {
                        const url =
                            "https://itunes.apple.com/app/id6746733499?action=write-review";
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
                      text: AppLocalizations.of(context)!.sendFeedback,
                      icon: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () {
                        AppReviewService.sendGeneralFeedback(
                          context: context,
                          feedbackType: 'general',
                        );
                      },
                    ),
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.support,
                      icon: Icon(
                        Icons.help_center,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () async {
                        const url = "https://mathgenieai.jkstudioo.com/support";
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

                    // Legal Section
                    // SettingsSectionHeaderWidget(
                    //   title: AppLocalizations.of(context)!.legal,
                    //   icon: Icons.gavel,
                    // ),
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.privacyPolicyTerms,
                      icon: Icon(
                        Icons.privacy_tip,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () async {
                        const url =
                            "https://mathgenieai.jkstudioo.com/privacy-policy";
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

                    // Account Section
                    if (user != null) ...[
                      SettingsSectionHeaderWidget(
                        isDeco: true,
                        title: AppLocalizations.of(context)!.account,
                        icon: Icons.person,
                      ),
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
                      ExpansionTile(
                        title: Text(
                          AppLocalizations.of(context)!.accountSettings,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        leading: Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        children: [
                          SettingsListTile(
                            text: AppLocalizations.of(context)!.resetPassword,
                            icon: Icon(
                              Icons.lock_reset,
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
                          SettingsListTile(
                            text: AppLocalizations.of(context)!.deleteAccount,
                            icon: Icon(
                              Icons.delete_forever,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onTap:
                                () => DeleteAccountDialogWidget.show(
                                  context,
                                  accountCubit,
                                ),
                          ),
                        ],
                      ),
                    ],

                    // Add bottom padding
                    const SizedBox(height: 32),
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
