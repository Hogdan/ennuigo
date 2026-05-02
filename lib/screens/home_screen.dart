import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Map<String, Color> _entries = {};
  final int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entriesList = await DBHelper.instance.queryAllEntries();
    final moodsList = await DBHelper.instance.queryAllMoods();
    
    Map<int, Color> moodColors = {
      for (var item in moodsList) item[DBHelper.columnId]: Color(item[DBHelper.columnColor])
    };

    Map<String, Color> entriesMap = {};
    for (var entry in entriesList) {
      if (entry[DBHelper.columnDate].startsWith('$_currentYear-')) {
        int moodId = entry[DBHelper.columnMoodId];
        entriesMap[entry[DBHelper.columnDate]] = moodColors[moodId] ?? Colors.white;
      }
    }

    setState(() {
      _entries = entriesMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    int daysInYear = isLeapYear(_currentYear) ? 366 : 365;
    DateTime firstDayOfYear = DateTime(_currentYear, 1, 1);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8), // extra padding for bottom tab
          child: LayoutBuilder(
            builder: (context, constraints) {
              int columns = 14;
              int rows = (daysInYear / columns).ceil();
              
              double crossAxisSpacing = 6;
              double mainAxisSpacing = 6;
              
              double itemWidth = (constraints.maxWidth - (columns - 1) * crossAxisSpacing) / columns;
              double itemHeight = (constraints.maxHeight - (rows - 1) * mainAxisSpacing) / rows;
              
              double squareSize = itemWidth < itemHeight ? itemWidth : itemHeight;
              double gridWidth = columns * squareSize + (columns - 1) * crossAxisSpacing;
              double gridHeight = rows * squareSize + (rows - 1) * mainAxisSpacing;
              
              return Center(
                child: SizedBox(
                  width: gridWidth,
                  height: gridHeight,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: daysInYear,
                    itemBuilder: (context, index) {
                DateTime day = firstDayOfYear.add(Duration(days: index));
                String dateStr = DateFormat('yyyy-MM-dd').format(day);
                
                DateTime now = DateTime.now();
                DateTime today = DateTime(now.year, now.month, now.day);
                DateTime dayDate = DateTime(day.year, day.month, day.day);

                Color squareColor;
                if (_entries.containsKey(dateStr)) {
                  squareColor = _entries[dateStr]!;
                } else if (dayDate.isAfter(today)) {
                  squareColor = Colors.white70; // Almost white for future days
                } else {
                  squareColor = Colors.grey[800]!; // Gray for past days with no mood
                }

                return Container(
                  decoration: BoxDecoration(
                    color: squareColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    if (year % 400 != 0) return false;
    return true;
  }
}
