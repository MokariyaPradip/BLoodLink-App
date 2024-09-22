import 'package:blood_link_app/org_main_screen.dart';
import 'package:blood_link_app/widgets/welcome_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

import 'org_camp_details.dart'; // Firestore import

class CampsScreen extends StatefulWidget {
  @override
  _CampsScreenState createState() => _CampsScreenState();
}

class _CampsScreenState extends State<CampsScreen> {
  String selectedStatus = 'Upcoming'; // Default status filter
  DateTime? fromDate;
  DateTime? toDate;
  String? uid;

  // List to store fetched camps
  List<Map<String, dynamic>> camps = [];

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid; // Get current user's uid
    fetchCampsFromFirestore(); // Fetch camps from Firestore on initialization
  }

  // Function to fetch camps from Firestore
  Future<void> fetchCampsFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch only camps for the current logged-in organizer
    QuerySnapshot snapshot = await firestore
        .collection('camps')
        .where('organizer_id', isEqualTo: uid)
        .get();

    setState(() {
      camps = snapshot.docs.map((doc) {
        return {
          'camp_name': doc['camp_name'],
          'location': doc['camp_address'],
          'date': doc['camp_dt'],
          'status': doc['camp_status'],
          'camp_id': doc['camp_id'],
        };
      }).toList();
    });
  }

  // Filtering based on status and date range
  List<Map<String, dynamic>> get filteredCamps {
    return camps.where((camp) {
      bool matchesStatus = camp['status'] == selectedStatus;
      bool matchesDate = true;

      if (fromDate != null && toDate != null) {
        DateTime campDate = DateTime.parse(camp['date']);
        matchesDate = campDate.isAfter(fromDate!) && campDate.isBefore(toDate!);
      }

      return matchesStatus && matchesDate;
    }).toList();
  }

  // Function to pick date range
  Future<void> pickDateRange(BuildContext context) async {
    DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (dateRange != null) {
      setState(() {
        fromDate = dateRange.start;
        toDate = dateRange.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press to navigate to home screen
        Navigator.pushReplacement(context, OrgMainScreen() as Route<Object?>);
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            WelcomeSection(),
            // Status filters
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Upcoming', 'Completed', 'Cancelled']
                    .map((status) => ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedStatus = status;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    foregroundColor: selectedStatus == status
                        ? Colors.white
                        : Colors.black,
                    backgroundColor: selectedStatus == status
                        ? Color(0xFF74060F)
                        : Colors.grey[300],
                  ),
                  child: Text(status),
                ))
                    .toList(),
              ),
            ),
            // Date filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fromDate != null
                        ? DateFormat('yyyy-MM-dd').format(fromDate!)
                        : 'From Date',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    toDate != null
                        ? DateFormat('yyyy-MM-dd').format(toDate!)
                        : 'To Date',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  ElevatedButton(
                    onPressed: () => pickDateRange(context),
                    child: Text(
                      'Select Date Range',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF74060F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List of filtered camps or "No camps available" message
            Expanded(
              child: filteredCamps.isEmpty
                  ? Center(
                child: Text(
                  'No camps available.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: filteredCamps.length,
                itemBuilder: (context, index) {
                  var camp = filteredCamps[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CampDetailsPage(campId: camp['camp_id']),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              camp['camp_name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Location: ${camp['location']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(camp['date']))}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Status: ${camp['status']}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}