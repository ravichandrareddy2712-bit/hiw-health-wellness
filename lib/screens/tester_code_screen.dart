import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_state.dart';
import '../services/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TesterCodeScreen extends StatefulWidget {
  final VoidCallback onVerified;

  const TesterCodeScreen({super.key, required this.onVerified});

  @override
  State<TesterCodeScreen> createState() => _TesterCodeScreenState();
}

class _TesterCodeScreenState extends State<TesterCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _validCodes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  Future<void> _loadCodes() async {
    // 🌍 Start waking up the backend immediately
    UserApi.healthCheck();

    try {
      final data = await rootBundle.loadString('assets/tester_codes.txt');
      setState(() {
        _validCodes = data
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error loading tester codes. Please contact admin.";
        _isLoading = false;
      });
    }
  }

  Future<void> _verify() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Local check (optional, for speed)
      if (!_validCodes.contains(code)) {
        throw Exception("Invalid tester code. Access Denied.");
      }

      // 2. Fetch user email for backend tracking
      final email = await AppState.getEmail() ?? "anonymous";

      // 3. Backend check (Prevent multi-person usage)
      await UserApi.verifyTesterCode(code, email);

      await AppState.setTesterVerified(true);
      await AppState.setLastVerifiedCode(code);
      widget.onVerified();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_rounded, size: 80, color: Colors.blueAccent),
              SizedBox(height: 24.h),
              Text(
                'TESTER ACCESS',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Please enter your unique tester code to proceed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 40.h),
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 16.h),
                    Text(
                      'Waking up backend server...\nThis may take 30-60 seconds on first run.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    ),
                  ],
                )
              else ...[
                TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter Code (e.g. HIW-XXXXX)',
                    hintStyle: TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    errorText: _error,
                    errorStyle: TextStyle(color: Colors.redAccent),
                  ),
                  onSubmitted: (_) => _verify(),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'VERIFY & ENTER',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
