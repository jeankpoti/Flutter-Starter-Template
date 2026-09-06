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

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

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

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes, so double check the results!'**
  String get aiDisclaimer;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get changeTheme;

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

  /// No description provided for @unlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Access'**
  String get unlimitedAccess;

  /// No description provided for @unlimitedAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Use all features without limits'**
  String get unlimitedAccessDesc;

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

  /// No description provided for @advancedFeatures.
  ///
  /// In en, this message translates to:
  /// **'Advanced Features'**
  String get advancedFeatures;

  /// No description provided for @advancedFeaturesDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium capabilities'**
  String get advancedFeaturesDesc;

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

  /// No description provided for @subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Error showing subscription options. Please try again.'**
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
  /// **'Failed to share. Please try again.'**
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

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noMoreItems.
  ///
  /// In en, this message translates to:
  /// **'No more items'**
  String get noMoreItems;

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
  String daysAgo(int count);

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
  String languageChangedTo(String language);

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'Check out this amazing app: {url}'**
  String shareAppText(String url);

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
  String expiresOn(String date);

  /// No description provided for @premiumBenefits.
  ///
  /// In en, this message translates to:
  /// **'Premium Benefits'**
  String get premiumBenefits;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get adFreeExperience;

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

  /// No description provided for @fileSizeExceedsLimit.
  ///
  /// In en, this message translates to:
  /// **'File size ({size}MB) exceeds the maximum allowed size of {limit}MB'**
  String fileSizeExceedsLimit(String size, int limit);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

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
