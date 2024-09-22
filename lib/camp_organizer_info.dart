import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blood_link_app/widgets/auth_button.dart';
import 'package:blood_link_app/widgets/auth_textfield.dart';

import 'auth/login.dart';

class CampOrganizerInfo extends StatefulWidget {
  final String uid;
  const CampOrganizerInfo({super.key, required this.uid});

  @override
  _CampOrganizerInfoState createState() => _CampOrganizerInfoState(uid : uid);
}

class _CampOrganizerInfoState extends State<CampOrganizerInfo> {
  _CampOrganizerInfoState({required this.uid});
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _orgNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _orgNameController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camp Organizer Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomTextField(
              hint: "Enter Camp Name",
              label: "Camp Name",
              controller: _orgNameController,
              icon: Icons.event_note,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Contact Number",
              label: "Contact Number",
              controller: _contactNumberController,
              icon: Icons.phone,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Address",
              label: "Address",
              controller: _addressController,
              icon: Icons.location_on,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter License Number",
              label: "License Number",
              controller: _licenseController,
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Submit",
              onPressed: _submitOrganizerInfo,
              color: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  _submitOrganizerInfo() async {
    final orgName = _orgNameController.text;
    final contactNumber = _contactNumberController.text;
    final address = _addressController.text;
    final licenseNo = _licenseController.text;

    if (orgName.isEmpty || contactNumber.isEmpty || address.isEmpty || licenseNo.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    try {
      await _firestore.collection('organizers').add({
        'uid' : uid,
        'camp_name': orgName,
        'contact_number': contactNumber,
        'address': address,
        'licenseNo' : licenseNo,
      });
      _showSnackBar("Camp organizer info saved successfully");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
      );
    } catch (e) {
      _showSnackBar("Error saving camp organizer info");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}