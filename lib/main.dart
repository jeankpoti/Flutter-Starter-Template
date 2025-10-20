import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:math_ai/features/account/presentation/sign_up_page.dart';
import 'package:math_ai/features/solve_math/data/repository/gemini_solve_math_repo.dart';
import 'package:math_ai/l10n/app_localizations.dart';
import 'package:math_ai/core/services/analytics_service.dart';
import 'package:math_ai/core/services/app_review_service.dart';
import 'package:math_ai/core/services/ad_service.dart';
import 'package:math_ai/features/ads/presentation/ad_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/study/presentation/study_page.dart';
import 'features/settings/data/preferences_service.dart';
import 'common_widgets/math_level_onboarding_dialog.dart';
import 'startup_widget.dart';

import 'features/account/data/repository/account_repo.dart';
import 'features/account/presentation/account_cubit.dart';
import 'features/account/presentation/reset_password_page.dart';
import 'features/account/presentation/sign_in_page.dart';
import 'features/locale/presentation/locale_cubit.dart';
import 'features/solve_math/data/repository/firebase_math_repo.dart';
import 'features/solve_math/domain/models/collection.dart';
import 'features/solve_math/presentation/collections_details_page.dart';
import 'features/solve_math/presentation/collections_page.dart';
import 'features/solve_math/presentation/firebase_collection_cubit.dart';
import 'features/solve_math/presentation/solve_math_cubit.dart';
import 'features/solve_math/presentation/image_capture_cubit.dart';
import 'features/subscription/data/repository/revenue_cat_repository.dart';
import 'features/subscription/presentation/subscription_cubit.dart';
import 'features/subscription/presentation/subscription_page.dart';
import 'features/common/presentation/permission_cubit.dart';
import 'firebase_options.dart';
import 'main_page.dart';
import 'onboarding_page.dart';
import 'settings_page.dart';
import 'theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Analytics Service (will check for permission internally)
  await AnalyticsService.initialize();
  
  // Initialize App Review Service (increments launch count)
  await AppReviewService.initialize();

  // Initialize Gemini Service
  final geminiService = GeminiSolveMathRepo();

  // Initialize RevenueCat
  final subscriptionRepository = RevenueCatRepository();
  await subscriptionRepository.initialize();

  // Initialize AdService
  final adService = AdService.instance;
  await AdService.initialize();

  // Initialize repositories in parallel
  await Future.wait([geminiService.initialize()]);

  final accountRepo = FirebaseRepo();

  final firebaseMathRepo = FirebaseMathRepo();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit(isDarkMode)),
        BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),
        BlocProvider<AccountCubit>(
          create: (context) => AccountCubit(accountRepo),
        ),

        BlocProvider<SolveMathCubit>(
          create: (context) => SolveMathCubit(geminiService, firebaseMathRepo, adService),
        ),

        BlocProvider<AdCubit>(
          create: (context) => AdCubit(adService),
        ),

        BlocProvider<FirebaseCollectionCubit>(
          create: (context) => FirebaseCollectionCubit(firebaseMathRepo),
        ),

        BlocProvider<SubscriptionCubit>(
          create: (context) => SubscriptionCubit(subscriptionRepository),
        ),

        BlocProvider<PermissionCubit>(create: (context) => PermissionCubit()),

        BlocProvider<ImageCaptureCubit>(
          create:
              (context) => ImageCaptureCubit(
                permissionCubit: context.read<PermissionCubit>(),
              ),
        ),
      ],
      child: const MyApp(),
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
              title: 'MathGenie AI',
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
  // splashPage,
  mainPage,
  homePage,
  studyPage,

  signInPage,
  signUpPage,
  resetPasswordPage,

  collectionsPage,
  collectionsDetailsPage,

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
                  return StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasData) {
                        // Check if it's first time to show math level dialog
                        return FutureBuilder<bool>(
                          future: PreferencesService.getInstance().then(
                            (prefs) => prefs.isFirstTime(),
                          ),
                          builder: (context, firstTimeSnapshot) {
                            if (firstTimeSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Scaffold(
                                body: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (firstTimeSnapshot.data == true) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder:
                                      (context) =>
                                          const MathLevelOnboardingDialog(),
                                );
                              });
                            }

                            return const StartupWidget();
                          },
                        );
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
          path: '/study',
          name: AppRoute.studyPage.name,
          pageBuilder:
              (context, state) => const NoTransitionPage(child: StudyPage()),
        ),
        GoRoute(
          path: '/collections',
          name: AppRoute.collectionsPage.name,
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: CollectionsPage()),
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
      path: '/collectionsDetails',
      name: AppRoute.collectionsDetailsPage.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        Collection collection =
            state.extra as Collection; // -> casting is important
        return CollectionsDetailsPage(collection: collection);
      },
    ),
    GoRoute(
      path: '/subscription',
      name: AppRoute.subscriptionPage.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SubscriptionPage(),
    ),
  ],
);
