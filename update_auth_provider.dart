// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/providers/auth_provider.dart');
  var content = file.readAsStringSync();
  
  // Add missing import if needed
  if (!content.contains("import 'package:cloud_firestore/cloud_firestore.dart';")) {
    content = "import 'package:cloud_firestore/cloud_firestore.dart';\n$content";
  }

  // Replace signUpWithEmail signature and body
  const target = '''  Future<bool> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      _setLoading(false);
      return true;''';
      
  const replacement = '''  Future<bool> signUpWithEmail(
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
      }, SetOptions(merge: true));
      
      _setLoading(false);
      return true;''';

  content = content.replaceFirst(target, replacement);
  file.writeAsStringSync(content);
  print('Updated auth_provider.dart');
}
