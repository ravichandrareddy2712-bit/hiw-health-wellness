//purchase screen
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  Future<void> _openYt() async {
    final url = Uri.parse('https://www.youtube.com/results?search_query=easy+vegetable+recipe+healthy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text('Shop'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rocket_launch_rounded,
                size: 80,
                color: Colors.tealAccent,
              ),
              SizedBox(height: 24.h),
              Text(
                'THIS IS A HUGE UPDATE GATHERING IDEAS STAY!TUNES!😀😀',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                height: 2.h,
                width: 60.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
