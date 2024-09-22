import 'dart:developer';
import 'package:blood_link_app/widgets/welcome_section.dart';
import 'package:flutter/material.dart';
import 'package:blood_link_app/widgets/auth_textfield.dart'; // Your custom text field
import 'package:blood_link_app/widgets/auth_button.dart';   // Your custom button
import 'package:blood_link_app/auth/auth_service.dart';     // To get current user
import 'package:firebase_storage/firebase_storage.dart';    // For file upload
import 'package:cloud_firestore/cloud_firestore.dart';      // Firebase Firestore
import 'package:image_picker/image_picker.dart';            // For picking the image
import 'package:intl/intl.dart';
import 'dart:io';

import 'add_camp_slots.dart';

class AddCampForm extends StatefulWidget {
  @override
  _AddCampFormState createState() => _AddCampFormState();
}

class _AddCampFormState extends State<AddCampForm> {
  final _auth = AuthService();
  final _campNameController = TextEditingController();
  final _campDateController = TextEditingController();
  final _campAddressController = TextEditingController();
  final _bloodTypesController = TextEditingController(); // User can input comma-separated blood types
  File? _campPosterFile; // For storing the selected image file
  UploadTask? uploadTask;
  String _campStatus = 'Upcoming'; // Default status
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _campNameController.dispose();
    _campDateController.dispose();
    _campAddressController.dispose();
    _bloodTypesController.dispose();
    super.dispose();
  }

  Future<void> _addCamp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get current user ID (organizer_id)
        final currentUser = await _auth.getUserData();
        if (currentUser != null) {
          String organizerId = currentUser["uid"];

          // Generate a unique camp ID
          String campId = FirebaseFirestore.instance.collection('camps').doc().id;

          // Upload the camp poster and get the download URL
          String? campPosterUrl = await _uploadCampPoster(campId);

          // Convert comma-separated blood types into a list
          List<String> bloodTypes = _bloodTypesController.text.split(',').map((e) => e.trim()).toList();

          // Add camp data to Firestore
          await FirebaseFirestore.instance.collection('camps').doc(campId).set({
            'organizer_id': organizerId,
            'camp_id': campId,
            'camp_name': _campNameController.text,
            'camp_dt': _campDateController.text,
            'camp_address': _campAddressController.text,
            'camp_status': _campStatus,
            'blood_types': bloodTypes,
            'camp_poster': campPosterUrl ?? '', // Store the URL from Firebase Storage
          });

          log('Camp added successfully');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camp added successfully')));

          // Navigate to the AddCampSlots screen and pass the campId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddCampSlots(campId: campId), // Pass the campId
            ),
          );
        }
      } catch (e) {
        log('Error adding camp: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding camp')));
      }
    }
  }

  Future<String?> _uploadCampPoster(String campId) async {
    if (_campPosterFile == null) {
      log('No camp poster file selected for upload');
      return null; // Return early if no file is selected
    }

    try {
      log('Uploading camp poster from path: ${_campPosterFile!.path}');
      final storageRef = FirebaseStorage.instance.ref().child('camp_posters/$campId');
      UploadTask uploadTask = storageRef.putFile(_campPosterFile!);

      TaskSnapshot snapshot = await uploadTask.whenComplete(()=>null);

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        log('Camp poster uploaded successfully: $downloadUrl');
        return downloadUrl; // Return the image URL after upload
      } else {
        log('Failed to upload camp poster: ${snapshot.state}');
        return null;
      }
    } catch (e) {
      log('Error uploading camp poster or getting download URL: $e');
      return null;
    }
  }

  Future<void> _pickCampPoster() async {
    final picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picture != null) {
      setState(() {
        _campPosterFile = File(picture.path);
      });
    }
  }

  Future<void> _selectCampDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Current date
      firstDate: DateTime(2022),   // Limit the start date
      lastDate: DateTime(2101),    // Limit the end date
    );
    if (pickedDate != null) {
      // Format the picked date and set it in the text field
      setState(() {
        _campDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WelcomeSection(),
          SizedBox(height: 15,),
          Text(
            'Add Camp',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Camp Name
                      CustomTextField(
                        controller: _campNameController,
                        hint: 'Enter Camp Name',
                        label: 'Camp Name',
                        icon: Icons.campaign,
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () => _selectCampDate(context), // Show date picker on tap
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: _campDateController,
                            hint: 'Enter Camp Date',
                            label: 'Camp Date',
                            icon: Icons.date_range,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Camp Address
                      CustomTextField(
                        controller: _campAddressController,
                        hint: 'Enter Camp Address',
                        label: 'Camp Address',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 20),

                      // Blood Types
                      CustomTextField(
                        controller: _bloodTypesController,
                        hint: 'Enter Blood Types (e.g. A+, O-, AB+)',
                        label: 'Blood Types',
                        icon: Icons.bloodtype,
                      ),
                      const SizedBox(height: 20),

                      // Camp Poster
                      _campPosterFile != null
                          ? Image.file(
                        _campPosterFile!,
                        height: 150,
                      )
                          : const Text("No Camp Poster Selected"),
                      TextButton.icon(
                        onPressed: _pickCampPoster,
                        icon: Icon(Icons.image),
                        label: Text('Select Camp Poster'),
                      ),
                      const SizedBox(height: 20),

                      // Add Camp Button
                      CustomButton(
                        label: 'Next',
                        onPressed: _addCamp,
                        color: Colors.red,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}