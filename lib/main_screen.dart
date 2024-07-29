import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'home_page.dart';
import 'mapclass/map_page.dart';
import 'search_page.dart';
import 'profile_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MapPage(),
    SearchPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0), // Dış kenarları daraltma
          child: SalomonBottomBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              SalomonBottomBarItem(
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0), // İkonların yatay boşluklarını azaltma
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
                  child: Icon(Icons.search),
                ),
                title: Text("Search"),
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}
