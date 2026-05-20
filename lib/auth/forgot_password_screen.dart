import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/particle_background.dart';
import '../services/otp_service.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _cardController;
  late AnimationController _glowController;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<double> _glowAnimation;
  
  bool isLoading = false;
  final FocusNode _emailFocus = FocusNode();
  bool _emailHasFocus = false;

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
    
    _emailFocus.addListener(() {
      setState(() => _emailHasFocus = _emailFocus.hasFocus);
      if (_emailFocus.hasFocus) HapticFeedback.selectionClick();
    });
  }

  Future<void> _sendResetOTP() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }
    
    setState(() => isLoading = true);
    HapticFeedback.mediumImpact();
    
    final email = _emailCtrl.text.trim().toLowerCase();
    
    // 💡 Logic Fix: We no longer send OTP here because OtpScreen
    // sends it automatically in its initState. This prevents double emails.
    await Future.delayed(const Duration(milliseconds: 500)); // Smooth transition
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: email,
            password: '', // Not needed for forgot password
            isForgotPassword: true,
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => isLoading = false);
      });
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    _glowController.dispose();
    _emailCtrl.dispose();
    _emailFocus.dispose();
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
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                
                Expanded(
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
                                child: Form(
                                  key: _formKey,
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
                                          Icons.lock_reset,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                      
                                      SizedBox(height: 24.h),
                                      
                                      Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      
                                      SizedBox(height: 8.h),
                                      
                                      Text(
                                        'Enter your email to receive a reset code',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      
                                      SizedBox(height: 32.h),
                                      
                                      TextFormField(
                                        controller: _emailCtrl,
                                        focusNode: _emailFocus,
                                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter email';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Invalid email format';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: TextStyle(
                                            color: _emailHasFocus ? Colors.white : Colors.white.withOpacity(0.6),
                                          ),
                                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            color: _emailHasFocus ? Colors.white : Colors.white.withOpacity(0.6),
                                          ),
                                          filled: true,
                                          fillColor: _emailHasFocus 
                                              ? Colors.white.withOpacity(0.2) 
                                              : Colors.white.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14.r),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14.r),
                                            borderSide: BorderSide(
                                              color: Colors.white.withOpacity(0.1),
                                              width: 1.w,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14.r),
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                              width: 2.w,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14.r),
                                            borderSide: BorderSide(
                                              color: Colors.red.shade300,
                                              width: 1.w,
                                            ),
                                          ),
                                          errorStyle: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12.sp,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 18,
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(height: 28.h),
                                      
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
                                            onTap: isLoading ? null : _sendResetOTP,
                                            borderRadius: BorderRadius.circular(16.r),
                                            splashColor: Colors.black.withOpacity(0.1),
                                            child: Center(
                                              child: isLoading
                                                  ? const CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2027)),
                                                    )
                                                  : Text(
                                                      'SEND CODE',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
