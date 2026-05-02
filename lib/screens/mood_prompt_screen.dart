import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../widgets/mood_icon.dart';
import 'main_tab_screen.dart';
import 'draw_mood_screen.dart';

class MoodPromptScreen extends StatefulWidget {
  final DateTime date;
  
  const MoodPromptScreen({super.key, required this.date});

  @override
  MoodPromptScreenState createState() => MoodPromptScreenState();
}

class MoodPromptScreenState extends State<MoodPromptScreen> {
  List<Map<String, dynamic>> _moods = [];

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    final moods = await DBHelper.instance.queryAllMoods();
    setState(() {
      _moods = moods;
    });
  }

  Future<void> _selectMood(int moodId) async {
    String dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    await DBHelper.instance.insertOrUpdateEntry(dateStr, moodId);
    
    if (!mounted) return;

    // Navigate home, clearing stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainTabScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: _moods.length + 1, // +1 for the "add new" button
            itemBuilder: (context, index) {
              if (index == _moods.length) {
                // Add new mood button
                return GestureDetector(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    if (!mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const DrawMoodScreen()),
                    );
                    _loadMoods(); // Reload after potential new drawing
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, color: Colors.white, size: 50),
                    ),
                  ),
                );
              }
              
              var mood = _moods[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _selectMood(mood[DBHelper.columnId]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: MoodIcon(
                      pathDataJson: mood[DBHelper.columnPathData],
                      color: Color(mood[DBHelper.columnColor]),
                      size: 80,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
