import 'package:blood_link_app/widgets/auth_button.dart';
import 'package:blood_link_app/widgets/slot_entry.dart';
import 'package:blood_link_app/widgets/welcome_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'camp_org_home.dart';

class AddCampSlots extends StatefulWidget {
  final String campId;

  AddCampSlots({required this.campId});

  @override
  _AddCampSlotsState createState() => _AddCampSlotsState();
}

class _AddCampSlotsState extends State<AddCampSlots> {
  final List<TextEditingController> _capacityControllers = [];
  final List<String> _slotTimes = [];
  int _numberOfSlots = 0;

  Future<void> _askNumberOfSlots() async {
    final int? number = await showDialog<int>(
      context: context,
      builder: (context) {
        int slots = 1;
        return AlertDialog(
          title: Text('How many slots?'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter number of slots'),
            onChanged: (value) {
              slots = int.tryParse(value) ?? 1;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(slots);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (number != null && number > 0) {
      setState(() {
        _numberOfSlots = number;
        _capacityControllers.clear();
        _slotTimes.clear();
        for (int i = 0; i < _numberOfSlots; i++) {
          _capacityControllers.add(TextEditingController());
          _slotTimes.add('Select Time');
        }
      });
    }
  }

  Future<void> _addSlots() async {
    for (int i = 0; i < _numberOfSlots; i++) {
      String slotId = FirebaseFirestore.instance.collection('slots').doc().id;
      await FirebaseFirestore.instance.collection('slots').doc(slotId).set({
        'camp_id': widget.campId,
        'slot_id': slotId,
        'slot_time': _slotTimes[i],
        'slot_capacity': int.parse(_capacityControllers[i].text),
        'available_slots': int.parse(_capacityControllers[i].text),
        'booked_by': [],
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Slots added successfully')));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => CampOrgHome(),
      ),
          (route) => false,
    );
  }

  Future<void> _pickTime(int index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _slotTimes[index] = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Prevent overflow
        child: Column(
          children: [
            WelcomeSection(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _askNumberOfSlots,
                    child: Text('Set Number of Slots'),
                  ),
                  const SizedBox(height: 20),

                  // Dynamically generated slot entries
                  if (_numberOfSlots > 0) ...List.generate(_numberOfSlots, (index) {
                    return SlotEntry(
                      initialTime: _slotTimes[index],
                      capacityController: _capacityControllers[index],
                      onTimePick: () => _pickTime(index),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Add Slots Button
                  CustomButton(
                    label: 'Add Slots',
                    onPressed: _addSlots,
                    color: Colors.red,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}