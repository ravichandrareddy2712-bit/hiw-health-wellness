import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ProteinHistoryScreen extends StatelessWidget {
  ProteinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Protein History"),
      ),
      body: Center(
        child: Text(
          "Protein history coming soon",
          style: TextStyle(fontSize: 18.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    );
  }
}
