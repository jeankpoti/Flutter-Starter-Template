import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_starter/core/config/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_starter/features/account/presentation/sign_up_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/core/services/analytics_service.dart';
import 'package:flutter_starter/core/services/app_review_service.dart';
import 'package:flutter_starter/constants/subscription.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'startup_widget.dart';

import 'features/account/data/repository/account_repo.dart';
import 'features/account/presentation/account_cubit.dart';
import 'features/account/presentation/reset_password_page.dart';
import 'features/account/presentation/sign_in_page.dart';
import 'features/locale/presentation/locale_cubit.dart';
import 'features/explore/presentation/explore_page.dart';
import 'features/subscription/data/repository/revenue_cat_repository.dart';
import 'features/subscription/presentation/subscription_cubit.dart';
import 'features/subscription/presentation/subscription_page.dart';
import 'features/common/presentation/permission_cubit.dart';
import 'main_page.dart';
import 'onboarding_page.dart';
import 'settings_page.dart';
import 'theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional - will skip if not configured)
  // Note: Run 'flutterfire configure' to generate firebase_options.dart
  await FirebaseConfig.initialize();

  // Initialize SharedPreferences early (needed for first_open tracking)
  final prefs = await SharedPreferences.getInstance();

  // Initialize Analytics Service (will check for permission internally)
  await AnalyticsService.initialize();

  // Track first_open for new user acquisition (Google Ads)
  final hasTrackedFirstOpen = prefs.getBool('has_tracked_first_open') ?? false;
  if (!hasTrackedFirstOpen) {
    await AnalyticsService.logFirstOpen();
    await prefs.setBool('has_tracked_first_open', true);
  }

  // Initialize App Review Service (increments launch count)
  await AppReviewService.initialize();

  // Initialize RevenueCat
  final subscriptionRepository = RevenueCatRepository();
  await subscriptionRepository.initialize();

  // Set up RevenueCat purchase listener for paywall purchases
  // This captures purchases made via RevenueCatUI.presentPaywall()
  Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    await _trackPurchaseFromRevenueCat(customerInfo, prefs);
  });

  final accountRepo = FirebaseRepo();

  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    PostHogWidget(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit(isDarkMode)),
          BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),
          BlocProvider<AccountCubit>(
            create: (context) => AccountCubit(accountRepo),
          ),

          BlocProvider<SubscriptionCubit>(
            create: (context) => SubscriptionCubit(subscriptionRepository),
          ),

          BlocProvider<PermissionCubit>(create: (context) => PermissionCubit()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, currentTheme) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, currentLocale) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'My App',
              theme: currentTheme,
              locale: currentLocale,
              routerConfig: _router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('fr'), // French
                Locale('es'), // Spanish
              ],
              // home: SigninPage(),
              // MainView(),
            );
          },
        );
      },
    );
  }
}

enum AppRoute {
  mainPage,
  homePage,
  explorePage,

  signInPage,
  signUpPage,
  resetPasswordPage,

  subscriptionPage,

  onboardingPage,

  settingsPage,
}

// Create a navigatorKey for the ShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Define the routes
final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  observers: [PosthogObserver()],

  routes: [
    // Authentication routes (outside of shell)
    GoRoute(
      path: '/sign-in',
      name: AppRoute.signInPage.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/sign-up',
      name: AppRoute.signUpPage.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/reset-password',
      name: AppRoute.resetPasswordPage.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: AppRoute.onboardingPage.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingPage(),
    ),

    // ShellRoute for main app with persistent navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainPage(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: AppRoute.mainPage.name,
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, prefsSnapshot) {
                  if (prefsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final hasSeenOnboarding =
                      prefsSnapshot.data?.getBool('hasSeenOnboarding') ?? false;

                  if (!hasSeenOnboarding) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.goNamed(AppRoute.onboardingPage.name);
                    });
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // After onboarding is seen, check auth state
                  // Skip auth check if Firebase isn't configured (demo mode)
                  if (!FirebaseConfig.isInitialized) {
                    return const StartupWidget();
                  }

                  return StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasData) {
                        return const StartupWidget();
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.goNamed(AppRoute.signInPage.name);
                        });
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
        GoRoute(
          path: '/explore',
          name: AppRoute.explorePage.name,
          pageBuilder:
              (context, state) => const NoTransitionPage(child: ExplorePage()),
        ),
        GoRoute(
          path: '/settings',
          name: AppRoute.settingsPage.name,
          pageBuilder:
              (context, state) => const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),

    // Routes that break out of the shell (no bottom navigation)
    GoRoute(
      path: '/subscription',
      name: AppRoute.subscriptionPage.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SubscriptionPage(),
    ),
  ],
);

/// Track purchases from RevenueCat paywall (handles purchases that bypass SubscriptionCubit)
/// This ensures all purchases are tracked for Google Ads conversion attribution
Future<void> _trackPurchaseFromRevenueCat(
  CustomerInfo customerInfo,
  SharedPreferences prefs,
) async {
  try {
    final entitlement =
        customerInfo.entitlements.active[Subscription.entitlementID];
    if (entitlement == null) {
      // No active subscription, update user properties as free user
      await AnalyticsService.setSubscriptionUserProperties(isSubscribed: false);
      return;
    }

    // Check if this is a new purchase we haven't tracked yet
    final lastTrackedPurchaseDate = prefs.getString(
      'last_tracked_purchase_date',
    );
    final currentPurchaseDate = entitlement.latestPurchaseDate;

    if (currentPurchaseDate != lastTrackedPurchaseDate) {
      // Get product details for tracking
      final offerings = await Purchases.getOfferings();
      Package? package;

      if (offerings.current != null) {
        for (final pkg in offerings.current!.availablePackages) {
          if (pkg.storeProduct.identifier == entitlement.productIdentifier) {
            package = pkg;
            break;
          }
        }
      }

      final price = package?.storeProduct.price ?? 0.0;
      final currency = package?.storeProduct.currencyCode ?? 'USD';
      final productId = entitlement.productIdentifier;
      final subscriptionPeriod = _getSubscriptionPeriod(productId);

      // Check if user was in trial before this purchase
      final wasInTrial = prefs.getBool('was_in_trial') ?? false;
      final isTrialConversion =
          wasInTrial && entitlement.periodType == PeriodType.normal;
      final isFirstPurchase = customerInfo.allPurchaseDates.length <= 1;

      // Log purchase event (Google Ads standard event)
      await AnalyticsService.logPurchase(
        transactionId: entitlement.originalPurchaseDate,
        value: price,
        currency: currency,
        itemName: productId,
        itemCategory: subscriptionPeriod,
      );

      // Log in_app_purchase event (subscription-specific)
      await AnalyticsService.logInAppPurchase(
        productId: productId,
        price: price,
        currency: currency,
        subscriptionPeriod: subscriptionPeriod,
        isTrialConversion: isTrialConversion,
        isFirstPurchase: isFirstPurchase,
      );

      // Track trial conversion if applicable
      if (isTrialConversion) {
        await AnalyticsService.logTrialConversion(
          productId: productId,
          value: price,
          currency: currency,
        );
      }

      // Track trial start if user is in trial
      if (entitlement.periodType == PeriodType.trial) {
        await AnalyticsService.logTrialStart(
          productId: productId,
          trialDurationDays: 7, // Default trial duration, adjust as needed
        );
      }

      // Save tracking state to prevent duplicate tracking
      await prefs.setString('last_tracked_purchase_date', currentPurchaseDate);
      await prefs.setBool(
        'was_in_trial',
        entitlement.periodType == PeriodType.trial,
      );
    }

    // Update user properties for audience segmentation
    await AnalyticsService.setSubscriptionUserProperties(
      isSubscribed: true,
      subscriptionType: _getSubscriptionPeriod(entitlement.productIdentifier),
      isInTrial: entitlement.periodType == PeriodType.trial,
    );
  } catch (e) {
    // Silently fail - analytics errors should not interrupt app flow
  }
}

/// Helper to determine subscription period from product ID
String _getSubscriptionPeriod(String productId) {
  final lowerProductId = productId.toLowerCase();
  if (lowerProductId.contains('weekly') || lowerProductId.contains('week')) {
    return 'weekly';
  }
  if (lowerProductId.contains('monthly') || lowerProductId.contains('month')) {
    return 'monthly';
  }
  if (lowerProductId.contains('yearly') ||
      lowerProductId.contains('year') ||
      lowerProductId.contains('annual')) {
    return 'yearly';
  }
  return 'unknown';
}
