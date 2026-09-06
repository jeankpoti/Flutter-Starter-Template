import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? '**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @connectToAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect to your account'**
  String get connectToAccount;

  /// No description provided for @signInDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to sign in'**
  String get signInDescription;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @signUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name, email, and password'**
  String get signUpDescription;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign in with'**
  String get orSignInWith;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign up with'**
  String get orSignUpWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our '**
  String get termsAgreement;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @solve.
  ///
  /// In en, this message translates to:
  /// **'Solve'**
  String get solve;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @welcomeHome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeHome;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'This is your home screen. Customize it to showcase your app\'s main features.'**
  String get homeDescription;

  /// No description provided for @welcomeToApp.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the App!'**
  String get welcomeToApp;

  /// No description provided for @discoverFeatures.
  ///
  /// In en, this message translates to:
  /// **'Discover Features'**
  String get discoverFeatures;

  /// No description provided for @featureOne.
  ///
  /// In en, this message translates to:
  /// **'Feature One'**
  String get featureOne;

  /// No description provided for @featureOneDescription.
  ///
  /// In en, this message translates to:
  /// **'Description of your first feature goes here.'**
  String get featureOneDescription;

  /// No description provided for @featureTwo.
  ///
  /// In en, this message translates to:
  /// **'Feature Two'**
  String get featureTwo;

  /// No description provided for @featureTwoDescription.
  ///
  /// In en, this message translates to:
  /// **'Description of your second feature goes here.'**
  String get featureTwoDescription;

  /// No description provided for @featureThree.
  ///
  /// In en, this message translates to:
  /// **'Feature Three'**
  String get featureThree;

  /// No description provided for @featureThreeDescription.
  ///
  /// In en, this message translates to:
  /// **'Description of your third feature goes here.'**
  String get featureThreeDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCategory;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @featuredContent.
  ///
  /// In en, this message translates to:
  /// **'Featured Content'**
  String get featuredContent;

  /// No description provided for @contentItemOne.
  ///
  /// In en, this message translates to:
  /// **'Getting Started Guide'**
  String get contentItemOne;

  /// No description provided for @contentItemOneDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn the basics of using this app.'**
  String get contentItemOneDescription;

  /// No description provided for @contentItemTwo.
  ///
  /// In en, this message translates to:
  /// **'Video Tutorials'**
  String get contentItemTwo;

  /// No description provided for @contentItemTwoDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch step-by-step video guides.'**
  String get contentItemTwoDescription;

  /// No description provided for @contentItemThree.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get contentItemThree;

  /// No description provided for @contentItemThreeDescription.
  ///
  /// In en, this message translates to:
  /// **'Helpful tips to get the most out of the app.'**
  String get contentItemThreeDescription;

  /// No description provided for @exploreDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover new features and content here.'**
  String get exploreDescription;

  /// No description provided for @recentProblems.
  ///
  /// In en, this message translates to:
  /// **'Recent Problems'**
  String get recentProblems;

  /// No description provided for @studyMaterials.
  ///
  /// In en, this message translates to:
  /// **'Study Materials'**
  String get studyMaterials;

  /// No description provided for @solveMathProblem.
  ///
  /// In en, this message translates to:
  /// **'Solve Math Problem'**
  String get solveMathProblem;

  /// No description provided for @aiMathSolver.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Math Solver'**
  String get aiMathSolver;

  /// No description provided for @mathSolverDescription.
  ///
  /// In en, this message translates to:
  /// **'Capture or type any math problem and get instant solutions with step-by-step explanations'**
  String get mathSolverDescription;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @solveProblem.
  ///
  /// In en, this message translates to:
  /// **'Solve Problem'**
  String get solveProblem;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @mathSolution.
  ///
  /// In en, this message translates to:
  /// **'Math Solution'**
  String get mathSolution;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @captureOrUpload.
  ///
  /// In en, this message translates to:
  /// **'Capture or upload a math problem'**
  String get captureOrUpload;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @analyzingProblem.
  ///
  /// In en, this message translates to:
  /// **'Analyzing problem...'**
  String get analyzingProblem;

  /// No description provided for @typeMathProblem.
  ///
  /// In en, this message translates to:
  /// **'Type your math problem'**
  String get typeMathProblem;

  /// No description provided for @enterMathProblem.
  ///
  /// In en, this message translates to:
  /// **'Enter your math problem here...'**
  String get enterMathProblem;

  /// No description provided for @solving.
  ///
  /// In en, this message translates to:
  /// **'Solving...'**
  String get solving;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes, so double check the solution!'**
  String get aiDisclaimer;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @studyMaterialsDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload study materials and let AI extract key topics'**
  String get studyMaterialsDescription;

  /// No description provided for @generateQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Generate personalized quizzes from your study materials'**
  String get generateQuizzes;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get changeTheme;

  /// No description provided for @mathLevel.
  ///
  /// In en, this message translates to:
  /// **'Math Level'**
  String get mathLevel;

  /// No description provided for @mathLevelDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your education level for personalized explanations'**
  String get mathLevelDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @frenchLanguage.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get frenchLanguage;

  /// No description provided for @spanishLanguage.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanishLanguage;

  /// No description provided for @elementary.
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get elementary;

  /// No description provided for @elementaryAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Ages 6-11'**
  String get elementaryAgeRange;

  /// No description provided for @elementaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Simple explanations with easy words'**
  String get elementaryDescription;

  /// No description provided for @middleSchool.
  ///
  /// In en, this message translates to:
  /// **'Middle School'**
  String get middleSchool;

  /// No description provided for @middleSchoolAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Ages 12-14'**
  String get middleSchoolAgeRange;

  /// No description provided for @middleSchoolDescription.
  ///
  /// In en, this message translates to:
  /// **'Clear explanations with guided reasoning'**
  String get middleSchoolDescription;

  /// No description provided for @highSchool.
  ///
  /// In en, this message translates to:
  /// **'High School'**
  String get highSchool;

  /// No description provided for @highSchoolAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Ages 14-18'**
  String get highSchoolAgeRange;

  /// No description provided for @highSchoolDescription.
  ///
  /// In en, this message translates to:
  /// **'Standard mathematical explanations'**
  String get highSchoolDescription;

  /// No description provided for @college.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get college;

  /// No description provided for @collegeAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Ages 18+'**
  String get collegeAgeRange;

  /// No description provided for @collegeDescription.
  ///
  /// In en, this message translates to:
  /// **'Advanced mathematical concepts'**
  String get collegeDescription;

  /// No description provided for @getPremium.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get getPremium;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Love the app? Rate us on the App Store!'**
  String get rateUs;

  /// No description provided for @shareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriends;

  /// No description provided for @privacyPolicyTerms.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy & Terms of Use'**
  String get privacyPolicyTerms;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get premiumSubscription;

  /// No description provided for @activeSubscription.
  ///
  /// In en, this message translates to:
  /// **'You have an active subscription!'**
  String get activeSubscription;

  /// No description provided for @enjoyPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all premium features'**
  String get enjoyPremiumFeatures;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @cancelTrial.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trial'**
  String get cancelTrial;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @unlockFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and remove ads'**
  String get unlockFeatures;

  /// No description provided for @freeTrialOffer.
  ///
  /// In en, this message translates to:
  /// **'Start with a 3-day free trial'**
  String get freeTrialOffer;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @unlimitedProblems.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Problems'**
  String get unlimitedProblems;

  /// No description provided for @unlimitedProblemsDesc.
  ///
  /// In en, this message translates to:
  /// **'Solve as many as you need'**
  String get unlimitedProblemsDesc;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// No description provided for @cloudSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Access anywhere, anytime'**
  String get cloudSyncDesc;

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// No description provided for @advancedAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed learning insights'**
  String get advancedAnalyticsDesc;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide your email'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide a password'**
  String get passwordRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide your full name'**
  String get fullNameRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get somethingWentWrong;

  /// No description provided for @signOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sign out successfully!'**
  String get signOutSuccess;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Please sign in.'**
  String get accountCreatedSuccess;

  /// No description provided for @couldNotOpenPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Could not open Privacy Policy'**
  String get couldNotOpenPrivacyPolicy;

  /// No description provided for @couldNotOpenTerms.
  ///
  /// In en, this message translates to:
  /// **'Could not open Terms of Use'**
  String get couldNotOpenTerms;

  /// No description provided for @failedToLoadProblems.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more problems'**
  String get failedToLoadProblems;

  /// No description provided for @mathSolvingError.
  ///
  /// In en, this message translates to:
  /// **'Error solving math problem. Please try again.'**
  String get mathSolvingError;

  /// No description provided for @enterMathProblemError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a math problem to solve.'**
  String get enterMathProblemError;

  /// No description provided for @nonMathContentError.
  ///
  /// In en, this message translates to:
  /// **'This image does not contain mathematical material. Please upload an image with math problems, equations, or mathematical concepts.'**
  String get nonMathContentError;

  /// No description provided for @nonMathTextError.
  ///
  /// In en, this message translates to:
  /// **'This text does not contain mathematical material. Please submit text with math problems, equations, or mathematical concepts.'**
  String get nonMathTextError;

  /// No description provided for @subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Subscription Error'**
  String get subscriptionError;

  /// No description provided for @takePictureError.
  ///
  /// In en, this message translates to:
  /// **'Failed to take picture. Please try again.'**
  String get takePictureError;

  /// No description provided for @uploadPictureError.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload picture. Please try again.'**
  String get uploadPictureError;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Failed to share result. Please try again.'**
  String get shareError;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @enableAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable access in your device settings to continue.'**
  String get enableAccessMessage;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @personalAiTutor.
  ///
  /// In en, this message translates to:
  /// **'Your Personal AI Math Tutor'**
  String get personalAiTutor;

  /// No description provided for @solveInstantly.
  ///
  /// In en, this message translates to:
  /// **'Solve any math problem instantly'**
  String get solveInstantly;

  /// No description provided for @smartStudyMaterials.
  ///
  /// In en, this message translates to:
  /// **'Smart Study Materials'**
  String get smartStudyMaterials;

  /// No description provided for @organizeContent.
  ///
  /// In en, this message translates to:
  /// **'Organize & analyze your content'**
  String get organizeContent;

  /// No description provided for @aiGeneratedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'AI-Generated Quizzes'**
  String get aiGeneratedQuizzes;

  /// No description provided for @testKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge effectively'**
  String get testKnowledge;

  /// No description provided for @unlockPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock Your Math Potential'**
  String get unlockPotential;

  /// No description provided for @premiumFeaturesAwait.
  ///
  /// In en, this message translates to:
  /// **'Premium features await'**
  String get premiumFeaturesAwait;

  /// No description provided for @welcomeToMathAi.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Math AI!'**
  String get welcomeToMathAi;

  /// No description provided for @selectEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Please select your education level for personalized explanations'**
  String get selectEducationLevel;

  /// No description provided for @changeAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings'**
  String get changeAnytime;

  /// No description provided for @noSolvedProblems.
  ///
  /// In en, this message translates to:
  /// **'No solved problems yet! Solve your first math problem to see it here.'**
  String get noSolvedProblems;

  /// No description provided for @noMoreProblems.
  ///
  /// In en, this message translates to:
  /// **'No more problems to load'**
  String get noMoreProblems;

  /// No description provided for @noMoreItems.
  ///
  /// In en, this message translates to:
  /// **'No more items'**
  String get noMoreItems;

  /// No description provided for @questionsReview.
  ///
  /// In en, this message translates to:
  /// **'Questions Review'**
  String get questionsReview;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @unanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unanswered;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @shareResults.
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get shareResults;

  /// No description provided for @tipsForBetterResults.
  ///
  /// In en, this message translates to:
  /// **'Tips for better results'**
  String get tipsForBetterResults;

  /// No description provided for @beSpecificTip.
  ///
  /// In en, this message translates to:
  /// **'Be specific with your question (e.g., \"Solve for x\")'**
  String get beSpecificTip;

  /// No description provided for @useProperNotationTip.
  ///
  /// In en, this message translates to:
  /// **'Use proper mathematical notation'**
  String get useProperNotationTip;

  /// No description provided for @includeNecessaryInfoTip.
  ///
  /// In en, this message translates to:
  /// **'Include all necessary information'**
  String get includeNecessaryInfoTip;

  /// No description provided for @exampleProblem.
  ///
  /// In en, this message translates to:
  /// **'Example:\n2x + 5 = 15\nSolve for x'**
  String get exampleProblem;

  /// No description provided for @studyMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Materials'**
  String get studyMaterialsTitle;

  /// No description provided for @uploadTab.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadTab;

  /// No description provided for @myMaterialsTab.
  ///
  /// In en, this message translates to:
  /// **'My Materials'**
  String get myMaterialsTab;

  /// No description provided for @flashcardsTab.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcardsTab;

  /// No description provided for @uploadYourStudyMaterial.
  ///
  /// In en, this message translates to:
  /// **'Upload Your Study Material'**
  String get uploadYourStudyMaterial;

  /// No description provided for @uploadDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload textbook pages, class notes, homework, or any math material. Our AI will create a personalized study plan just for you!'**
  String get uploadDescription;

  /// No description provided for @takePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture textbook pages, notes, or worksheets'**
  String get takePhotoSubtitle;

  /// No description provided for @uploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get uploadFromGallery;

  /// No description provided for @uploadFromGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select images from your photo library'**
  String get uploadFromGallerySubtitle;

  /// No description provided for @typeMaterial.
  ///
  /// In en, this message translates to:
  /// **'Type Material'**
  String get typeMaterial;

  /// No description provided for @typeMaterialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter text directly or paste from clipboard'**
  String get typeMaterialSubtitle;

  /// No description provided for @recentUploads.
  ///
  /// In en, this message translates to:
  /// **'Recent Uploads'**
  String get recentUploads;

  /// No description provided for @noMaterialsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No materials uploaded yet'**
  String get noMaterialsUploaded;

  /// No description provided for @uploadFirstMaterial.
  ///
  /// In en, this message translates to:
  /// **'Upload your first study material to get started!'**
  String get uploadFirstMaterial;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @myStudyMaterials.
  ///
  /// In en, this message translates to:
  /// **'My Study Materials'**
  String get myStudyMaterials;

  /// No description provided for @noStudyMaterials.
  ///
  /// In en, this message translates to:
  /// **'No Study Materials'**
  String get noStudyMaterials;

  /// No description provided for @noStudyMaterialsDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your first material to see it here and start building your personalized study plan.'**
  String get noStudyMaterialsDescription;

  /// No description provided for @myStudyPlans.
  ///
  /// In en, this message translates to:
  /// **'My Study Plans'**
  String get myStudyPlans;

  /// No description provided for @deletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get deletePlan;

  /// No description provided for @viewTopics.
  ///
  /// In en, this message translates to:
  /// **'View Topics'**
  String get viewTopics;

  /// No description provided for @takeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get takeQuiz;

  /// No description provided for @processingYourMaterial.
  ///
  /// In en, this message translates to:
  /// **'Processing Your Material'**
  String get processingYourMaterial;

  /// No description provided for @processingDescription.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing your content and creating a personalized study plan...'**
  String get processingDescription;

  /// No description provided for @uploadStep.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadStep;

  /// No description provided for @analyzeStep.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyzeStep;

  /// No description provided for @practiceQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Practice Quizzes'**
  String get practiceQuizzes;

  /// No description provided for @testYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Test Your Knowledge'**
  String get testYourKnowledge;

  /// No description provided for @testKnowledgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate AI-powered quizzes based on your study materials to test your understanding and identify areas for improvement.'**
  String get testKnowledgeDescription;

  /// No description provided for @quickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz'**
  String get quickQuiz;

  /// No description provided for @quickQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'5 questions • 10 min'**
  String get quickQuizSubtitle;

  /// No description provided for @practiceTest.
  ///
  /// In en, this message translates to:
  /// **'Practice Test'**
  String get practiceTest;

  /// No description provided for @practiceTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'10 questions • 20 min'**
  String get practiceTestSubtitle;

  /// No description provided for @challengeMode.
  ///
  /// In en, this message translates to:
  /// **'Challenge Mode'**
  String get challengeMode;

  /// No description provided for @challengeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'15 questions • 30 min • Based on study plan'**
  String get challengeModeSubtitle;

  /// No description provided for @errorLoadingStudyData.
  ///
  /// In en, this message translates to:
  /// **'Error loading your study data'**
  String get errorLoadingStudyData;

  /// No description provided for @quizHistory.
  ///
  /// In en, this message translates to:
  /// **'Quiz History'**
  String get quizHistory;

  /// No description provided for @searchQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Search quizzes...'**
  String get searchQuizzes;

  /// No description provided for @filterQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Filter Quizzes'**
  String get filterQuizzes;

  /// No description provided for @sortQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Sort Quizzes'**
  String get sortQuizzes;

  /// No description provided for @noQuizHistory.
  ///
  /// In en, this message translates to:
  /// **'No Quiz History'**
  String get noQuizHistory;

  /// No description provided for @noQuizHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take your first quiz to see it here!'**
  String get noQuizHistorySubtitle;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFound;

  /// No description provided for @noResultsFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter criteria.'**
  String get noResultsFoundSubtitle;

  /// No description provided for @loadingQuizHistory.
  ///
  /// In en, this message translates to:
  /// **'Loading quiz history...'**
  String get loadingQuizHistory;

  /// No description provided for @errorInitializingQuizService.
  ///
  /// In en, this message translates to:
  /// **'Error initializing quiz service'**
  String get errorInitializingQuizService;

  /// No description provided for @errorLoadingQuizData.
  ///
  /// In en, this message translates to:
  /// **'Error loading quiz data'**
  String get errorLoadingQuizData;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// No description provided for @attempts.
  ///
  /// In en, this message translates to:
  /// **'attempts'**
  String get attempts;

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String completedOn(Object date);

  /// No description provided for @quizStatistics.
  ///
  /// In en, this message translates to:
  /// **'Quiz Statistics'**
  String get quizStatistics;

  /// No description provided for @totalQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Total Quizzes'**
  String get totalQuizzes;

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScore;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @detailedStatistics.
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get detailedStatistics;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Questions Answered'**
  String get questionsAnswered;

  /// No description provided for @totalQuestionsAttempted.
  ///
  /// In en, this message translates to:
  /// **'Total questions attempted'**
  String get totalQuestionsAttempted;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get correctAnswers;

  /// No description provided for @questionsAnsweredCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Questions answered correctly'**
  String get questionsAnsweredCorrectly;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @performanceTrends.
  ///
  /// In en, this message translates to:
  /// **'Performance Trends (Last 30 Days)'**
  String get performanceTrends;

  /// No description provided for @daysWithActivity.
  ///
  /// In en, this message translates to:
  /// **'days with activity'**
  String get daysWithActivity;

  /// No description provided for @averageScoreTrend.
  ///
  /// In en, this message translates to:
  /// **'Average Score Trend'**
  String get averageScoreTrend;

  /// No description provided for @progressInsights.
  ///
  /// In en, this message translates to:
  /// **'Progress Insights'**
  String get progressInsights;

  /// No description provided for @recentPerformance.
  ///
  /// In en, this message translates to:
  /// **'Recent Performance'**
  String get recentPerformance;

  /// No description provided for @activityPattern.
  ///
  /// In en, this message translates to:
  /// **'Activity Pattern'**
  String get activityPattern;

  /// No description provided for @activityPatternDescription.
  ///
  /// In en, this message translates to:
  /// **'You completed quizzes on {count} different days this month.'**
  String activityPatternDescription(Object count);

  /// No description provided for @noProgressData.
  ///
  /// In en, this message translates to:
  /// **'No Progress Data'**
  String get noProgressData;

  /// No description provided for @noProgressDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take more quizzes to see your progress trends!'**
  String get noProgressDataSubtitle;

  /// No description provided for @performanceImprovement.
  ///
  /// In en, this message translates to:
  /// **'Great improvement! Your scores are trending upward.'**
  String get performanceImprovement;

  /// No description provided for @performanceDecline.
  ///
  /// In en, this message translates to:
  /// **'Your recent scores have dipped. Keep practicing to improve!'**
  String get performanceDecline;

  /// No description provided for @performanceConsistent.
  ///
  /// In en, this message translates to:
  /// **'Your performance is consistent. Keep up the good work!'**
  String get performanceConsistent;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @takeMoreQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Take more quizzes to see performance trends.'**
  String get takeMoreQuizzes;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @completedFilter.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedFilter;

  /// No description provided for @inProgressFilter.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressFilter;

  /// No description provided for @easyFilter.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easyFilter;

  /// No description provided for @mediumFilter.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumFilter;

  /// No description provided for @hardFilter.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hardFilter;

  /// No description provided for @newestSort.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newestSort;

  /// No description provided for @oldestSort.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldestSort;

  /// No description provided for @highScoreSort.
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get highScoreSort;

  /// No description provided for @lowScoreSort.
  ///
  /// In en, this message translates to:
  /// **'Low Score'**
  String get lowScoreSort;

  /// No description provided for @azSort.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get azSort;

  /// No description provided for @zaSort.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get zaSort;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} result'**
  String resultsCount(Object count);

  /// No description provided for @resultsCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCountPlural(Object count);

  /// No description provided for @quizReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Review: {title}'**
  String quizReviewTitle(Object title);

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String score(Object score);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed: {date}'**
  String completed(Object date);

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsCount(Object count);

  /// No description provided for @pointsValue.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsValue(Object points);

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctAnswer;

  /// No description provided for @yourAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Answer:'**
  String get yourAnswerLabel;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer:'**
  String get correctAnswerLabel;

  /// No description provided for @questionNotAnswered.
  ///
  /// In en, this message translates to:
  /// **'Question was not answered'**
  String get questionNotAnswered;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(Object time);

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String yesterdayAt(Object time);

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @quizResultsShare.
  ///
  /// In en, this message translates to:
  /// **'Quiz Results: {title}'**
  String quizResultsShare(Object title);

  /// No description provided for @shareScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String shareScore(Object score);

  /// No description provided for @shareCorrect.
  ///
  /// In en, this message translates to:
  /// **'✅ Correct: {count}'**
  String shareCorrect(Object count);

  /// No description provided for @shareIncorrect.
  ///
  /// In en, this message translates to:
  /// **'❌ Incorrect: {count}'**
  String shareIncorrect(Object count);

  /// No description provided for @shareUnanswered.
  ///
  /// In en, this message translates to:
  /// **'⚪ Unanswered: {count}'**
  String shareUnanswered(Object count);

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total Questions: {count}'**
  String totalQuestions(Object count);

  /// No description provided for @shareFunctionality.
  ///
  /// In en, this message translates to:
  /// **'Share functionality would open here\n\n{shareText}'**
  String shareFunctionality(Object shareText);

  /// No description provided for @noQuestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No questions available'**
  String get noQuestionsAvailable;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(Object current, Object total);

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'point'**
  String get point;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @concept.
  ///
  /// In en, this message translates to:
  /// **'concept'**
  String get concept;

  /// No description provided for @concepts.
  ///
  /// In en, this message translates to:
  /// **'concepts'**
  String get concepts;

  /// No description provided for @problem.
  ///
  /// In en, this message translates to:
  /// **'problem'**
  String get problem;

  /// No description provided for @problems.
  ///
  /// In en, this message translates to:
  /// **'problems'**
  String get problems;

  /// No description provided for @pointsDisplay.
  ///
  /// In en, this message translates to:
  /// **'{count} {points}'**
  String pointsDisplay(Object count, Object points);

  /// No description provided for @hintLabel.
  ///
  /// In en, this message translates to:
  /// **'Hint: {hint}'**
  String hintLabel(Object hint);

  /// No description provided for @selectCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select the correct answer:'**
  String get selectCorrectAnswer;

  /// No description provided for @selectTrueFalse.
  ///
  /// In en, this message translates to:
  /// **'Select True or False:'**
  String get selectTrueFalse;

  /// No description provided for @enterYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer:'**
  String get enterYourAnswer;

  /// No description provided for @typeAnswerHere.
  ///
  /// In en, this message translates to:
  /// **'Type your answer here...'**
  String get typeAnswerHere;

  /// No description provided for @fillInBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank:'**
  String get fillInBlank;

  /// No description provided for @enterMissingWord.
  ///
  /// In en, this message translates to:
  /// **'Enter the missing word or expression...'**
  String get enterMissingWord;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finishQuiz.
  ///
  /// In en, this message translates to:
  /// **'Finish Quiz'**
  String get finishQuiz;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed!'**
  String get quizCompleted;

  /// No description provided for @backToStudy.
  ///
  /// In en, this message translates to:
  /// **'Back to Study'**
  String get backToStudy;

  /// No description provided for @retakeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get retakeQuiz;

  /// No description provided for @performanceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Performance Breakdown'**
  String get performanceBreakdown;

  /// No description provided for @viewDetailedReview.
  ///
  /// In en, this message translates to:
  /// **'View Detailed Review'**
  String get viewDetailedReview;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get multipleChoice;

  /// No description provided for @shortAnswer.
  ///
  /// In en, this message translates to:
  /// **'Short Answer'**
  String get shortAnswer;

  /// No description provided for @trueFalse.
  ///
  /// In en, this message translates to:
  /// **'True/False'**
  String get trueFalse;

  /// No description provided for @fillInTheBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the Blank'**
  String get fillInTheBlank;

  /// No description provided for @excellentWork.
  ///
  /// In en, this message translates to:
  /// **'Excellent work! You have mastered this material.'**
  String get excellentWork;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job! You have a solid understanding.'**
  String get greatJob;

  /// No description provided for @goodWork.
  ///
  /// In en, this message translates to:
  /// **'Good work! Consider reviewing some topics.'**
  String get goodWork;

  /// No description provided for @fairPerformance.
  ///
  /// In en, this message translates to:
  /// **'Fair performance. Some additional study recommended.'**
  String get fairPerformance;

  /// No description provided for @reviewMaterial.
  ///
  /// In en, this message translates to:
  /// **'Consider reviewing the material and retaking the quiz.'**
  String get reviewMaterial;

  /// No description provided for @exitQuiz.
  ///
  /// In en, this message translates to:
  /// **'Exit Quiz?'**
  String get exitQuiz;

  /// No description provided for @exitQuizConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your progress will be lost.'**
  String get exitQuizConfirmation;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @quizResultsSaved.
  ///
  /// In en, this message translates to:
  /// **'Quiz results saved to history'**
  String get quizResultsSaved;

  /// No description provided for @failedToSaveResults.
  ///
  /// In en, this message translates to:
  /// **'Failed to save quiz results: {error}'**
  String failedToSaveResults(Object error);

  /// No description provided for @problemsDetails.
  ///
  /// In en, this message translates to:
  /// **'Problems Details'**
  String get problemsDetails;

  /// No description provided for @couldNotLoadMoreProblems.
  ///
  /// In en, this message translates to:
  /// **'Could not load more problems.'**
  String get couldNotLoadMoreProblems;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @failedToLoadMoreProblems.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more problems'**
  String get failedToLoadMoreProblems;

  /// No description provided for @noSolvedProblemsYet.
  ///
  /// In en, this message translates to:
  /// **'No solved problems yet! Solve your first math problem to see it here.'**
  String get noSolvedProblemsYet;

  /// No description provided for @noMoreProblemsToLoad.
  ///
  /// In en, this message translates to:
  /// **'No more problems to load'**
  String get noMoreProblemsToLoad;

  /// No description provided for @copySolution.
  ///
  /// In en, this message translates to:
  /// **'Copy Solution'**
  String get copySolution;

  /// No description provided for @shareSolution.
  ///
  /// In en, this message translates to:
  /// **'Share Solution'**
  String get shareSolution;

  /// No description provided for @solutionCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Solution copied to clipboard!'**
  String get solutionCopiedToClipboard;

  /// No description provided for @unableToCopySolution.
  ///
  /// In en, this message translates to:
  /// **'Unable to copy solution'**
  String get unableToCopySolution;

  /// No description provided for @unableToShareSolution.
  ///
  /// In en, this message translates to:
  /// **'Unable to share solution'**
  String get unableToShareSolution;

  /// No description provided for @mathProblemSolution.
  ///
  /// In en, this message translates to:
  /// **'Math Problem Solution'**
  String get mathProblemSolution;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Math Problem Solution:\n\n{solution}'**
  String shareText(Object solution);

  /// No description provided for @mathAiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Math AI can make mistakes, so double check the solution!'**
  String get mathAiDisclaimer;

  /// No description provided for @mathLevelUpdated.
  ///
  /// In en, this message translates to:
  /// **'Math level updated to {level}'**
  String mathLevelUpdated(Object level);

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be deleted. Please type \"DELETE\" to confirm.'**
  String get deleteAccountConfirmation;

  /// No description provided for @typeDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE'**
  String get typeDeleteHint;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteText;

  /// No description provided for @deleteConfirmationError.
  ///
  /// In en, this message translates to:
  /// **'Please type DELETE to confirm'**
  String get deleteConfirmationError;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedTo(Object language);

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'Check out this amazing app: {url}'**
  String shareAppText(Object url);

  /// No description provided for @generatePlan.
  ///
  /// In en, this message translates to:
  /// **'Generate Plan'**
  String get generatePlan;

  /// No description provided for @generateQuizWithAllMaterials.
  ///
  /// In en, this message translates to:
  /// **'Generate Quiz with All Materials'**
  String get generateQuizWithAllMaterials;

  /// No description provided for @addStudyMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add Study Material'**
  String get addStudyMaterial;

  /// No description provided for @addMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add Material'**
  String get addMaterial;

  /// No description provided for @studyPlanCreated.
  ///
  /// In en, this message translates to:
  /// **'Study plan \"{title}\" created!'**
  String studyPlanCreated(Object title);

  /// No description provided for @noStudyMaterialsForQuiz.
  ///
  /// In en, this message translates to:
  /// **'No study materials or plans available for quiz generation'**
  String get noStudyMaterialsForQuiz;

  /// No description provided for @noStudyMaterialsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No study materials available to generate quiz from'**
  String get noStudyMaterialsAvailable;

  /// No description provided for @selectStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Study Plan'**
  String get selectStudyPlan;

  /// No description provided for @generatingQuizFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Generating quiz from \"{title}\" with {count} questions...'**
  String generatingQuizFromPlan(Object count, Object title);

  /// No description provided for @studyPlanDeleted.
  ///
  /// In en, this message translates to:
  /// **'Study plan deleted'**
  String get studyPlanDeleted;

  /// No description provided for @errorDeletingStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Error deleting study plan: {error}'**
  String errorDeletingStudyPlan(Object error);

  /// No description provided for @errorGeneratingStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Error generating study plan: {error}'**
  String errorGeneratingStudyPlan(Object error);

  /// No description provided for @totalTopics.
  ///
  /// In en, this message translates to:
  /// **'Total Topics'**
  String get totalTopics;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @keyConcepts.
  ///
  /// In en, this message translates to:
  /// **'Key Concepts'**
  String get keyConcepts;

  /// No description provided for @aiExplanation.
  ///
  /// In en, this message translates to:
  /// **'AI Explanation'**
  String get aiExplanation;

  /// No description provided for @practiceProblems.
  ///
  /// In en, this message translates to:
  /// **'Practice Problems'**
  String get practiceProblems;

  /// No description provided for @prerequisites.
  ///
  /// In en, this message translates to:
  /// **'Prerequisites'**
  String get prerequisites;

  /// No description provided for @unknownTopic.
  ///
  /// In en, this message translates to:
  /// **'Unknown Topic'**
  String get unknownTopic;

  /// No description provided for @startTopic.
  ///
  /// In en, this message translates to:
  /// **'Start Topic'**
  String get startTopic;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @markIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Incomplete'**
  String get markIncomplete;

  /// No description provided for @enterStudyMaterialText.
  ///
  /// In en, this message translates to:
  /// **'Enter your study material text:'**
  String get enterStudyMaterialText;

  /// No description provided for @processingTextMaterial.
  ///
  /// In en, this message translates to:
  /// **'Processing text material...'**
  String get processingTextMaterial;

  /// No description provided for @generatingComprehensiveQuiz.
  ///
  /// In en, this message translates to:
  /// **'Generating comprehensive quiz from all your study materials...'**
  String get generatingComprehensiveQuiz;

  /// No description provided for @chooseStudyPlanForQuiz.
  ///
  /// In en, this message translates to:
  /// **'Choose which study plan to generate the quiz from:'**
  String get chooseStudyPlanForQuiz;

  /// No description provided for @generatingQuiz.
  ///
  /// In en, this message translates to:
  /// **'Generating quiz...'**
  String get generatingQuiz;

  /// No description provided for @completeTheseTopicsFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete these topics first:'**
  String get completeTheseTopicsFirst;

  /// No description provided for @topicCompleted.
  ///
  /// In en, this message translates to:
  /// **'Topic Completed!'**
  String get topicCompleted;

  /// No description provided for @allMaterialsQuizDescription.
  ///
  /// In en, this message translates to:
  /// **'12 questions • 25 min • All study materials included'**
  String get allMaterialsQuizDescription;

  /// No description provided for @allStudyMaterials.
  ///
  /// In en, this message translates to:
  /// **'All Study Materials'**
  String get allStudyMaterials;

  /// No description provided for @generateFromAllMaterials.
  ///
  /// In en, this message translates to:
  /// **'Generate quiz from all uploaded materials'**
  String get generateFromAllMaterials;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @topicStarted.
  ///
  /// In en, this message translates to:
  /// **'📚 Topic started!'**
  String get topicStarted;

  /// No description provided for @materialCaptured.
  ///
  /// In en, this message translates to:
  /// **'📷 Material captured! Starting AI analysis...'**
  String get materialCaptured;

  /// No description provided for @errorCapturingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error capturing photo: {error}'**
  String errorCapturingPhoto(Object error);

  /// No description provided for @materialsUploaded.
  ///
  /// In en, this message translates to:
  /// **'📱 {count} material(s) uploaded! Starting AI analysis...'**
  String materialsUploaded(Object count);

  /// No description provided for @errorUploadingFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Error uploading from gallery: {error}'**
  String errorUploadingFromGallery(Object error);

  /// No description provided for @studyMaterialTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Material {number}'**
  String studyMaterialTitle(Object number);

  /// No description provided for @textMaterialTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Material {number}'**
  String textMaterialTitle(Object number);

  /// No description provided for @materialAnalyzedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Material analyzed successfully! Study plan created!'**
  String get materialAnalyzedSuccess;

  /// No description provided for @errorProcessingMaterial.
  ///
  /// In en, this message translates to:
  /// **'Error processing material: {error}'**
  String errorProcessingMaterial(Object error);

  /// No description provided for @permissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'{permission} Permission Required'**
  String permissionRequiredTitle(Object permission);

  /// No description provided for @permissionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable {permission} access in your device settings to upload study materials.'**
  String permissionRequiredMessage(Object permission);

  /// No description provided for @pasteOrTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Paste or type your math content here...\n\nExample:\n• Chapter 5: Quadratic Equations\n• Solving ax² + bx + c = 0\n• Practice problems 1-15'**
  String get pasteOrTypeHint;

  /// No description provided for @generatingQuizWithCount.
  ///
  /// In en, this message translates to:
  /// **'Generating quiz with {count} questions...'**
  String generatingQuizWithCount(Object count);

  /// No description provided for @errorGeneratingQuiz.
  ///
  /// In en, this message translates to:
  /// **'Error generating quiz: {error}'**
  String errorGeneratingQuiz(Object error);

  /// No description provided for @errorGeneratingComprehensiveQuiz.
  ///
  /// In en, this message translates to:
  /// **'Error generating comprehensive quiz: {error}'**
  String errorGeneratingComprehensiveQuiz(Object error);

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan: {title}'**
  String planTitle(Object title);

  /// No description provided for @process.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get process;

  /// No description provided for @progressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Progress updated: {progress}%'**
  String progressUpdated(Object progress);

  /// No description provided for @errorUpdatingProgress.
  ///
  /// In en, this message translates to:
  /// **'Error updating progress: {error}'**
  String errorUpdatingProgress(Object error);

  /// No description provided for @topicMarkedComplete.
  ///
  /// In en, this message translates to:
  /// **'✅ Topic marked as complete!'**
  String get topicMarkedComplete;

  /// No description provided for @errorMarkingTopicComplete.
  ///
  /// In en, this message translates to:
  /// **'Error marking topic complete: {error}'**
  String errorMarkingTopicComplete(Object error);

  /// No description provided for @errorStartingTopic.
  ///
  /// In en, this message translates to:
  /// **'Error starting topic: {error}'**
  String errorStartingTopic(Object error);

  /// No description provided for @comprehensiveQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Quiz - All Materials'**
  String get comprehensiveQuizTitle;

  /// No description provided for @daysAgoFormat.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgoFormat(Object days);

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year}'**
  String dateFormat(Object day, Object month, Object year);

  /// No description provided for @maxMaterialsReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum of {count} study materials allowed'**
  String maxMaterialsReached(Object count);

  /// No description provided for @maxMaterialsHint.
  ///
  /// In en, this message translates to:
  /// **'Select up to {count} of your most important study materials for best results'**
  String maxMaterialsHint(Object count);

  /// No description provided for @reviewMainConcepts.
  ///
  /// In en, this message translates to:
  /// **'Review and understand the main concepts of {topic}'**
  String reviewMainConcepts(Object topic);

  /// No description provided for @practiceExercisesFocusing.
  ///
  /// In en, this message translates to:
  /// **'Practice exercises focusing on {concepts}'**
  String practiceExercisesFocusing(Object concepts);

  /// No description provided for @workThroughProblems.
  ///
  /// In en, this message translates to:
  /// **'Work through problems involving {concepts}'**
  String workThroughProblems(Object concepts);

  /// No description provided for @completeWorksheets.
  ///
  /// In en, this message translates to:
  /// **'Complete practice worksheets or textbook exercises on {topic}'**
  String completeWorksheets(Object topic);

  /// No description provided for @takeTopicQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take a quiz or self-assessment on this topic'**
  String get takeTopicQuiz;

  /// No description provided for @errorAnalyzingContent.
  ///
  /// In en, this message translates to:
  /// **'Error analyzing content. Please try again.'**
  String get errorAnalyzingContent;

  /// No description provided for @analyzingContent.
  ///
  /// In en, this message translates to:
  /// **'Analyzing content...'**
  String get analyzingContent;

  /// No description provided for @unableToAnalyzeContent.
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze content'**
  String get unableToAnalyzeContent;

  /// No description provided for @unableToAnalyzeImage.
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze image content: {error}'**
  String unableToAnalyzeImage(Object error);

  /// No description provided for @targetCompletionDate.
  ///
  /// In en, this message translates to:
  /// **'Target completion date: {date}'**
  String targetCompletionDate(Object date);

  /// No description provided for @noSpecificTargetDate.
  ///
  /// In en, this message translates to:
  /// **'No specific target date'**
  String get noSpecificTargetDate;

  /// No description provided for @unableToGenerateStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate study plan'**
  String get unableToGenerateStudyPlan;

  /// No description provided for @studyPlanSingle.
  ///
  /// In en, this message translates to:
  /// **'Study Plan: {title}'**
  String studyPlanSingle(Object title);

  /// No description provided for @studyPlanMultiple.
  ///
  /// In en, this message translates to:
  /// **'Study Plan: {count} Materials'**
  String studyPlanMultiple(Object count);

  /// No description provided for @aiGeneratedStudyPlanDescription.
  ///
  /// In en, this message translates to:
  /// **'AI-generated study plan based on your uploaded materials'**
  String get aiGeneratedStudyPlanDescription;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @uploadFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select files from your device'**
  String get uploadFileSubtitle;

  /// No description provided for @extracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting'**
  String get extracting;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing'**
  String get analyzing;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get generating;

  /// No description provided for @typeText.
  ///
  /// In en, this message translates to:
  /// **'Type Text'**
  String get typeText;

  /// No description provided for @typeTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter text directly or paste from clipboard'**
  String get typeTextSubtitle;

  /// No description provided for @noRecentUploads.
  ///
  /// In en, this message translates to:
  /// **'No Recent Uploads'**
  String get noRecentUploads;

  /// No description provided for @studyPlanGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Study plan generated successfully!'**
  String get studyPlanGeneratedSuccessfully;

  /// No description provided for @topicDetails.
  ///
  /// In en, this message translates to:
  /// **'Topic Details'**
  String get topicDetails;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time: {minutes} minutes'**
  String estimatedTime(Object minutes);

  /// No description provided for @topicDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get topicDescription;

  /// No description provided for @keyConceptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Concepts'**
  String get keyConceptsTitle;

  /// No description provided for @aiExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Explanation'**
  String get aiExplanationTitle;

  /// No description provided for @practiceProblemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Problems'**
  String get practiceProblemsTitle;

  /// No description provided for @prerequisitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prerequisites'**
  String get prerequisitesTitle;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescription;

  /// No description provided for @noPracticeProblems.
  ///
  /// In en, this message translates to:
  /// **'No practice problems available'**
  String get noPracticeProblems;

  /// No description provided for @noPrerequisites.
  ///
  /// In en, this message translates to:
  /// **'No prerequisites required'**
  String get noPrerequisites;

  /// No description provided for @noAiExplanation.
  ///
  /// In en, this message translates to:
  /// **'No AI explanation available'**
  String get noAiExplanation;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get reportContent;

  /// No description provided for @pleaseSelectReportType.
  ///
  /// In en, this message translates to:
  /// **'Please select a report type'**
  String get pleaseSelectReportType;

  /// No description provided for @pleaseProvideDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a description'**
  String get pleaseProvideDescription;

  /// No description provided for @reportSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSubmittedSuccessfully;

  /// No description provided for @errorSubmittingReport.
  ///
  /// In en, this message translates to:
  /// **'Error submitting report'**
  String get errorSubmittingReport;

  /// No description provided for @reportTypeInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportTypeInappropriate;

  /// No description provided for @reportTypeIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect information'**
  String get reportTypeIncorrect;

  /// No description provided for @reportTypeHarmful.
  ///
  /// In en, this message translates to:
  /// **'Harmful or dangerous'**
  String get reportTypeHarmful;

  /// No description provided for @reportTypeSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or misleading'**
  String get reportTypeSpam;

  /// No description provided for @reportTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other issue'**
  String get reportTypeOther;

  /// No description provided for @alreadyReportedContent.
  ///
  /// In en, this message translates to:
  /// **'You have already reported this content'**
  String get alreadyReportedContent;

  /// No description provided for @selectReportReason.
  ///
  /// In en, this message translates to:
  /// **'Select a reason for reporting'**
  String get selectReportReason;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional details'**
  String get additionalDetails;

  /// No description provided for @describeIssue.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue in detail...'**
  String get describeIssue;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @reportDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Reports are reviewed to improve content quality. False reports may result in account restrictions.'**
  String get reportDisclaimer;

  /// No description provided for @requiredFieldsNote.
  ///
  /// In en, this message translates to:
  /// **'Fields marked with * are required'**
  String get requiredFieldsNote;

  /// No description provided for @descriptionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters long'**
  String get descriptionTooShort;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable {permission} access in your device settings to use this feature'**
  String permissionDeniedMessage(String permission);

  /// No description provided for @errorTakingPicture.
  ///
  /// In en, this message translates to:
  /// **'Failed to take picture'**
  String get errorTakingPicture;

  /// No description provided for @errorSelectingPicture.
  ///
  /// In en, this message translates to:
  /// **'Failed to select picture'**
  String get errorSelectingPicture;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take Picture'**
  String get takePicture;

  /// No description provided for @uploadPicture.
  ///
  /// In en, this message translates to:
  /// **'Upload Picture'**
  String get uploadPicture;

  /// No description provided for @cropImage.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropImage;

  /// No description provided for @trackingPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Us Improve Your Experience'**
  String get trackingPermissionTitle;

  /// No description provided for @trackingPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow us to collect app usage data to understand how you use the app and make it better for you.'**
  String get trackingPermissionDescription;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @yourPersonalAIMathTutor.
  ///
  /// In en, this message translates to:
  /// **'Your Personal AI Math Tutor'**
  String get yourPersonalAIMathTutor;

  /// No description provided for @solveMathInstantly.
  ///
  /// In en, this message translates to:
  /// **'Solve any math problem instantly'**
  String get solveMathInstantly;

  /// No description provided for @takePhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of math problems and get step-by-step solutions powered by Google Gemini AI. From basic arithmetic to advanced calculus.'**
  String get takePhotoDescription;

  /// No description provided for @photoRecognition.
  ///
  /// In en, this message translates to:
  /// **'Photo Recognition'**
  String get photoRecognition;

  /// No description provided for @snapAnyMathProblem.
  ///
  /// In en, this message translates to:
  /// **'Snap any math problem'**
  String get snapAnyMathProblem;

  /// No description provided for @aiPowered.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered'**
  String get aiPowered;

  /// No description provided for @googleGeminiFlash.
  ///
  /// In en, this message translates to:
  /// **'Advanced AI Technology'**
  String get googleGeminiFlash;

  /// No description provided for @stepByStep.
  ///
  /// In en, this message translates to:
  /// **'Step-by-Step'**
  String get stepByStep;

  /// No description provided for @detailedExplanations.
  ///
  /// In en, this message translates to:
  /// **'Detailed explanations'**
  String get detailedExplanations;

  /// No description provided for @organizeAnalyzeContent.
  ///
  /// In en, this message translates to:
  /// **'Organize & analyze your content'**
  String get organizeAnalyzeContent;

  /// No description provided for @uploadStudyDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload study materials and let AI extract key topics, assess difficulty, and create personalized learning paths just for you.'**
  String get uploadStudyDescription;

  /// No description provided for @easyUpload.
  ///
  /// In en, this message translates to:
  /// **'Easy Upload'**
  String get easyUpload;

  /// No description provided for @imagesNotesUpload.
  ///
  /// In en, this message translates to:
  /// **'Images, PDFs, notes'**
  String get imagesNotesUpload;

  /// No description provided for @uploadPdf.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get uploadPdf;

  /// No description provided for @uploadPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload math PDFs or documents'**
  String get uploadPdfSubtitle;

  /// No description provided for @nonMathDocumentError.
  ///
  /// In en, this message translates to:
  /// **'This document does not contain mathematical material. Please upload a PDF with math problems, equations, or mathematical concepts.'**
  String get nonMathDocumentError;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// No description provided for @autoTopicExtraction.
  ///
  /// In en, this message translates to:
  /// **'Auto topic extraction'**
  String get autoTopicExtraction;

  /// No description provided for @progressTracking.
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get progressTracking;

  /// No description provided for @monitorImprovement.
  ///
  /// In en, this message translates to:
  /// **'Monitor improvement'**
  String get monitorImprovement;

  /// No description provided for @testKnowledgeEffectively.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge effectively'**
  String get testKnowledgeEffectively;

  /// No description provided for @generatePersonalizedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Generate personalized quizzes from your study materials. Track performance, identify weak spots, and improve faster.'**
  String get generatePersonalizedQuizzes;

  /// No description provided for @smartQuestions.
  ///
  /// In en, this message translates to:
  /// **'Smart Questions'**
  String get smartQuestions;

  /// No description provided for @aiCreatesTests.
  ///
  /// In en, this message translates to:
  /// **'AI creates relevant tests'**
  String get aiCreatesTests;

  /// No description provided for @performanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get performanceAnalytics;

  /// No description provided for @detailedProgressInsights.
  ///
  /// In en, this message translates to:
  /// **'Detailed progress insights'**
  String get detailedProgressInsights;

  /// No description provided for @adaptiveLearning.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Learning'**
  String get adaptiveLearning;

  /// No description provided for @questionsMatchLevel.
  ///
  /// In en, this message translates to:
  /// **'Questions match your level'**
  String get questionsMatchLevel;

  /// No description provided for @unlockMathPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock Your Math Potential'**
  String get unlockMathPotential;

  /// No description provided for @joinThousandsStudents.
  ///
  /// In en, this message translates to:
  /// **'Get early access to unlimited AI tutoring, advanced features, and personalized learning designed to transform your math skills.'**
  String get joinThousandsStudents;

  /// No description provided for @solveAsMany.
  ///
  /// In en, this message translates to:
  /// **'Solve as many as you need'**
  String get solveAsMany;

  /// No description provided for @accessAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Access anywhere, anytime'**
  String get accessAnywhere;

  /// No description provided for @detailedLearningInsights.
  ///
  /// In en, this message translates to:
  /// **'Detailed learning insights'**
  String get detailedLearningInsights;

  /// No description provided for @premiumBenefits.
  ///
  /// In en, this message translates to:
  /// **'Premium Benefits'**
  String get premiumBenefits;

  /// No description provided for @unlimitedMathProblemSolving.
  ///
  /// In en, this message translates to:
  /// **'Unlimited math problem solving'**
  String get unlimitedMathProblemSolving;

  /// No description provided for @aiGeneratedQuizzesFromMaterials.
  ///
  /// In en, this message translates to:
  /// **'AI-generated quizzes from your materials'**
  String get aiGeneratedQuizzesFromMaterials;

  /// No description provided for @advancedStudyOrganization.
  ///
  /// In en, this message translates to:
  /// **'Advanced study material organization'**
  String get advancedStudyOrganization;

  /// No description provided for @detailedPerformanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Detailed performance analytics and insights'**
  String get detailedPerformanceAnalytics;

  /// No description provided for @crossDeviceSynchronization.
  ///
  /// In en, this message translates to:
  /// **'Cross-device synchronization'**
  String get crossDeviceSynchronization;

  /// No description provided for @priorityCustomerSupport.
  ///
  /// In en, this message translates to:
  /// **'Priority customer support'**
  String get priorityCustomerSupport;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get adFreeExperience;

  /// No description provided for @studentsImprovedGrades.
  ///
  /// In en, this message translates to:
  /// **'Join the Community'**
  String get studentsImprovedGrades;

  /// No description provided for @testimonialCalculus.
  ///
  /// In en, this message translates to:
  /// **'Be among the first to experience AI-powered math learning'**
  String get testimonialCalculus;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get startFreeTrial;

  /// No description provided for @continueWithFreeVersion.
  ///
  /// In en, this message translates to:
  /// **'Continue with Free Version'**
  String get continueWithFreeVersion;

  /// No description provided for @tryYourFirstProblemFree.
  ///
  /// In en, this message translates to:
  /// **'Solve Your First Problem Free'**
  String get tryYourFirstProblemFree;

  /// No description provided for @seeAiMagicInAction.
  ///
  /// In en, this message translates to:
  /// **'See AI Magic in Action'**
  String get seeAiMagicInAction;

  /// No description provided for @solveAnyMathProblemInstantly.
  ///
  /// In en, this message translates to:
  /// **'Solve any math problem instantly with AI'**
  String get solveAnyMathProblemInstantly;

  /// No description provided for @aiDemoDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch AI solve complex problems in seconds'**
  String get aiDemoDescription;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @premiumFeatureDescription.
  ///
  /// In en, this message translates to:
  /// **'This feature is only available to premium subscribers. Would you like to upgrade to premium?'**
  String get premiumFeatureDescription;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and remove ads'**
  String get unlockAllFeatures;

  /// No description provided for @startWithFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start with a 3-day free trial'**
  String get startWithFreeTrial;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String expiresOn(Object date);

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @flashcard.
  ///
  /// In en, this message translates to:
  /// **'Flashcard'**
  String get flashcard;

  /// No description provided for @deck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get deck;

  /// No description provided for @decks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get decks;

  /// No description provided for @createDeck.
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get createDeck;

  /// No description provided for @editDeck.
  ///
  /// In en, this message translates to:
  /// **'Edit Deck'**
  String get editDeck;

  /// No description provided for @deleteDeck.
  ///
  /// In en, this message translates to:
  /// **'Delete Deck'**
  String get deleteDeck;

  /// No description provided for @deckName.
  ///
  /// In en, this message translates to:
  /// **'Deck Name'**
  String get deckName;

  /// No description provided for @deckDescription.
  ///
  /// In en, this message translates to:
  /// **'Deck Description'**
  String get deckDescription;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// No description provided for @cardFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get cardFront;

  /// No description provided for @cardBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cardBack;

  /// No description provided for @cardHint.
  ///
  /// In en, this message translates to:
  /// **'Hint (Optional)'**
  String get cardHint;

  /// No description provided for @cardTags.
  ///
  /// In en, this message translates to:
  /// **'Tags (Optional)'**
  String get cardTags;

  /// No description provided for @studyCards.
  ///
  /// In en, this message translates to:
  /// **'Study Cards'**
  String get studyCards;

  /// No description provided for @reviewCards.
  ///
  /// In en, this message translates to:
  /// **'Review Cards'**
  String get reviewCards;

  /// No description provided for @startStudy.
  ///
  /// In en, this message translates to:
  /// **'Start Study'**
  String get startStudy;

  /// No description provided for @generateFlashcardsWithAI.
  ///
  /// In en, this message translates to:
  /// **'Generate Flashcards With AI'**
  String get generateFlashcardsWithAI;

  /// No description provided for @generateFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Generate Flashcards'**
  String get generateFlashcards;

  /// No description provided for @generateFromMaterials.
  ///
  /// In en, this message translates to:
  /// **'Generate From Materials'**
  String get generateFromMaterials;

  /// No description provided for @generateFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Generate From Camera'**
  String get generateFromCamera;

  /// No description provided for @generateFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Generate From Gallery'**
  String get generateFromGallery;

  /// No description provided for @generateFromFile.
  ///
  /// In en, this message translates to:
  /// **'Generate From File'**
  String get generateFromFile;

  /// No description provided for @createManually.
  ///
  /// In en, this message translates to:
  /// **'Create Manually'**
  String get createManually;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @addNewFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Add New Flashcard'**
  String get addNewFlashcard;

  /// No description provided for @chooseCreationMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to create your flashcard'**
  String get chooseCreationMethod;

  /// No description provided for @typeQuestionAndAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your question and answer'**
  String get typeQuestionAndAnswer;

  /// No description provided for @captureContentWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Capture content with camera'**
  String get captureContentWithCamera;

  /// No description provided for @selectImageFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select image from gallery'**
  String get selectImageFromGallery;

  /// No description provided for @importFromDocument.
  ///
  /// In en, this message translates to:
  /// **'Import from document or PDF'**
  String get importFromDocument;

  /// No description provided for @noCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No Cards Yet'**
  String get noCardsYet;

  /// No description provided for @addFirstFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Add your first flashcard to start studying.'**
  String get addFirstFlashcard;

  /// No description provided for @errorLoadingCards.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Cards'**
  String get errorLoadingCards;

  /// No description provided for @generatedFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Generated Flashcards'**
  String get generatedFlashcards;

  /// No description provided for @aiGeneratedCards.
  ///
  /// In en, this message translates to:
  /// **'AI generated {count} flashcard{plural} from your content. Review and select which ones to add.'**
  String aiGeneratedCards(int count, String plural);

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card {number}'**
  String cardNumber(int number);

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question:'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer:'**
  String get answer;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint:'**
  String get hint;

  /// No description provided for @selectedCards.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} cards selected'**
  String selectedCards(int selected, int total);

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Selected'**
  String get addSelected;

  /// No description provided for @addedFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Added {count} flashcard{plural} successfully!'**
  String addedFlashcards(int count, String plural);

  /// No description provided for @failedToGenerateFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate flashcard: {error}'**
  String failedToGenerateFlashcard(String error);

  /// No description provided for @failedToGenerateFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate flashcards: {error}'**
  String failedToGenerateFlashcards(String error);

  /// No description provided for @analyzingImageGeneratingFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image and generating flashcard...'**
  String get analyzingImageGeneratingFlashcard;

  /// No description provided for @processingFileGeneratingFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Processing file and generating flashcards...'**
  String get processingFileGeneratingFlashcards;

  /// No description provided for @premiumFlashcardGeneration.
  ///
  /// In en, this message translates to:
  /// **'AI flashcard generation requires a premium subscription.'**
  String get premiumFlashcardGeneration;

  /// No description provided for @premiumSubscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription required for AI flashcard generation.'**
  String get premiumSubscriptionRequired;

  /// No description provided for @watchAdToSeeSolution.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad to See Solution'**
  String get watchAdToSeeSolution;

  /// No description provided for @loadingAd.
  ///
  /// In en, this message translates to:
  /// **'Loading ad...'**
  String get loadingAd;

  /// No description provided for @adFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Ad failed to load. Please try again.'**
  String get adFailedToLoad;

  /// No description provided for @watchAdFirst.
  ///
  /// In en, this message translates to:
  /// **'Please watch the ad to see your solution'**
  String get watchAdFirst;

  /// No description provided for @adLoadingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Loading ad, please wait...'**
  String get adLoadingPleaseWait;

  /// No description provided for @skipAdsForever.
  ///
  /// In en, this message translates to:
  /// **'Skip ads forever with Premium'**
  String get skipAdsForever;

  /// No description provided for @processingAfterAd.
  ///
  /// In en, this message translates to:
  /// **'Processing your solution...'**
  String get processingAfterAd;

  /// No description provided for @skipAdsWithPremium.
  ///
  /// In en, this message translates to:
  /// **'Skip Ads with Premium'**
  String get skipAdsWithPremium;

  /// No description provided for @stopAdsForever.
  ///
  /// In en, this message translates to:
  /// **'Stop ads forever with Premium'**
  String get stopAdsForever;

  /// No description provided for @premiumNoAds.
  ///
  /// In en, this message translates to:
  /// **'Get Premium to enjoy ad-free math solving!'**
  String get premiumNoAds;

  /// No description provided for @unableToVerifySubscription.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify subscription status.'**
  String get unableToVerifySubscription;

  /// No description provided for @unableToProcessSubscription.
  ///
  /// In en, this message translates to:
  /// **'Unable to process subscription. Please try again.'**
  String get unableToProcessSubscription;

  /// No description provided for @subscriptionServiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Subscription service not available.'**
  String get subscriptionServiceNotAvailable;

  /// No description provided for @deckUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deck updated successfully!'**
  String get deckUpdatedSuccessfully;

  /// No description provided for @cardDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully'**
  String get cardDeletedSuccessfully;

  /// No description provided for @confirmDeleteCard.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this flashcard? This action cannot be undone.'**
  String get confirmDeleteCard;

  /// No description provided for @fileSizeExceedsLimit.
  ///
  /// In en, this message translates to:
  /// **'File size ({size}MB) exceeds the maximum allowed size of {limit}MB'**
  String fileSizeExceedsLimit(String size, int limit);

  /// No description provided for @flashcardsDeck.
  ///
  /// In en, this message translates to:
  /// **'Flashcards Deck'**
  String get flashcardsDeck;

  /// No description provided for @newCards.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCards;

  /// No description provided for @dueCards.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueCards;

  /// No description provided for @learningCards.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learningCards;

  /// No description provided for @totalCards.
  ///
  /// In en, this message translates to:
  /// **'Total Cards'**
  String get totalCards;

  /// No description provided for @studyProgress.
  ///
  /// In en, this message translates to:
  /// **'Study Progress'**
  String get studyProgress;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @tagsExample.
  ///
  /// In en, this message translates to:
  /// **'algebra, geometry, calculus'**
  String get tagsExample;

  /// No description provided for @separateTagsComma.
  ///
  /// In en, this message translates to:
  /// **'Separate tags with commas'**
  String get separateTagsComma;

  /// No description provided for @deleteCardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this flashcard? This action cannot be undone.'**
  String get deleteCardConfirmation;

  /// No description provided for @reviewComplete.
  ///
  /// In en, this message translates to:
  /// **'Review Complete!'**
  String get reviewComplete;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @showAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show Answer'**
  String get showAnswer;

  /// No description provided for @howWellDidYouKnow.
  ///
  /// In en, this message translates to:
  /// **'How well did you know this?'**
  String get howWellDidYouKnow;

  /// No description provided for @reviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get reviewAgain;

  /// No description provided for @reviewHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get reviewHard;

  /// No description provided for @reviewGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get reviewGood;

  /// No description provided for @reviewEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get reviewEasy;

  /// No description provided for @enjoyingApp.
  ///
  /// In en, this message translates to:
  /// **'Enjoying the App?'**
  String get enjoyingApp;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How many stars would you give us?'**
  String get rateYourExperience;

  /// No description provided for @tapNumberOfStars.
  ///
  /// In en, this message translates to:
  /// **'Tap the number of stars that represents your experience'**
  String get tapNumberOfStars;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @helpUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Help Us Improve'**
  String get helpUsImprove;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear your feedback to make the app better for you!'**
  String get feedbackMessage;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @feedbackEmailError.
  ///
  /// In en, this message translates to:
  /// **'Cannot open email app. Please copy the email address.'**
  String get feedbackEmailError;

  /// No description provided for @copyEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy Email'**
  String get copyEmail;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support Email'**
  String get supportEmail;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @tapToRevealAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal answer'**
  String get tapToRevealAnswer;

  /// No description provided for @aiPreferences.
  ///
  /// In en, this message translates to:
  /// **'AI Preferences'**
  String get aiPreferences;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @supportAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get supportAndFeedback;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @numbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get numbers;

  /// No description provided for @algebra.
  ///
  /// In en, this message translates to:
  /// **'Algebra'**
  String get algebra;

  /// No description provided for @calculus.
  ///
  /// In en, this message translates to:
  /// **'Calculus'**
  String get calculus;

  /// No description provided for @symbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get symbols;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
