import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during sign in.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String name,
    String email,
    String password, {
    String role = 'Individual',
    String? communityName,
    String? communityAddress,
    String? contactPhone,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      
      // Save user metadata to Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        if (communityName != null && communityName.isNotEmpty) 'communityName': communityName,
        if (communityAddress != null && communityAddress.isNotEmpty) 'communityAddress': communityAddress,
        if (contactPhone != null && contactPhone.isNotEmpty) 'contactPhone': contactPhone,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true),);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during sign up.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      if (!_isGoogleInitialized) {
        await _googleSignIn.initialize();
        _isGoogleInitialized = true;
      }

      final googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final clientAuth = await googleUser.authorizationClient
          .authorizationForScopes(['email']);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth?.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during Google sign in.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _setError('Error signing out.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during password reset.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}
