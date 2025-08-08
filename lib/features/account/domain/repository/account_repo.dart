/*
TodoRepo is an abstract class that defines the methods that the TodoRepository class must implement.

Here we define what the app can do
*/

// import '../../data/models/isar_todo.dart';

import 'package:firebase_auth/firebase_auth.dart';

abstract class AccountRepo {
  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
    context,
  );
  Future<bool> signInWithGooogle(context);
  Future<bool> signInWithApple(context);
  Future<bool> signUpWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    context,
  );
  Future<UserCredential> signUpWithGoogle(context);
  Future<UserCredential> signUpWithApple(context);
  Future<void> signOut();
  Future<void> resetPassword(context, String email);
  Future<void> deleteUserWithHisData(context);
}

/*

The repo in domain layer outlines what operations the app can do, bu
it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks.

*/
