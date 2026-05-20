import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../core/theme_manager.dart';
import 'history/streak_calendar.dart';
import 'history/animated_stats_circle.dart';
import 'history/daily_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    // 🚀 Immediate Navigation on Date Click
    _navigateToDetails();
  }

  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyDetailScreen(date: _selectedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 140.h),
      child: Column(
        children: [
          // 🗓️ STREAK CALENDAR
          StreakCalendar(
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
          ),
          
          SizedBox(height: 10.h),

          // 🔥 ANIMATED STATS
          AnimatedStatsCircle(
            date: _selectedDate,
            onTap: _navigateToDetails,
          ),

          SizedBox(height: 20.h),
          
          Text(
            "Track your Daily Food\nKeep the Streak Alive! 🔥",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
