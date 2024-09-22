import 'dart:developer';
import 'package:blood_link_app/donor_main_screen.dart';
import 'package:blood_link_app/org_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blood_link_app/auth/auth_service.dart';
import 'package:blood_link_app/auth/signup.dart';
import 'package:blood_link_app/widgets/auth_button.dart';
import 'package:blood_link_app/widgets/auth_textfield.dart';// Import organizer home screen
import 'package:local_auth/local_auth.dart';
import '../camp_org_home.dart';
import '../donor_home.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),
                const Center(
                  child: Image(
                    image: AssetImage('assets/images/BloodLinkLogo.png'),
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  hint: "Enter Email",
                  label: "Email",
                  controller: _email,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Enter Password",
                  label: "Password",
                  controller: _password,
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ForgotPassword()));
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  label: "Login",
                  onPressed: _login,
                  color: Colors.black,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Do not have an account? "),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Regular email/password login
  _login() async {
    final user = await _auth.loginUserWithEmailAndPassword(
      _email.text,
      _password.text,
    );

    if (user != null) {
      // Prompt for fingerprint authentication
      bool auth = await _loginWithFingerprint();
      if (auth) {
        log("User Logged In with Fingerprint");
        _redirectBasedOnUserType(context);
      } else {
        log("Fingerprint authentication failed");
      }
    } else {
      log("Login failed");
    }
  }

  // Fingerprint Login
  _loginWithFingerprint() async {
    final canAuthenticate = await _auth.hasBiometricCapability();
    if (canAuthenticate) {
      final authenticated = await _auth.authenticateWithBiometrics();
      if (authenticated) {
        return true;
      }
    }
    return false;
  }

  _redirectBasedOnUserType(BuildContext context) async {
    final userData = await _auth.getUserData();

    log("User Data: $userData"); // Log userData for debugging

    if (userData != null) {
      if (userData['userType'] == 'Blood Donor') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DonorMainScreen()),
              (route) => false,
        );
      } else if (userData['userType'] == 'Camp Organizer') {
        log("Organizer Name: ${userData['name']}"); // Log organizer name
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OrgMainScreen(),
          ),
              (route) => false,
        );
      } else {
        log("Unknown user type");
      }
    } else {
      log("User data is null");
    }
  }
}