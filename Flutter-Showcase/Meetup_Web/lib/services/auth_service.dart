import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '989749993524-1ukveda6ple8tengecgge52m0sra6ibt.apps.googleusercontent.com' : null,
  );

  User? _user;
  bool _isLoading = false;
  String? _anonymousId;

  String get anonymousId {
    _anonymousId ??= 'anonymous_${const Uuid().v4()}';
    return _anonymousId!;
  }

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthService() {
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  // Google Sign-In Logic (Handles Mobile & Web)
  Future<UserCredential?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential.user != null) {
        final user = userCredential.user!;
        // store in firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // store in shared prefs for quick access
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('name', user.displayName ?? 'CodeX User');
        prefs.setString('email', user.email ?? '');
        prefs.setString('photoUrl', user.photoURL ?? '');
      }

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Google Sign-In Error: $e");
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
