import 'package:blood_link_app/widgets/add_camp_button.dart';
import 'package:blood_link_app/widgets/camp_card.dart';
import 'package:blood_link_app/widgets/welcome_section.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for the current user's uid

class CampOrgHome extends StatefulWidget {
  const CampOrgHome({super.key});

  @override
  State<CampOrgHome> createState() => _CampOrgHomeState();
}

class _CampOrgHomeState extends State<CampOrgHome> {
  String? uid;

  @override
  void initState() {
    super.initState();
    // Get the currently logged-in user's UID
    uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeSection(),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: AddCampButton(),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Upcoming Camps',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 2),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('camps')
                  .where('organizer_id', isEqualTo: uid)  // Filter by organizer's uid
                  .orderBy('camp_dt', descending: false) // Order by camp date
                  .limit(10)  // Limit to 10 results
                  .snapshots(),
              builder: (context, snapshot) {
                // Check if snapshot has an error or no data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final camps = snapshot.data?.docs ?? [];

                if (camps.isEmpty) {
                  // Display message if there are no camps
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No Upcoming Camps Available",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  );
                }

                // Display camps if available
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: camps.length,
                  itemBuilder: (context, index) {
                    final campData = camps[index].data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CampCard(
                        campName: campData['camp_name'],
                        campLocation: campData['camp_address'],
                        campPosterUrl: campData['camp_poster'],
                        campDate: DateTime.parse(campData['camp_dt']),
                        campId: campData['camp_id'],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}