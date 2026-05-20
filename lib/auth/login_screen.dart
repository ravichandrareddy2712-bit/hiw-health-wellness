import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_state.dart';
import '../core/nutrition_store.dart';
import '../main.dart';
import '../services/user_api.dart';
import '../widgets/particle_background.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Animation Controllers
  late AnimationController _cardController;
  late AnimationController _fieldController;
  late AnimationController _buttonController;
  late AnimationController _glowController;
  late AnimationController _errorController;
  
  // Animations
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _errorShake;
  
  // State
  bool isLoading = false;
  bool _isObscured = true;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  bool _emailHasFocus = false;
  bool _passHasFocus = false;

  @override
  void initState() {
    super.initState();
    
    // Card entrance animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Staggered fields animation
    _fieldController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Button pulse
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Border glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Error shake
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
      end: const Offset(0.1, 0),
    ).animate(
      CurvedAnimation(parent: _errorController, curve: Curves.elasticIn),
    );
    
    // Start entrance animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _cardController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _fieldController.forward();
      });
    });
    
    // Focus listeners
    _emailFocus.addListener(() {
      setState(() => _emailHasFocus = _emailFocus.hasFocus);
      if (_emailFocus.hasFocus) HapticFeedback.selectionClick();
    });
    _passFocus.addListener(() {
      setState(() => _passHasFocus = _passFocus.hasFocus);
      if (_passFocus.hasFocus) HapticFeedback.selectionClick();
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      _triggerError();
      return;
    }
    
    setState(() => isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final email = _emailCtrl.text.trim().toLowerCase();
      final password = _passCtrl.text.trim();

      final userData = await UserApi.login(email: email, password: password);
      
      final username = userData['username'] ?? 'User';
      final targetCalories = userData['targetCalories'] ?? 2000;

      await AppState.setLoggedIn(true);
      await AppState.setUserInfoDone(true);
      await AppState.setUsername(username);
      await AppState.setEmail(email);
      NutritionStore().setDailyTargetCalories(targetCalories);
      
      // Success haptic
      HapticFeedback.heavyImpact();
      
      if (!mounted) return;
      
      // Success animation before navigation
      await _showSuccessAnimation();
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppGate()),
        (_) => false,
      );

    } catch (e) {
      _triggerError();
      debugPrint("Login fail: $e");
      final errorMsg = e.toString().replaceAll("Exception:", "").trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: Colors.red.withOpacity(0.9),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _triggerError() {
    HapticFeedback.vibrate();
    _errorController.forward(from: 0);
  }

  Future<void> _showSuccessAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(50.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 20.r,
                      spreadRadius: 5.r,
                    ),
                  ],
                ),
                child: Icon(Icons.check, color: Colors.white, size: 50),
              ),
            );
          },
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _fieldController.dispose();
    _buttonController.dispose();
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
      body: Stack(
        children: [
          // Animated Gradient Background
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
          
          // Floating Health Particles
          const ParticleBackground(),
          
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: FadeTransition(
                  opacity: _cardOpacity,
                  child: ScaleTransition(
                    scale: _cardScale,
                    child: SlideTransition(
                      position: _errorShake,
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
                                  // Logo/Icon with pulse
                                  TweenAnimationBuilder(
                                    duration: const Duration(milliseconds: 1200),
                                    tween: Tween<double>(begin: 0, end: 1),
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
                                          child: Icon(
                                            Icons.health_and_safety,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  
                                  SizedBox(height: 24.h),
                                  
                                  Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  
                                  SizedBox(height: 8.h),
                                  
                                  Text(
                                    'Sign in to continue your health journey',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  SizedBox(height: 32.h),
                                  
                                  // Email Field with floating label animation
                                  _buildAnimatedTextField(
                                    controller: _emailCtrl,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    focusNode: _emailFocus,
                                    hasFocus: _emailHasFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Invalid email format';
                                      }
                                      return null;
                                    },
                                    delay: 0,
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Password Field
                                  _buildAnimatedTextField(
                                    controller: _passCtrl,
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    focusNode: _passFocus,
                                    hasFocus: _passHasFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password too short';
                                      }
                                      return null;
                                    },
                                    delay: 0.1,
                                  ),
                                  
                                  SizedBox(height: 12.h),
                                  
                                  // Forgot Password Link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(height: 28.h),
                                  
                                  // Animated Login Button
                                  GestureDetector(
                                    onTapDown: (_) {
                                      _buttonController.stop();
                                      HapticFeedback.lightImpact();
                                    },
                                    onTapUp: (_) => _buttonController.repeat(reverse: true),
                                    onTapCancel: () => _buttonController.repeat(reverse: true),
                                    child: AnimatedBuilder(
                                      animation: _buttonController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: isLoading ? 1.0 : 1.0 + (_buttonController.value * 0.02),
                                          child: Container(
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
                                                  color: Colors.white.withOpacity(0.2 + (_buttonController.value * 0.2)),
                                                  blurRadius: 20.r,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: isLoading ? null : _login,
                                                borderRadius: BorderRadius.circular(16.r),
                                                splashColor: Colors.black.withOpacity(0.1),
                                                child: Center(
                                                  child: AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    switchInCurve: Curves.easeOut,
                                                    switchOutCurve: Curves.easeIn,
                                                    child: isLoading
                                                        ? SizedBox(
                                                            width: 24.w,
                                                            height: 24.h,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2.5,
                                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2027)),
                                                            ),
                                                          )
                                                        : Text(
                                                            'SIGN IN',
                                                            key: ValueKey('text'),
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
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Register Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8.r),
                                            ),
                                            child: Text('Create Account'),
                                          ),
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
        return Transform.translate(
          offset: Offset(0, (1 - fieldProgress) * 20),
          child: Opacity(
            opacity: fieldProgress,
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
          labelStyle: TextStyle(
            color: hasFocus ? Colors.white : Colors.white.withOpacity(0.6),
            fontSize: hasFocus ? 12 : 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              color: hasFocus ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      key: ValueKey<bool>(_isObscured),
                      color: Colors.white70,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _isObscured = !_isObscured);
                    HapticFeedback.selectionClick();
                  },
                )
              : null,
          filled: true,
          fillColor: hasFocus 
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
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: Colors.red.shade300,
              width: 2.w,
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
    );
  }
}
