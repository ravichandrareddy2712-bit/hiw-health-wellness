import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/history_store.dart';
import '../../widgets/premium_glass_card.dart'; // 🆕

class StreakCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const StreakCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1; // Mon=0

    return Column(
      children: [
        // 📅 MONTH HEADER
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 16),
                onPressed: () => _changeMonth(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  monthName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => _changeMonth(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // 🗓️ GRID
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: PremiumGlassCard(
            // height: 320.h,  <-- REMOVED FIXED HEIGHT to prevent overflow
            padding: EdgeInsets.all(12.r),
            child: Column(
                mainAxisSize: MainAxisSize.min, // 📏 Shrink to fit content
                children: [
                // WEEKDAY LABELS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'].map((day) {
                    return SizedBox(
                      width: 30.w,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10.h),
                
                // DAYS GRID
                GridView.builder(
                  shrinkWrap: true, // 📏 Required when parent size is min
                  physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 4,
                      childAspectRatio: 0.8, // 📏 Taller cells to fit streak icon + circle
                    ),
                    itemCount: 42, // Max grid size (6 weeks)
                    itemBuilder: (context, index) {
                      if (index < firstDayOffset || index >= firstDayOffset + daysInMonth) {
                        return SizedBox.shrink();
                      }

                      final dayNum = index - firstDayOffset + 1;
                      final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                      
                      final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
                      final hasStreak = HistoryStore().hasStreak(date);
                      final entries = HistoryStore().getEntriesForDate(date);
                      final hasEntries = entries.isNotEmpty;

                      // 🔮 FUTURE CHECK
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final isFuture = date.isAfter(today);

                      // 🏥 HEALTH CHECK
                      Color? dayColor;
                      if (hasEntries) {
                        // Calculate healthy %
                        final stats = HistoryStore().getStatsForDate(date);
                        final healthyPct = stats['healthyPercent'] ?? 0;
                        if (healthyPct >= 50) {
                          dayColor = Colors.greenAccent; // Healthy
                        } else {
                          dayColor = Colors.redAccent; // Unhealthy
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (isFuture) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Day has not started yet! ⏳"),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          widget.onDateSelected(date);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasStreak)
                              Icon(Icons.local_fire_department, color: Colors.orange, size: 14)
                            else
                              SizedBox(height: 14.h),
                            
                            // DATE CIRCLE (Glass Simulation)
                            Container(
                              width: 32.w,
                              height: 32.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // 🎨 BACKGROUND: Selected=Green, Future=Dim, HasData=Red/Green, Else=Glass
                                color: isSelected
                                    ? Colors.greenAccent
                                    : (isFuture 
                                        ? Colors.white.withOpacity(0.02) 
                                        : (hasEntries 
                                            ? (dayColor ?? Colors.white).withOpacity(0.4) 
                                            : Colors.white.withOpacity(0.08))),
                                
                                // 💎 BORDER
                                border: Border.all(
                                  color: isSelected 
                                      ? Colors.white 
                                      : Colors.white.withOpacity(isFuture ? 0.05 : 0.2),
                                  width: isSelected ? 1.5 : 1,
                                ),

                                // 🔦 SHADOWS
                                boxShadow: [
                                  if (!isFuture)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4.r,
                                      offset: const Offset(0, 2),
                                    ),
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.greenAccent,
                                      blurRadius: 10.r,
                                      spreadRadius: 1.r,
                                    ),
                                  if (hasEntries && !isSelected && !isFuture)
                                     BoxShadow(
                                      color: (dayColor ?? Colors.white).withOpacity(0.3),
                                      blurRadius: 6.r,
                                    ),
                                ],

                                // 🌈 GRADIENT (Subtle Glass shine)
                                gradient: isSelected ? null : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(isFuture ? 0.0 : 0.2),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$dayNum',
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white 
                                      : (isFuture ? Colors.white30 : Colors.white),
                                  fontWeight: isSelected || hasEntries ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12.sp,
                                  shadows: isSelected ? [Shadow(color: Colors.black26, blurRadius: 2.r)] : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
