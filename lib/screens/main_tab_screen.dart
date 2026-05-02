import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'month_view_screen.dart';
import 'mood_prompt_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  MainTabScreenState createState() => MainTabScreenState();
}

class MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),      // Index 0: Year View
    const MonthViewScreen(), // Index 1: Month View
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              backgroundColor: Colors.grey[900],
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white38,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          if (index == 2) {
            // "Add Current Day" tapped, push the Mood prompt screen without changing the tab
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MoodPromptScreen(date: DateTime.now())),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on, size: 30),
            label: 'Year', // Labels are hidden
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_month, size: 30),
            label: 'Month',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 30),
            label: 'Add Today',
          ),
        ],
      ),
    ),
        ),
      ),
    );
  }
}
