import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampDetailsPage extends StatelessWidget {
  final String campId;

  CampDetailsPage({required this.campId});

  Future<DocumentSnapshot> _getCampDetails() async {
    return await FirebaseFirestore.instance.collection('camps').doc(campId).get();
  }

  Future<QuerySnapshot> _getSlotBookings() async {
    return await FirebaseFirestore.instance.collection('slots').where('camp_id', isEqualTo: campId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camp Details'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getCampDetails(),
        builder: (context, campSnapshot) {
          if (campSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!campSnapshot.hasData || !campSnapshot.data!.exists) {
            return Center(child: Text('Camp not found'));
          }

          final campData = campSnapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Image
                campData['camp_poster'] != null
                    ? Image.network(campData['camp_poster'], height: 200, width: double.infinity, fit: BoxFit.cover)
                    : SizedBox.shrink(),

                SizedBox(height: 16),

                // Camp Name
                Text(
                  campData['camp_name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 8),

                // Camp Date
                Text(
                  'Date: ${campData['camp_dt']}',
                  style: TextStyle(fontSize: 18),
                ),

                SizedBox(height: 8),

                // Camp Location
                Text(
                  'Location: ${campData['camp_address']}',
                  style: TextStyle(fontSize: 18),
                ),

                SizedBox(height: 16),

                // Slots and Donors
                Text(
                  'Slots and Donors:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                FutureBuilder<QuerySnapshot>(
                  future: _getSlotBookings(),
                  builder: (context, slotSnapshot) {
                    if (slotSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!slotSnapshot.hasData || slotSnapshot.data!.docs.isEmpty) {
                      return Text('No slots booked yet.');
                    }

                    final slots = slotSnapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        final slotData = slots[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text('Slot Time: ${slotData['slot_time']}'),
                          subtitle: Text('Booked by: ${slotData['booked_by'] ?? 'No one'}'),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}