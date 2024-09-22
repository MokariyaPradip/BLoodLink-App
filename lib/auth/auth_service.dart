import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Method to check if the device supports biometric authentication
  Future<bool> hasBiometricCapability() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      log("Error checking biometrics: $e");
      return false;
    }
  }

  // Method to authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
    log("Available biometrics: $availableBiometrics");
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Use fingerprint to authenticate',
        options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
            biometricOnly: true
        ),
      );
      return authenticated;
    } catch (e) {
      log("Error using biometric authentication: $e");
      return false;
    }
  }

  // Create user with email and password and store basic user data
  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String userType) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error during account creation: $e");
    }
    return null;
  }

  // Method to send a password reset link to the user's email
  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log("Password reset link sent.");
    } catch (e) {
      log("Error sending password reset link: $e");
    }
  }

  // Method to login user with email and password
  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error logging in user: $e");
    }
    return null;
  }

  // Method to sign out the user
  Future<void> signout() async {
    try {
      await _auth.signOut();
      log("User signed out successfully.");
    } catch (e) {
      log("Error signing out user: $e");
    }
  }
  //
  // Get current user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser; // Get currently authenticated user

      if (user != null) {
        DocumentSnapshot userData =
        await _firestore.collection('users').doc(user.uid).get();

        if (userData.exists) {
          return userData.data() as Map<String, dynamic>?; // Return user data
        }
      }
      return null; // If no user or no data found
    } catch (e) {
      print("Error fetching user data: $e");
      return null; // Return null if an error occurs
    }
  }
  //
  // Future<List<CampModel>> getUpcomingCampsForOrganizer(String organizerId) async {
  //   // Fetch upcoming camps for the organizer from Firebase or another source
  //   // Return a list of CampModel
  //   return [];
  // }
}