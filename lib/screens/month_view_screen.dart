import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import 'mood_prompt_screen.dart';

class MonthViewScreen extends StatefulWidget {
  const MonthViewScreen({super.key});

  @override
  MonthViewScreenState createState() => MonthViewScreenState();
}

class MonthViewScreenState extends State<MonthViewScreen> {
  Map<String, Color> _entries = {};
  late PageController _pageController;
  final int _initialPage = 1200; // Large number to allow infinite scrolling in both directions
  double _currentPage = 1200;
  int _snappedPageIndex = 1200;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage, viewportFraction: 0.55);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? _initialPage.toDouble();
      });
    });
    _loadEntries();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final entriesList = await DBHelper.instance.queryAllEntries();
    final moodsList = await DBHelper.instance.queryAllMoods();
    
    Map<int, Color> moodColors = {
      for (var item in moodsList) item[DBHelper.columnId]: Color(item[DBHelper.columnColor])
    };

    Map<String, Color> entriesMap = {};
    for (var entry in entriesList) {
      int moodId = entry[DBHelper.columnMoodId];
      entriesMap[entry[DBHelper.columnDate]] = moodColors[moodId] ?? Colors.white;
    }

    setState(() {
      _entries = entriesMap;
    });
  }

  int _daysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    }
    return DateTime(year, month + 1, 0).day;
  }

  DateTime _getMonthForPage(int pageIndex) {
    DateTime now = DateTime.now();
    int monthOffset = pageIndex - _initialPage;
    return DateTime(now.year, now.month + monthOffset, 1);
  }

  Widget _buildMoodChart(DateTime targetMonth, double width, int index) {
    Map<Color, int> colorCounts = {};
    int daysInMonth = _daysInMonth(targetMonth.year, targetMonth.month);
    
    for (int dayNumber = 1; dayNumber <= daysInMonth; dayNumber++) {
      DateTime day = DateTime(targetMonth.year, targetMonth.month, dayNumber);
      String dateStr = DateFormat('yyyy-MM-dd').format(day);
      if (_entries.containsKey(dateStr)) {
        Color c = _entries[dateStr]!;
        colorCounts[c] = (colorCounts[c] ?? 0) + 1;
      }
    }

    if (colorCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> segments = [];
    colorCounts.forEach((color, count) {
      segments.add(
        Expanded(
          flex: count,
          child: Container(color: color),
        ),
      );
    });

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _snappedPageIndex == index ? 1.0 : 0.0,
      child: Container(
        width: width,
        height: 6, // Slim proportional bar
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: segments,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.only(bottom: 0), // padding for bottom tab
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              HapticFeedback.lightImpact();
              setState(() {
                _snappedPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              DateTime targetMonth = _getMonthForPage(index);
              int daysInMonth = _daysInMonth(targetMonth.year, targetMonth.month);
              int firstWeekdayOffset = targetMonth.weekday % 7; // Sunday = 0
              int totalCells = daysInMonth + firstWeekdayOffset;
              
              double scale = 1.0;
              double opacity = 1.0;
              double translateY = 0.0;
              
              if (_pageController.position.haveDimensions) {
                double diff = (_currentPage - index).abs();
                scale = (1 - (diff * 0.25)).clamp(0.75, 1.0); // Scaled down slightly more
                opacity = (1 - (diff * 0.8)).clamp(0.2, 1.0);
                
                // Bring them closer to the focused month based on distance and direction
                if (index < _currentPage) {
                  translateY = diff * 70.0; // pull down towards center
                } else if (index > _currentPage) {
                  translateY = -(diff * 70.0); // pull up towards center
                }

                // Hide pages beyond the immediate adjacent ones
                if (diff >= 1.5) {
                  opacity = 0.0;
                }
              }

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scale: scale,
                    child: LayoutBuilder(
                    builder: (context, constraints) {
                      int columns = 7;
                      int rows = (totalCells / columns).ceil();

                      double crossAxisSpacing = 10;
                      double mainAxisSpacing = 10;

                      // Use a fixed max size ratio to allow scaling without breaking layout
                      double availableWidth = constraints.maxWidth - 40; // Horizontal padding
                      double availableHeight = constraints.maxHeight - 40; // Vertical padding

                      double itemWidth = (availableWidth - (columns - 1) * crossAxisSpacing) / columns;
                      double itemHeight = (availableHeight - (rows - 1) * mainAxisSpacing) / rows;

                      double squareSize = itemWidth < itemHeight ? itemWidth : itemHeight;
                      double gridWidth = columns * squareSize + (columns - 1) * crossAxisSpacing;
                      double gridHeight = rows * squareSize + (rows - 1) * mainAxisSpacing;

                      return Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
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
                                itemCount: totalCells,
                                itemBuilder: (context, gridIndex) {
                                  if (gridIndex < firstWeekdayOffset) {
                                    return const SizedBox.shrink(); // Empty space for offset days
                                  }
                                  
                                  int dayNumber = gridIndex - firstWeekdayOffset + 1;
                                  DateTime day = DateTime(targetMonth.year, targetMonth.month, dayNumber);
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

                                  return GestureDetector(
                                    onTap: () {
                                      // Prevent adding moods to future days
                                      if (dayDate.isAfter(today)) return;

                                      HapticFeedback.mediumImpact();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => MoodPromptScreen(date: day)),
                                      ).then((_) => _loadEntries());
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: squareColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: -30, // Sit below the month grid
                              left: 0,
                              right: 0,
                              child: _buildMoodChart(targetMonth, gridWidth, index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
