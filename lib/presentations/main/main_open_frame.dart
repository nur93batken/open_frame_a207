import 'package:flutter/material.dart';
import 'package:open_frame_a207/presentations/notes/notes_screen_open_frame.dart';
import 'package:open_frame_a207/presentations/projects/projects_screen_open_frame.dart';
import 'package:open_frame_a207/presentations/settings/setting_open_frame.dart';

import '../statics/personal_statistics_screen_open_frame.dart';

class MainScreenOpenFrame extends StatefulWidget {
  const MainScreenOpenFrame({super.key});

  @override
  State<MainScreenOpenFrame> createState() => _MainScreenOpenFrameState();
}

class _MainScreenOpenFrameState extends State<MainScreenOpenFrame> {
  int currentIndex = 0;
  final List<Widget> pages = [
    ProjectsScreenOpenFrame(),
    NotesScreenOpenFrame(),
    PersonalStatisticsScreenOpenFrame(),
    SettingPageOpenFrame(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF7F7F7),
      body: pages[currentIndex],

      bottomNavigationBar: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color(0xFFEBEDF1),
        ),
        child: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BottomNavigationBar(
        elevation: 20,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(color: Colors.black),
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        backgroundColor: Color(0xFFEBEDF1),
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: _navBarItems(currentIndex),
      ),
    );
  }

  List<BottomNavigationBarItem> _navBarItems(int currentIndex) {
    return [
      _buildNavItem('Projects', 'assets/icons/navbar_icon1.png', 0),
      _buildNavItem('Notes', 'assets/icons/navbar_icon2.png', 1),
      _buildNavItem('Statistics', 'assets/icons/navbar_icon3.png', 2),
      _buildNavItem('Settings', 'assets/icons/navbar_icon4.png', 3),
    ];
  }

  BottomNavigationBarItem _buildNavItem(String label, String icon, int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        icon,
        height: 30,
        width: 30,

        color: currentIndex == index ? Colors.black : Colors.grey,
      ),
      label: label,
    );
  }
}
