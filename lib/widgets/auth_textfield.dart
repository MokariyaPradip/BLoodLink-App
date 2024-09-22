import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool obscureText;
  final IconButton? suffixIcon;
  final TextInputType? keyboardType; // Added keyboardType

  CustomTextField({
    super.key,
    required this.hint,
    required this.label,
    required this.controller,
    this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType, // Added keyboardType to constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType, // Added keyboardType to TextField
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}