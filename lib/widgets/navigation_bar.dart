import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final int selectedIndexNavBar;

  const MyBottomNavigationBar({Key? key, required this.selectedIndexNavBar})
      : super(key: key);

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  void _onTap(int index) {
    if (widget.selectedIndexNavBar == index) return; // Avoid unnecessary reloads

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/exercise');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/user');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/workout-planner');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryWhite, // Background color
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.primaryWhite,
          selectedItemColor: AppTheme.primaryBlue, // Active icon color
          unselectedItemColor: Colors.grey[600], // Inactive icon color
          currentIndex: widget.selectedIndexNavBar,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'Exercise',
              icon: Icon(Icons.directions_run_outlined),
              activeIcon: Icon(Icons.directions_run),
            ),
            BottomNavigationBarItem(
              label: 'User',
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
            ),
            BottomNavigationBarItem(
              label: 'Planner',
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
            ),
          ],
        ),
      ),
    );
  }
}
