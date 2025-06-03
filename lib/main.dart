import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:math_ai/features/account/presentation/sign_up_page.dart';
import 'package:math_ai/features/solve_math/data/repository/gemini_solve_math_repo.dart';
import 'package:math_ai/features/solve_math/domain/respository/firebase_collection_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/account/data/repository/account_repo.dart';
import 'features/account/presentation/account_cubit.dart';
import 'features/account/presentation/reset_password_page.dart';
import 'features/account/presentation/sign_in_page.dart';
import 'features/solve_math/data/repository/firebase_math_repo.dart';
import 'features/solve_math/domain/models/collection.dart';
import 'features/solve_math/presentation/collections_details_page.dart';
import 'features/solve_math/presentation/collections_page.dart';
import 'features/solve_math/presentation/firebase_collection_cubit.dart';
import 'features/solve_math/presentation/solve_math_cubit.dart';
import 'features/subscription/data/repository/revenue_cat_repository.dart';
import 'features/subscription/presentation/subscription_cubit.dart';
import 'features/subscription/presentation/subscription_page.dart';
import 'firebase_options.dart';
import 'main_page.dart';
import 'onboarding_page.dart';
import 'settings_page.dart';
import 'theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Gemini Service
  final geminiService = GeminiSolveMathRepo();

  // Initialize RevenueCat
  final subscriptionRepository = RevenueCatRepository();
  await subscriptionRepository.initialize();

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
        BlocProvider<AccountCubit>(
          create: (context) => AccountCubit(accountRepo),
        ),

        BlocProvider<SolveMathCubit>(
          create: (context) => SolveMathCubit(geminiService, firebaseMathRepo),
        ),

        BlocProvider<SubscriptionCubit>(
          create: (context) => SubscriptionCubit(subscriptionRepository),
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
        return MaterialApp.router(
          debugShowCheckedModeBanner: true,
          title: 'Snap Animal',
          theme: currentTheme,
          routerConfig: _router,
          // home: SigninPage(),
          // MainView(),
        );
      },
    );
  }
}

enum AppRoute {
  // splashPage,
  mainPage,

  signInPage,
  signUpPage,
  resetPasswordPage,

  collectionsPage,
  collectionsDetailsPage,

  subscriptionPage,

  onboardingPage,

  settingsPage,
}

// Define the routes
final GoRouter _router = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/sign-in',
      name: AppRoute.signInPage.name,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/sign-up',
      name: AppRoute.signUpPage.name,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/reset-password',
      name: AppRoute.resetPasswordPage.name,
      builder: (context, state) => const ResetPasswordPage(),
    ),

    // GoRoute(
    //   path: '/solve-math',
    //   name: AppRoute.identifyAnimalPage.name,
    //   builder: (context, state) => const IdentifyAnimalPage(),
    // ),
    // GoRoute(
    //   path: '/collection',
    //   name: AppRoute.identifiedPage.name,
    //   builder: (context, state) => const IdentifyAnimalPage(),
    //   routes: [
    //     GoRoute(
    //       path: 'identifiedAnimalsDetails',
    //       name: AppRoute.identifiedAnimalsDetailsPage.name,
    //       builder: (context, state) {
    //         Animal animal = state.extra as Animal; // -> casting is important
    //         return IdentifiedAnimalsDetailsPage(animal: animal);
    //       },
    //     ),
    //   ],
    // ),
    GoRoute(
      path: '/settings',
      name: AppRoute.settingsPage.name,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/subscription',
      name: AppRoute.subscriptionPage.name,
      builder: (context, state) => const SubscriptionPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: AppRoute.onboardingPage.name,
      builder: (context, state) => const OnboardingPage(),
    ),

    GoRoute(
      path: '/collections',
      name: AppRoute.collectionsPage.name,
      builder: (context, state) => const CollectionsPage(),
    ),

    GoRoute(
      path: '/collectionsDetails',
      name: AppRoute.collectionsDetailsPage.name,
      builder: (context, state) {
        Collection collection =
            state.extra as Collection; // -> casting is important
        return CollectionsDetailsPage(collection: collection);
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) {
        return FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, prefsSnapshot) {
            if (prefsSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final hasSeenOnboarding =
                prefsSnapshot.data?.getBool('hasSeenOnboarding') ?? false;

            if (!hasSeenOnboarding) {
              // Set the flag to true and show onboarding
              // prefsSnapshot.data?.setBool('hasSeenOnboarding', true);
              return const OnboardingPage();
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
                  // Get animals on first load
                  // context.read<FirebaseMathCubit>().getAnimals();

                  return MainPage();
                } else {
                  return const SignInPage();
                }
              },
            );
          },
        );
      },
      routes: [
        GoRoute(
          path: 'mainView',
          name: AppRoute.mainPage.name,
          builder: (context, state) {
            return const MainPage();
          },
        ),
      ],
    ),
  ],
);
