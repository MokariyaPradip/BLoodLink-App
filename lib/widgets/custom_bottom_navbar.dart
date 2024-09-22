import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final List<Widget> pages;  // List of pages to navigate between
  final List<BottomNavigationBarItem> navItems;  // List of bottom navigation bar items
  final Color selectedColor;
  final Color unselectedColor;

  const CustomBottomNavBar({
    Key? key,
    required this.pages,
    required this.navItems,
    this.selectedColor = const Color(0xFF74060F),
    this.unselectedColor = Colors.grey,
  }) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.pages[_currentIndex],  // Display the current selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: widget.selectedColor,  // Red color for the selected item
        unselectedItemColor: widget.unselectedColor,  // Grey color for unselected items
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: widget.navItems,
      ),
    );
  }
}