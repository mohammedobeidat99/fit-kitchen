import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _biometricAvailable = false;
  bool get biometricAvailable => _biometricAvailable;

  bool _biometricEnabled = false;
  bool get biometricEnabled => _biometricEnabled;

  bool _rememberMe = true;
  bool get rememberMe => _rememberMe;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isEmailVerified =>
      _firebaseAuth.currentUser?.emailVerified ?? false;

  String? get userName => _currentUser?.name;
  String? get userImageUrl => _currentUser?.imageUrl;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isInitializing = true;
    notifyListeners();

    // Check biometric availability
    try {
      _biometricAvailable =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      _biometricAvailable = false;
    }

    _biometricEnabled =
        LocalStorageService.getBool(LocalStorageService.keyBiometricEnabled);

    debugPrint('[AuthProvider] Biometric Hardware Available: $_biometricAvailable | Feature Enabled by User: $_biometricEnabled');

    _rememberMe =
        LocalStorageService.getBool(LocalStorageService.keyRememberMe);

    if (!LocalStorageService.containsKey(LocalStorageService.keyRememberMe)) {
      _rememberMe = true;
    }

    // Check if Firebase user is already signed in
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      if (!_rememberMe && !_biometricEnabled) {
        await _firebaseAuth.signOut();
      } else {
        try {
          await firebaseUser.reload();
        } on FirebaseAuthException catch (e) {
          debugPrint('[AuthProvider] User reload failed (Firebase exception): ${e.code}');
          if (e.code == 'user-not-found' || e.code == 'user-disabled' || e.code == 'invalid-user-token') {
            await _firebaseAuth.signOut();
            _isLoggedIn = false;
            _currentUser = null;
          }
        } catch (e) {
          debugPrint('[AuthProvider] User reload failed with unknown error (likely offline): $e');
        }

        // Check if user is still logged in after reload attempt
        if (_firebaseAuth.currentUser != null) {
          _isLoggedIn = true; // Set logged in before starting sync
          _startUserSync(_firebaseAuth.currentUser!.uid);
          
          // If biometric feature is explicitly enabled, don't automatically log in.
          // Force them to the Login screen where they can click the Biometric button.
          if (_biometricEnabled) {
            _isLoggedIn = false; // Override if biometric required
          }
        }
      }
    }

    // Force a 3-second minimum display time for the SplashScreen
    await Future.delayed(const Duration(seconds: 3));

    _isInitializing = false;
    notifyListeners();
  }

  /// Register a new user with Firebase Auth + save profile to Firestore.
  /// Returns null on success, error code string on failure.
  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      _isLoading = false;
      _errorMessage = 'Please fill all fields';
      notifyListeners();
      return 'empty_fields';
    }

    try {
      // Create user in Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = credential.user!;

      // Set display name
      await user.updateDisplayName(name.trim());

      // Send email verification
      await user.sendEmailVerification();

      // Save user profile to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });

      // Sign out immediately so they must verify before logging in
      await _firebaseAuth.signOut();

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.code;
      notifyListeners();
      return e.code; // e.g. 'email-already-in-use', 'weak-password'
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'unknown_error';
    }
  }

  Future<void> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = UserModel(
      uid: 'guest',
      name: 'Guest',
      email: 'guest@fitkitchen.app',
    );
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
  }

  /// Login with email & password via Firebase Auth.
  /// Returns null on success, error code string on failure.
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _isLoading = false;
      _errorMessage = 'empty_fields';
      notifyListeners();
      return 'empty_fields';
    }

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = credential.user!;

      if (!user.emailVerified) {
        await _firebaseAuth.signOut();
        _isLoading = false;
        _errorMessage = 'email_not_verified';
        notifyListeners();
        return 'email_not_verified';
      }

      _isLoggedIn = true;
      _startUserSync(user.uid);

      // Save user info locally for biometric re-login
      if (_rememberMe) {
        // We'll save the profile once we get the first sync data, or just save minimal info now
        await LocalStorageService.setString(
            LocalStorageService.keyUser, 
            jsonEncode({
              'uid': user.uid,
              'name': user.displayName ?? 'User',
              'email': user.email ?? '',
            })
        );
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.code;
      notifyListeners();
      return e.code; // e.g. 'user-not-found', 'wrong-password'
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'unknown_error';
    }
  }

  /// Biometric authentication. Uses local_auth + active Firebase session.
  /// Returns null on success, or a specific string error code on failure.
  Future<String?> authenticateBiometrically() async {
    debugPrint('[AuthProvider] authenticateBiometrically() called');
    
    if (!_biometricAvailable) {
      debugPrint('[AuthProvider] Biometric is NOT available on this device! (_biometricAvailable = false)');
      return 'not_available';
    }

    try {
      debugPrint('[AuthProvider] Invoking _localAuth.authenticate()... Waiting for user fingerprint...');
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Login with biometrics',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      debugPrint('[AuthProvider] User fingerprint scan finished. authenticated=$authenticated');

      if (authenticated) {
        // If Firebase session is still active, use it
        debugPrint('[AuthProvider] Checking if Firebase session is active...');
        await _firebaseAuth.currentUser?.reload();
        final firebaseUser = _firebaseAuth.currentUser;
        
        if (firebaseUser != null) {
          debugPrint('[AuthProvider] Active Firebase Session FOUND! UID: ${firebaseUser.uid}');
          _isLoggedIn = true;
          _startUserSync(firebaseUser.uid);
          notifyListeners();
          debugPrint('[AuthProvider] Successfully logged in using ACTIVE Firebase token.');
          return null; // Success
        }

        debugPrint('[AuthProvider] Firebase Session is NULL. Falling back to cached JSON user from LocalStorage...');
        // Fallback: load cached user info from local storage
        final userJson = LocalStorageService.getString(LocalStorageService.keyUser);
        
        if (userJson != null) {
          debugPrint('[AuthProvider] Found cached JSON in LocalStorage.');
          _currentUser = UserModel.fromJson(json.decode(userJson));
          _isLoggedIn = true;
          notifyListeners();
          debugPrint('[AuthProvider] Successfully logged in using OFFLINE cached JSON fallback.');
          return null; // Success
        } else {
          debugPrint('[AuthProvider] Cached JSON (keyUser) is NULL! Cannot log in via fallback.');
          return 'no_saved_credentials';
        }
      } else {
        debugPrint('[AuthProvider] User cancelled or failed biometric authentication.');
        return 'auth_failed';
      }
    } on PlatformException catch (e) {
      debugPrint('[AuthProvider] PLATFORM EXCEPTION CAUGHT during biometric scan: ${e.code}');
      if (e.code == 'NotEnrolled') return 'not_enrolled';
      if (e.code == 'NotAvailable') return 'not_available';
      if (e.code == 'PasscodeNotSet') return 'passcode_not_set';
      return 'system_error';
    } catch (e) {
      debugPrint('[AuthProvider] EXCEPTION CAUGHT during biometric scan: $e');
      return 'system_error';
    }
  }

  /// Send email verification to the current user
  Future<void> sendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Reload user to check if email is now verified
  Future<bool> checkEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser!;
      if (refreshedUser.emailVerified) {
        _currentUser = _currentUser?.copyWith(emailVerified: true);
        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
        });
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void setBiometricEnabled(bool value) async {
    _biometricEnabled = value;
    await LocalStorageService.setBool(
        LocalStorageService.keyBiometricEnabled, value);
        
    // Save the user data locally so the biometric fallback can use it later!
    if (value && _currentUser != null) {
      await LocalStorageService.setString(
          LocalStorageService.keyUser, jsonEncode(_currentUser!.toJson()));
    }
    
    notifyListeners();
  }

  void setRememberMe(bool value) async {
    _rememberMe = value;
    await LocalStorageService.setBool(
        LocalStorageService.keyRememberMe, value);
    notifyListeners();
  }

  /// Logout: sign out from Firebase + clear local session (if biometrics not enabled)
  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _userSubscription?.cancel();
    _userSubscription = null;
    await _firebaseAuth.signOut();
    
    // Do NOT delete the local JSON if biometric is enabled, 
    // because it relies on this cached JSON as a fallback to log you back in!
    if (!_biometricEnabled) {
      await LocalStorageService.remove(LocalStorageService.keyUser);
    }
    
    notifyListeners();
  }

  void _startUserSync(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _currentUser = UserModel(
          uid: uid,
          name: data['name'] ?? 'User',
          email: data['email'] ?? '',
          imageUrl: data['imageUrl'],
          emailVerified: _firebaseAuth.currentUser?.emailVerified ?? false,
        );
        
        // Cache the latest data if rememberMe is on
        if (_rememberMe) {
          LocalStorageService.setString(
            LocalStorageService.keyUser,
            json.encode(_currentUser!.toJson()),
          );
        }
        
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  /// Send password reset email via Firebase
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get the current Firebase User ID (needed by other providers for Firestore paths)
  String? get uid => _firebaseAuth.currentUser?.uid ?? _currentUser?.uid;
}
