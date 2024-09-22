import 'package:blood_link_app/camp_organizer_profile.dart';
import 'package:flutter/material.dart';
import 'camp_screen.dart';
import 'widgets/custom_bottom_navbar.dart';  // Import your CustomBottomNavBar
import 'camp_org_home.dart';     // Donor home page

class OrgMainScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    // Define pages based on userType
    List<Widget> organizerPages = [
      CampOrgHome(),
      CampsScreen(),
      CampOrganizerProfile(),
    ];

    // Define navigation items for the bottom navigation bar
    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_hospital_outlined),
        label: 'Camps',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ];

    return CustomBottomNavBar(
      pages: organizerPages,
      navItems: navItems,  // Pass the navigation items
    );
  }
}