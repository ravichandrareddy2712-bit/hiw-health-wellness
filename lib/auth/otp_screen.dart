import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiw/auth/reset_password_screen.dart';
import 'package:hiw/auth/user_info_screen.dart';
import '../widgets/particle_background.dart';
import '../services/otp_service.dart';
import 'username_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  final bool isForgotPassword;

  const OtpScreen({
    Key? key,
    required this.email,
    required this.password,
    this.isForgotPassword = false,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  late AnimationController _cardController;
  late AnimationController _glowController;
  late AnimationController _timerController;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<double> _glowAnimation;
  
  bool isLoading = false;
  bool canResend = false;
  int remainingSeconds = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _timerController = AnimationController(
      duration: const Duration(seconds: 300),
      vsync: this,
    );
    
    _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _cardController.forward();
    });
    
    // Send OTP on init
    _sendOTP();
    
    // Start timer
    _startTimer();
  }

  void _startTimer() {
    _timerController.forward(from: 0);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      
      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          canResend = true;
        }
      });
      
      if (remainingSeconds <= 0) return false;
      return true;
    });
  }

  Future<void> _sendOTP() async {
    final otpService = OtpService();
    final success = await otpService.sendOTP(widget.email);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.email, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text('OTP sent to ${widget.email}'),
              ),
            ],
          ),
          backgroundColor: Colors.green.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      _showError('Please enter complete OTP');
      return;
    }
    
    setState(() => isLoading = true);
    HapticFeedback.mediumImpact();
    
    final otpService = OtpService();
    final isValid = otpService.verifyOTP(widget.email, otp);
    
    if (isValid) {
      if (!mounted) return;
      
      // _timer?.cancel(); // Assuming _timer is a Timer object, which is not declared in this file.
      // Show success briefly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP Verified!'),
          backgroundColor: Colors.green.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );

      // Navigate based on flow
      // Navigate based on flow
      if (widget.isForgotPassword) {
        // Navigate to Reset Password Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: widget.email),
          ),
        );
      } else {
        // Continue Registration Flow -> Username Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UsernameScreen(
              email: widget.email,
              password: widget.password,
            ),
          ),
        );
      }
    } else {
      if (!mounted) return;
      _showError('Invalid OTP. Please try again.');
      HapticFeedback.heavyImpact();
    }
    
    if (mounted) setState(() => isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _resendOTP() async {
    setState(() {
      canResend = false;
      remainingSeconds = 300;
    });
    _startTimer();
    await _sendOTP();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _glowController.dispose();
    _timerController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFF0F2027), const Color(0xFF203A43), _glowController.value)!,
                      Color.lerp(const Color(0xFF203A43), const Color(0xFF2C5364), _glowController.value)!,
                      Color.lerp(const Color(0xFF2C5364), const Color(0xFF0F2027), _glowController.value)!,
                    ],
                  ),
                ),
              );
            },
          ),
          
          const ParticleBackground(),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                child: FadeTransition(
                  opacity: _cardOpacity,
                  child: ScaleTransition(
                    scale: _cardScale,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: EdgeInsets.all(28.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(_glowAnimation.value),
                                  width: 1.5.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 20.r,
                                    spreadRadius: 5.r,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 70.w,
                                height: 70.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.mail_lock,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              
                              SizedBox(height: 24.h),
                              
                              Text(
                                'Verify OTP',
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              
                              SizedBox(height: 8.h),
                              
                              Text(
                                'Enter the 6-digit code sent to',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              
                              SizedBox(height: 4.h),
                              
                              Text(
                                widget.email,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              
                              SizedBox(height: 32.h),
                              
                              // OTP Input Fields
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (index) {
                                  return _buildOTPBox(index);
                                }),
                              ),
                              
                              SizedBox(height: 24.h),
                              
                              // Timer
                              if (!canResend)
                                Text(
                                  'Resend OTP in ${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13.sp,
                                  ),
                                ),
                              
                              if (canResend)
                                GestureDetector(
                                  onTap: _resendOTP,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              SizedBox(height: 28.h),
                              
                              // Verify Button
                              Container(
                                width: double.infinity,
                                height: 56.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.95),
                                      Colors.white.withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 20.r,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isLoading ? null : _verifyOTP,
                                    borderRadius: BorderRadius.circular(16.r),
                                    splashColor: Colors.black.withOpacity(0.1),
                                    child: Center(
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2027)),
                                            )
                                          : Text(
                                              'VERIFY',
                                              style: TextStyle(
                                                color: Color(0xFF0F2027),
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 45.w,
      height: 55.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? Colors.white
              : Colors.white.withOpacity(0.2),
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            HapticFeedback.selectionClick();
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
