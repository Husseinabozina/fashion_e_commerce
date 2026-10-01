import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Captures a UID-scoped reference before an operation starts. No account data
/// or collection references are cached across sign-in/sign-out.
class FirebaseAccountStore {
  FirebaseAccountStore(this.db, this.auth);
  final FirebaseFirestore db;
  final FirebaseAuth auth;

  String get uid =>
      auth.currentUser?.uid ??
      (throw StateError('An authenticated session is required.'));

  CollectionReference<Map<String, dynamic>> collection(String name) =>
      db.collection('users').doc(uid).collection(name);

  static String documentKey(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}
