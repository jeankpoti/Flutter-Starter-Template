/*
TodoRepo is an abstract class that defines the methods that the TodoRepository class must implement.

Here we define what the app can do
*/

// import '../../data/models/isar_todo.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class AccountRepo {
  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  );
  Future<bool> signInWithGooogle(BuildContext context);
  Future<bool> signInWithApple(BuildContext context);
  Future<bool> signUpWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    BuildContext context,
  );
  Future<UserCredential> signUpWithGoogle(BuildContext context);
  Future<UserCredential> signUpWithApple(BuildContext context);
  Future<void> signOut();
  Future<void> resetPassword(BuildContext context, String email);
  Future<void> deleteUserWithHisData(BuildContext context);
}

/*

The repo in domain layer outlines what operations the app can do, bu
it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks.

*/
