import 'package:flutter/material.dart';

import 'auth_textfield.dart';

class SlotEntry extends StatelessWidget {
  final String initialTime;
  final TextEditingController capacityController;
  final VoidCallback onTimePick;

  SlotEntry({
    required this.initialTime,
    required this.capacityController,
    required this.onTimePick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Slot Time Picker
        TextButton.icon(
          onPressed: onTimePick,
          icon: Icon(Icons.access_time),
          label: Text(initialTime),
        ),
        const SizedBox(height: 20),

        // Slot Capacity Input
        CustomTextField(
          controller: capacityController,
          hint: 'Enter Slot Capacity',
          label: 'Slot Capacity',
          icon: Icons.people,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}