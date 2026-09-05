import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_starter/core/config/firebase_config.dart';
import 'package:flutter_starter/core/services/analytics_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../common_widgets/app_snackbar_widget.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/repository/account_repo.dart';

class FirebaseRepo implements AccountRepo {
  // Lazy initialization to avoid crashes when Firebase isn't configured
  FirebaseAuth? _authInstance;
  FirebaseFirestore? _firestoreInstance;

  FirebaseAuth? get _auth {
    if (!FirebaseConfig.isInitialized) return null;
    _authInstance ??= FirebaseAuth.instance;
    return _authInstance;
  }

  FirebaseFirestore? get _firestore {
    if (!FirebaseConfig.isInitialized) return null;
    _firestoreInstance ??= FirebaseFirestore.instance;
    return _firestoreInstance;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Check if Firebase is available, show error if not
  bool _checkFirebaseAvailable(BuildContext context) {
    if (!FirebaseConfig.isInitialized) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          'Firebase not configured. Run "flutterfire configure" to set up.',
        );
      }
      return false;
    }
    return true;
  }

  /// Throw if Firebase is not available
  void _requireFirebase() {
    if (!FirebaseConfig.isInitialized) {
      throw Exception('Firebase not configured. Run "flutterfire configure" to set up.');
    }
  }

  @override
  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (!_checkFirebaseAvailable(context)) return false;

    try {
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        // Track login for Google Ads conversion
        await AnalyticsService.logLogin(method: 'email');
        await AnalyticsService.setUserId(userCredential.user!.uid);
        return true;
      } else {
        // If email is not verified, sign out the user and show an error message
        await _auth!.signOut();
        if (context.mounted) {
          AppSnackBar.showError(
            context,
            "Your email is not verified. Please check your inbox for the verification email.",
          );
        }
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'user-not-found') {
          AppSnackBar.showError(
            context,
            "No user found for that email.. Please try again.",
          );
        } else if (e.code == 'wrong-password') {
          AppSnackBar.showError(
            context,
            "Wrong password provided for that user. Please try again.",
          );
        } else if (e.code == 'invalid-credential') {
          AppSnackBar.showError(
            context,
            "Email or password incorrect. Please try again.",
          );
        } else {
          AppSnackBar.showError(
            context,
            "An authentication error occurred. Please try again.",
          );
        }
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          "An unexpected error occurred. Please try again.",
        );
      }
      return false;
    }
  }

  @override
  Future<bool> signInWithApple(BuildContext context) async {
    if (!_checkFirebaseAvailable(context)) return false;

    try {
      // Request an Apple ID Credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Check if user exists using Cloud Function BEFORE authenticating
      final appleId = appleCredential.userIdentifier;

      if (appleId != null) {
        try {
          // Call the Cloud Function via HTTP to check if user exists
          const functionUrl = ApiConfig.checkAppleUserExistsUrl;

          final response = await http.post(
            Uri.parse(functionUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'appleId': appleId}),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final bool userExists = data['exists'] ?? false;

            if (!userExists) {
              if (context.mounted) {
                AppSnackBar.showError(
                  context,
                  "Account not found. Please sign up first!",
                );
              }
              return false;
            }
          } else {
            throw Exception('Failed to check user existence');
          }
        } catch (error) {
          rethrow;
        }
      } else {}

      // Create an OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Use the credential to sign in with Firebase
      final authResult = await _auth!.signInWithCredential(
        oauthCredential,
      );

      // Get the current user
      final user = authResult.user;

      if (user != null) {
        // Track login for Google Ads conversion
        await AnalyticsService.logLogin(method: 'apple');
        await AnalyticsService.setUserId(user.uid);
        // User exists and signed in successfully
        return true;
      } else {
        if (context.mounted) {
          AppSnackBar.showError(
            context,
            "Failed to retrieve user information after Apple Sign-In.",
          );
        }
        return false;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      String displayMessage = "Sign in with Apple failed.";
      if (e.code == AuthorizationErrorCode.canceled) {
        displayMessage = "Sign in with Apple was cancelled.";
      } else if (e.code == AuthorizationErrorCode.failed) {
        displayMessage = "Sign in with Apple failed. Please try again.";
      } else if (e.code == AuthorizationErrorCode.invalidResponse) {
        displayMessage =
            "Invalid response from Apple Sign-In. Please try again.";
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        displayMessage = "Apple Sign-In not handled. Please try again.";
      } else if (e.code == AuthorizationErrorCode.unknown) {
        displayMessage =
            "An unknown error occurred with Apple Sign-In. Please try again.";
      }
      if (context.mounted) {
        AppSnackBar.showError(context, displayMessage);
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          "Firebase authentication failed with Apple Sign-In: ${e.message}",
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          "An unexpected error occurred during Apple Sign-In!",
        );
      }
      return false;
    }
  }

  @override
  Future<bool> signInWithGooogle(BuildContext context) async {
    try {
      // Start Google Sign In flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return false;
      }

      // Get Google authentication
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential = await _auth!.signInWithCredential(
        credential,
      );

      // Check if this is a new user (not in our database)
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // This is a new user trying to sign in - they should sign up first
        await _auth!.signOut();
        await _googleSignIn.signOut();
        if (context.mounted) {
          AppSnackBar.showError(
            context,
            "Account not found. Please sign up first!",
          );
        }
        return false;
      }
      final User? user = userCredential.user;

      if (user != null) {
        // Track login for Google Ads conversion
        await AnalyticsService.logLogin(method: 'google');
        await AnalyticsService.setUserId(user.uid);
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          "An authentication error occurred: ${e.message}",
        );
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<UserCredential> signUpWithGoogle(BuildContext context) async {
    _requireFirebase();

    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled');
      }

      // Check if user already exists BEFORE creating Firebase Auth account
      final email = googleUser.email;
      try {
        // Call the Cloud Function via HTTP to check if user exists
        const functionUrl = ApiConfig.checkGoogleUserExistsUrl;

        final response = await http.post(
          Uri.parse(functionUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final bool userExists = data['exists'] ?? false;

          if (userExists) {
            // User already exists - show the message
            await _googleSignIn.signOut();
            if (context.mounted) {
              AppSnackBar.showError(
                context,
                "You have already signed up. Please sign in!",
              );
            }
            return Future.error(
              'Account already exists. Please sign in instead.',
            );
          }
        }
      } catch (error) {
        // Continue with sign up if check fails
      }

      // Obtain the auth details from the request
      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with credential first
        UserCredential userCredential = await _auth!.signInWithCredential(
          credential,
        );

        // Save the user's information to Firestore
        try {
          await _firestore!
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
                'displayName': googleUser.displayName,
                'email': googleUser.email,
                'isSubscribed': false, // Free subscription
                'createdAt': DateTime.now(),
              });
        } catch (firestoreError) {
          // You might want to delete the Firebase Auth user if Firestore save fails
          await userCredential.user?.delete();
          throw Exception('Failed to save user data: $firestoreError');
        }

        // Track sign-up for Google Ads conversion
        await AnalyticsService.logSignUp(method: 'google');
        if (userCredential.user != null) {
          await AnalyticsService.setUserId(userCredential.user!.uid);
        }

        return userCredential;
      } catch (authError) {
        throw Exception('Authentication failed: $authError');
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<UserCredential> signUpWithApple(BuildContext context) async {
    _requireFirebase();

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Check if user already exists BEFORE creating Firebase Auth account
      final appleId = appleCredential.userIdentifier;
      if (appleId != null) {
        try {
          // Call the Cloud Function via HTTP to check if user exists
          const functionUrl = ApiConfig.checkAppleUserExistsUrl;

          final response = await http.post(
            Uri.parse(functionUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'appleId': appleId}),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final bool userExists = data['exists'] ?? false;

            if (userExists) {
              // User already exists - show the message
              if (context.mounted) {
                AppSnackBar.showError(
                  context,
                  "You have already signed up. Please sign in!",
                );
              }
              return Future.error(
                'Account already exists. Please sign in instead.',
              );
            }
          }
        } catch (error) {
          // Continue with sign up if check fails
        }
      }

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth!.signInWithCredential(
        credential,
      );

      // Save the user's information to Firestore
      await _firestore!.collection('users').doc(userCredential.user?.uid).set({
        'fullName':
            '${appleCredential.familyName} ${appleCredential.givenName}',
        'email': appleCredential.email,
        'appleId':
            appleCredential
                .userIdentifier, // Store Apple ID for future sign-in checks
        'isSubscribed': false, // Free subscription
        'createdAt': DateTime.now(),
      });

      // Track sign-up for Google Ads conversion
      await AnalyticsService.logSignUp(method: 'apple');
      if (userCredential.user != null) {
        await AnalyticsService.setUserId(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      // Handle error
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
                'This account exists with a different sign-in provider.';
            break;
          case 'invalid-credential':
            errorMessage =
                'The credential received is malformed or has expired.';
            break;
          case 'operation-not-allowed':
            errorMessage =
                'This operation is not allowed. Please enable it in the Firebase console.';
            break;
          case 'user-disabled':
            errorMessage =
                'This user has been disabled. Please contact support for help.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for the provided credentials.';
            break;
          case 'wrong-password':
            errorMessage =
                'The password is invalid or the user does not have a password.';
            break;
          case 'invalid-verification-code':
            errorMessage = 'The verification code is invalid.';
            break;
          case 'invalid-verification-id':
            errorMessage = 'The verification ID is invalid.';
            break;
          default:
            errorMessage = 'An unknown error occurred.';
        }
      } else {
        errorMessage = 'An unknown error occurred.';
      }

      // Show error message
      if (context.mounted) {
        AppSnackBar.showError(context, errorMessage);
      }
    }
    return Future.error('An error occurred while signing up with Apple.');
  }

  @override
  Future<bool> signUpWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    BuildContext context,
  ) async {
    if (!_checkFirebaseAvailable(context)) return false;

    try {
      UserCredential userCredential = await _auth!
          .createUserWithEmailAndPassword(email: email, password: password);

      // After the user is created, we can add the username to the displayName field
      await userCredential.user?.updateProfile(displayName: fullName);

      // Create a new document for the user with the uid
      await _firestore!.collection('users').doc(userCredential.user?.uid).set({
        'fullName': fullName,
        'email': email,
        'isSubscribed': false, // Free subscription
        'createdAt': DateTime.now(),
      });

      // Check if the user is not null
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        // Track sign-up for Google Ads conversion (track before sign out)
        await AnalyticsService.logSignUp(method: 'email');
        await AnalyticsService.setUserId(user.uid);

        // Send an email verification if the user is created successfully and email is not verified
        await user.sendEmailVerification();

        // Sign out the user so they can't access the app until email is verified
        await _auth!.signOut();

        // Show a message to inform the user
        if (context.mounted) {
          AppSnackBar.showSuccess(
            context,
            "Verification email has been sent. Please check your inbox and verify your email before signing in.",
          );
        }
      }

      return true;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'weak-password') {
          AppSnackBar.showError(context, "The password provided is too weak.");
        } else if (e.code == 'email-already-in-use') {
          AppSnackBar.showError(
            context,
            "The account already exists for that email.",
          );
        } else {
          AppSnackBar.showError(
            context,
            "An authentication error occurred. Please try again.",
          );
        }
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, "An error occurred while signing up.");
      }
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    if (_auth == null) return;
    await _auth!.signOut();
  }

  @override
  Future<void> resetPassword(BuildContext context, String email) async {
    if (!_checkFirebaseAvailable(context)) return;

    try {
      await _auth!.sendPasswordResetEmail(email: email);

      if (context.mounted) {
        AppSnackBar.showInfo(
          context,
          "Password reset email will be sent to your email if the email exist in our system. Check your inbox.",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          "Failed to send password reset email: ${e.message}",
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          "An unexpected error occurred. Please try again.",
        );
      }
    }
  }

  @override
  Future<void> deleteUserWithHisData(BuildContext context) async {
    if (!_checkFirebaseAvailable(context)) return;

    try {
      final user = _auth!.currentUser;

      if (user != null) {
        // Delete data from all collections
        final collections = ['todos', 'users'];

        for (String collection in collections) {
          final querySnapshot =
              await _firestore!
                  .collection(collection)
                  .where('userId', isEqualTo: user.uid)
                  .get();

          for (var doc in querySnapshot.docs) {
            await doc.reference.delete();
          }
        }

        // Explicitly delete the user document from Firestore
        await _firestore!
            .collection('users')
            .doc(user.uid)
            .delete();

        // Finally delete the authentication account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (context.mounted) {
          AppSnackBar.showError(
            context,
            "Please sign out and sign in again to delete your account.",
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          'Error deleting account. Please try again.',
        );
      }
    }
  }
}
