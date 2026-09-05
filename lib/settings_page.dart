import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/core/config/firebase_config.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accountCubit = context.read<AccountCubit>();

    // Only listen to auth changes if Firebase is configured
    if (FirebaseConfig.isInitialized) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
        } else {}
      });
    }

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

              final user = FirebaseConfig.isInitialized
                  ? FirebaseAuth.instance.currentUser
                  : null;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Preferences Section
                    SettingsSectionHeaderWidget(
                      isDeco: false,
                      title: AppLocalizations.of(context)!.appPreferences,
                      icon: Icons.settings,
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    ),
                    BlocBuilder<LocaleCubit, Locale>(
                      builder: (context, currentLocale) {
                        return LanguageDropdown(
                          selectedLocale: currentLocale,
                          onChanged: (languageCode) async {
                            // Capture language name and localization before async gap
                            final languageName = _getLanguageName(
                              context,
                              languageCode,
                            );
                            final localeCubit = context.read<LocaleCubit>();

                            await localeCubit.changeLocale(languageCode);

                            if (mounted) {
                              AppSnackBar.showSuccess(
                                this.context,
                                AppLocalizations.of(
                                  this.context,
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
                        await AppReviewService.openStoreListing();
                      },
                    ),
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.shareWithFriends,
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () {
                        final storeUrl =
                            Platform.isAndroid
                                ? 'https://play.google.com/store/apps/details?id=com.example.app'
                                : 'https://apps.apple.com/app/idYOUR_APP_ID';
                        SharePlus.instance.share(
                          ShareParams(
                            text: AppLocalizations.of(context)!.shareAppText(storeUrl),
                          ),
                        );
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
                        const url = "https://example.com/support";
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
                    SettingsListTile(
                      text: AppLocalizations.of(context)!.privacyPolicyTerms,
                      icon: Icon(
                        Icons.privacy_tip,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () async {
                        const url = "https://example.com/privacy";
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
