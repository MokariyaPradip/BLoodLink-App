import 'package:flutter/material.dart';
import 'camp_screen.dart';
import 'donor_home.dart';
import 'widgets/custom_bottom_navbar.dart';  // Import your CustomBottomNavBar

class DonorMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define pages based on userType
    List<Widget> donorPages = [
      DonorHome(),
      CampsScreen(),
      BookingScreen(),
      ProfileScreen(),
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
        icon: Icon(Icons.app_registration),
        label: 'Booked',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ];

    return CustomBottomNavBar(
      pages: donorPages,
      navItems: navItems,  // Pass the navigation items
    );
  }
}


class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Screen'));
  }
}

class BookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Screen'));
  }
}