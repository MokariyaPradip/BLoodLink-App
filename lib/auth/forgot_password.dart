import 'package:blood_link_app/auth/auth_service.dart';
import 'package:blood_link_app/widgets/auth_button.dart';
import 'package:blood_link_app/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _auth = AuthService();
  final _email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter email to send you a password reset email"),
            SizedBox(height:20),
            CustomTextField(hint: "Enter Email", label: "Email", controller: _email),
            SizedBox(height: 20,),
            CustomButton(label: "Send Email", onPressed: () async{
              await _auth.sendPasswordResetLink(_email.text);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email sent for password reset")));
              Navigator.pop(context);
            }),
          ],
        ),
      )
    );
  }
}
