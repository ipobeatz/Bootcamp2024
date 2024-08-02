import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:field_analysis/homeclass/home_page.dart';
import 'package:field_analysis/mapclass/map_page.dart';
import 'package:field_analysis/profileclass/profile_detail.dart';
import 'package:field_analysis/profileclass/profile_page.dart';
import 'package:field_analysis/fieldclass/field_add_screen.dart';

class MyHomePage extends StatefulWidget {
  final int initialIndex;

  const MyHomePage({super.key, this.initialIndex = 0});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex;

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MapPage(),
    FieldAddScreen(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Başlangıç indexini ayarla
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: SalomonBottomBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                SalomonBottomBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(Icons.home),
                  ),
                  title: Text("Home"),
                  selectedColor: Colors.purple.shade400,
                ),
                SalomonBottomBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(Icons.map),
                  ),
                  title: Text("Map"),
                  selectedColor: Colors.pink.shade400,
                ),
                SalomonBottomBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(Icons.add_chart_outlined),
                  ),
                  title: Text("Soil Analysis"),
                  selectedColor: Colors.orange.shade400,
                ),
                SalomonBottomBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(Icons.person),
                  ),
                  title: Text("Profile"),
                  selectedColor: Colors.blue.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
