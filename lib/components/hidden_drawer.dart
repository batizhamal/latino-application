import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:latino_app/pages/profile/profile.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];

  final mySelectedStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: Colors.white,
  );

  final myBaseStyle = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: Color(0xFF383C46),
  );

  @override
  void initState() {
    super.initState();

    _pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Homepage',
          baseStyle: myBaseStyle,
          selectedStyle: mySelectedStyle,
          colorLineSelected: const Color(0xFFE0503D),
        ),
        const HomePage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Profile',
          baseStyle: myBaseStyle,
          selectedStyle: mySelectedStyle,
          colorLineSelected: const Color(0xFFE0503D),
        ),
        const ProfilePage(),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      screens: _pages,
      backgroundColorMenu: const Color(0xFFB9C7F8),
      initPositionSelected: 0,
      slidePercent: 40,
    );
  }
}
