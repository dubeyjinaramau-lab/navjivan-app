import 'package:flutter/material.dart';

import 'matches_screen.dart';
import 'chat_screen.dart';
import 'my_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;

  final List<Widget> _pages = const [

    MatchesScreen(),

    ChatScreen(
      partnerName: "User",
    ),

   MyProfileScreen(),

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedIndex,

        onTap: (index) {

          setState(() {

            _selectedIndex = index;

          });

        },
        selectedItemColor: const Color(0xFF388E3C),
        unselectedItemColor: Colors.grey,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Matches",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],

      ),

    );

  }

}