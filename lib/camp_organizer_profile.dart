import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CampOrganizerProfile extends StatefulWidget {
  @override
  _CampOrganizerProfileState createState() => _CampOrganizerProfileState();
}

class _CampOrganizerProfileState extends State<CampOrganizerProfile> {
  String? uid;
  DocumentSnapshot? organizerData;
  int totalCamps = 0;
  int totalDonors = 0;
  double totalUnitsCollected = 0.0;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    fetchOrganizerData();
    fetchAnalyticsData();
  }

  Future<void> fetchOrganizerData() async {
    if (uid != null) {
      final data = await FirebaseFirestore.instance
          .collection('organizers')
          .doc(uid)
          .get();
      setState(() {
        organizerData = data;
      });
    }
  }

  Future<void> fetchAnalyticsData() async {
    if (uid != null) {
      // Fetch total camps
      final campsSnapshot = await FirebaseFirestore.instance
          .collection('camps')
          .where('organizer_id', isEqualTo: uid)
          .get();
      totalCamps = campsSnapshot.size;

      // Fetch total donors and units collected from donations
      final donationsSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('organizer_id', isEqualTo: uid)
          .get();

      for (var doc in donationsSnapshot.docs) {
        totalDonors++;
        totalUnitsCollected += doc['units_donated'] ?? 0;
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camp Organizer Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Organizer Info Section
            Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: organizerData != null &&
                        organizerData!['organizer_logo'] != null
                        ? NetworkImage(organizerData!['organizer_logo'])
                        : AssetImage('assets/default_logo.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    organizerData != null
                        ? organizerData!['organizer_name']
                        : 'Loading...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    organizerData != null
                        ? organizerData!['contact_no']
                        : 'Loading...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    organizerData != null
                        ? organizerData!['address']
                        : 'Loading...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Analytics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Analytics Cards
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnalyticsCard(
                    context,
                    'Camps Organized',
                    totalCamps.toString(),
                    Colors.blueAccent,
                  ),
                  _buildAnalyticsCard(
                    context,
                    'Donors',
                    totalDonors.toString(),
                    Colors.green,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnalyticsCard(
                    context,
                    'Units Collected',
                    totalUnitsCollected.toStringAsFixed(1),
                    Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
      BuildContext context, String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: 120,
        width: 120,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}