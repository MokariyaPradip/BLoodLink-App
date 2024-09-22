import 'package:blood_link_app/auth/login.dart';
import 'package:blood_link_app/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore to store user info
import 'package:intl/intl.dart';


class DonorInfoPage extends StatefulWidget {
  final String uid;
  const DonorInfoPage({super.key, required this.uid});

  @override
  _DonorInfoPageState createState() => _DonorInfoPageState(uid:uid);
}

class _DonorInfoPageState extends State<DonorInfoPage> {
  _DonorInfoPageState({required this.uid});
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _contactController = TextEditingController();
  String? _diseaseHistory = "No"; // Default selection
  final _diseaseDetailsController = TextEditingController();
  DateTime? _selectedDOB; // Date of Birth
  final _addressController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _bloodGroupController.dispose();
    _contactController.dispose();
    _diseaseDetailsController.dispose();
    _addressController.dispose();
  }

  Future<void> _submitUserInfo() async {
    String name = _nameController.text;
    String bloodGroup = _bloodGroupController.text;
    String contact = _contactController.text;
    String diseaseHistory = _diseaseHistory!;
    String diseaseDetails = _diseaseDetailsController.text;
    String address = _addressController.text;

    if (name.isNotEmpty && _selectedDOB != null && bloodGroup.isNotEmpty && contact.isNotEmpty) {
      try {
        await _firestore.collection('donors').add({
          'uid' : uid,
          'name': name,
          'dob': _selectedDOB,
          'blood_group': bloodGroup,
          'contact': contact,
          'disease_history': diseaseHistory,
          'disease_details': diseaseDetails,
          'address' : address
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donor data saved successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving donor info')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
    }
  }

  Future<void> _selectDOB(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDOB) {
      setState(() {
        _selectedDOB = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            const Center(
              child: Text(
                "User Information",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF74060F),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              hint: "Enter your name",
              label: "Name",
              controller: _nameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            _buildDOBField(context),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter your blood group",
              label: "Blood Group",
              controller: _bloodGroupController,
              icon: Icons.water_drop,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter your contact number",
              label: "Contact Number",
              controller: _contactController,
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
            _buildDiseaseHistoryDropdown(),
            const SizedBox(height: 20),
            if (_diseaseHistory == "Yes") ...[
              CustomTextField(
                hint: "Describe your blood-related disease history",
                label: "Disease Details",
                controller: _diseaseDetailsController,
                icon: Icons.medical_services,
              ),
            ],
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDOBField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDOB(context),
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: TextEditingController(
              text: _selectedDOB == null
                  ? ""
                  : DateFormat('yyyy-MM-dd').format(_selectedDOB!),
            ),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: "Select your date of birth",
              labelText: "Date of Birth",
              labelStyle: const TextStyle(color: Color(0xFF74060F)),
              prefixIcon: const Icon(Icons.cake, color: Color(0xFF202020)),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF94A0B4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF74060F)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiseaseHistoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _diseaseHistory,
      decoration: InputDecoration(
        labelText: 'Any blood-related disease history?',
        labelStyle: const TextStyle(color: Color(0xFF74060F)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF94A0B4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF74060F)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "No", child: Text("No")),
        DropdownMenuItem(value: "Yes", child: Text("Yes")),
      ],
      onChanged: (value) {
        setState(() {
          _diseaseHistory = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: Colors.transparent, // Transparent to allow gradient
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0, // No shadow on the button itself, as it's covered by the gradient
      ),
      onPressed: _submitUserInfo, // Method to handle the button press
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF250101), Color(0xFF74060F)], // Your app's gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
          alignment: Alignment.center,
          child: const Text(
            "Submit",
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: Colors.white, // Text color on gradient
            ),
          ),
        ),
      ),
    );
  }
}