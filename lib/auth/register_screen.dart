import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/particle_background.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _cardController;
  late AnimationController _fieldController;
  late AnimationController _glowController;
  late AnimationController _errorController;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _errorShake;
  
  bool isLoading = false;
  bool _isObscured = true;
  double _passwordStrength = 0;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  bool _emailHasFocus = false;
  bool _passHasFocus = false;

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fieldController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    
    _errorShake = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.01, 0),
    ).animate(_errorController);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _cardController.forward();
      Future.delayed(const Duration(milliseconds: 250), () {
        _fieldController.forward();
      });
    });
    
    _passCtrl.addListener(_checkPasswordStrength);
    
    _emailFocus.addListener(() {
      setState(() => _emailHasFocus = _emailFocus.hasFocus);
      if (_emailFocus.hasFocus) HapticFeedback.selectionClick();
    });
    _passFocus.addListener(() {
      setState(() => _passHasFocus = _passFocus.hasFocus);
      if (_passFocus.hasFocus) HapticFeedback.selectionClick();
    });
  }

  void _checkPasswordStrength() {
    String password = _passCtrl.text;
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]')) && password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    
    setState(() => _passwordStrength = strength);
  }

  void _sendOTP() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      _errorController.forward(from: 0);
      return;
    }
    
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          email: _emailCtrl.text.trim().toLowerCase(),
          password: _passCtrl.text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _fieldController.dispose();
    _glowController.dispose();
    _errorController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Dynamic Gradient Background
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
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _cardOpacity,
                      child: ScaleTransition(
                        scale: _cardScale,
                        child: SlideTransition(
                          position: _errorShake,
                        child: Material(
                          type: MaterialType.transparency,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5.w,
                                  ),
                                ),
                                child: AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      padding: EdgeInsets.all(28.r),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(_glowAnimation.value * 0.2),
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
                                        // Icon
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 1200),
                                          tween: Tween(begin: 0, end: 1),
                                          curve: Curves.elasticOut,
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: value,
                                              child: Container(
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
                                                child: Icon(Icons.person_add, color: Colors.white, size: 35),
                                              ),
                                            );
                                          },
                                        ),
                                        
                                        SizedBox(height: 24.h),
                                        
                                        Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        
                                        SizedBox(height: 8.h),
                                        
                                        Text(
                                          'Start your health journey today',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        
                                        SizedBox(height: 32.h),
                                        
                                        _buildAnimatedTextField(
                                          controller: _emailCtrl,
                                          label: 'Email',
                                          icon: Icons.email_outlined,
                                          focusNode: _emailFocus,
                                          hasFocus: _emailHasFocus,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) return 'Email required';
                                            if (!value.contains('@')) return 'Invalid email';
                                            return null;
                                          },
                                          delay: 0,
                                        ),
                                        
                                        SizedBox(height: 20.h),
                                        
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildAnimatedTextField(
                                              controller: _passCtrl,
                                              label: 'Password',
                                              icon: Icons.lock_outline,
                                              isPassword: true,
                                              focusNode: _passFocus,
                                              hasFocus: _passHasFocus,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) return 'Password required';
                                                if (value.length < 6) return 'Min 6 characters';
                                                return null;
                                              },
                                              delay: 0.1,
                                            ),
                                            SizedBox(height: 8.h),
                                            
                                            // Password strength bar
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4.r),
                                              child: Container(
                                                height: 4.h,
                                                width: double.infinity,
                                                color: Colors.white.withOpacity(0.1),
                                                child: FractionallySizedBox(
                                                  alignment: Alignment.centerLeft,
                                                  widthFactor: _passwordStrength,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: _passwordStrength < 0.5
                                                            ? [Colors.red.shade400, Colors.red.shade300]
                                                            : _passwordStrength < 0.8
                                                                ? [Colors.orange.shade400, Colors.orange.shade300]
                                                                : [Colors.green.shade400, Colors.green.shade300],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              _passwordStrength < 0.5 ? 'Weak' : _passwordStrength < 0.8 ? 'Medium' : 'Strong',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: _passwordStrength < 0.5 ? Colors.red.shade300 : _passwordStrength < 0.8 ? Colors.orange.shade300 : Colors.green.shade300,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        SizedBox(height: 28.h),
                                        
                                        // Submit Button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 56.h,
                                          child: ElevatedButton(
                                            onPressed: isLoading ? null : _sendOTP,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFF0F2027),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                              elevation: 4,
                                            ),
                                            child: isLoading
                                                ? const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFF0F2027)))
                                                : Text('SEND OTP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                          ),
                                        ),
                                        
                                        SizedBox(height: 20.h),
                                        
                                        // Sign In Link
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          children: [
                                            Text(
                                              "Already have an account? ",
                                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Sign In',
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required FocusNode focusNode,
    required bool hasFocus,
    String? Function(String?)? validator,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _fieldController,
      builder: (context, child) {
        final double fieldProgress = (_fieldController.value - delay).clamp(0.0, 0.2) / 0.2;
        return Opacity(
          opacity: fieldProgress,
          child: Transform.translate(
            offset: Offset(0, (1 - fieldProgress) * 20),
            child: child,
          ),
        );
      },
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && _isObscured,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: hasFocus ? Colors.white : Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: hasFocus ? Colors.white : Colors.white.withOpacity(0.6)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(hasFocus ? 0.2 : 0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18.h),
        ),
      ),
    );
  }
}
