import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'Pages/camera.dart';
import 'Pages/translate.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    Translate(),
    OcrHomePage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        color: Colors.lightBlueAccent.shade100,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: GNav(
              rippleColor: Colors.pinkAccent[100]??Colors.pinkAccent,
              hoverColor: Colors.pinkAccent,
              backgroundColor: Colors.lightBlueAccent.shade100,
              tabBorderRadius: 80,
              color: Colors.pinkAccent[100],
              activeColor: Colors.white70,
              gap: 8,
              iconSize: 24,
              duration: Duration(milliseconds: 800),
              tabBackgroundColor: Colors.pinkAccent[100]??Colors.pinkAccent,
              padding: EdgeInsets.all(16),
              tabs: [
                GButton(
                  icon: Icons.text_snippet_outlined,
                  text: 'Text',
                ),
                GButton(
                  icon: Icons.camera_alt_outlined,
                  text: 'Photo',
                ),
              ],
              selectedIndex: currentIndex,
              onTabChange: onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
