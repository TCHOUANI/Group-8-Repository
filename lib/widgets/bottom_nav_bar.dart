import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roadex/pages/home_page.dart';
import 'package:roadex/pages/learn_page.dart';
import 'package:roadex/pages/reports_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color(0xFFFF5400),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
                onTap: () {
                  Get.offAll(() => HomePage());
                },
                child: Icon(Icons.home_filled)),
            label: "Home",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
              ),
              label: "Alerts"),
          BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  Get.offAll(() => ReportsPage());
                },
                child: Icon(
                  Icons.note,
                ),
              ),
              label: "Reports"),
          BottomNavigationBarItem(
              icon: GestureDetector(
                  onTap: () {
                    Get.offAll(() => LearnPage());
                  },
                  child: Icon(Icons.menu_book)),
              label: "Learn"),
        ],
      ),
    );
  }
}
