import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';   // For Firestore interaction
import 'package:firebase_auth/firebase_auth.dart';      // For Firebase Auth
import 'package:blood_link_app/widgets/auth_button.dart';  // Custom button widget
import 'package:blood_link_app/widgets/auth_textfield.dart'; // Custom textfield widget
import '../donor_info.dart';  // UserInfoPage for blood donors
import '../camp_organizer_info.dart'; // CampOrgInfo for camp organizers

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();
  bool _obscurePassword = true;

  String? _selectedUserType;
  final List<String> _userTypes = ['Blood Donor', 'Camp Organizer'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              CustomTextField(
                hint: "Enter Email",
                label: "Email",
                controller: _emailController,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: "Enter Password",
                label: "Password",
                controller: _passwordController,
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
              const SizedBox(height: 20),
              CustomTextField(
                hint: "Verify Password",
                label: "Verify Password",
                controller: _verifyPasswordController,
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
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                hint: const Text("Select User Type"),
                value: _selectedUserType,
                items: _userTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedUserType = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Type',
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: "Sign Up",
                onPressed: _register,
                color: Colors.black,
                textColor: Colors.white,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (_passwordController.text != _verifyPasswordController.text) {
      log("Passwords do not match");
      return;
    }

    setState(() {
      // Indicate loading (you can add a loader if needed)
    });

    try {
      // Create a new user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        // Add user details to Firestore in the 'users' collection
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'created_at': DateTime.now(),
          'userType': _selectedUserType!,
        });

        log("User Registered");

        // Navigate based on userType
        if (_selectedUserType == 'Blood Donor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DonorInfoPage(uid: user.uid),
            ),
          );
        } else if (_selectedUserType == 'Camp Organizer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CampOrganizerInfo(uid: user.uid),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      log("Registration failed: ${e.message}");
    } finally {
      setState(() {
        // Stop loading
      });
    }
  }
}