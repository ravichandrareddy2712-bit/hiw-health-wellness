import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/particle_background.dart';
import '../utils/calorie_calculator.dart';
import '../core/nutrition_store.dart';
import '../core/app_state.dart';
import '../services/user_api.dart';
import '../main.dart';
import 'login_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const UserInfoScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.username,
  }) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen>
    with TickerProviderStateMixin {
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController heightCtrl = TextEditingController();
  final TextEditingController weightCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _cardController;
  late AnimationController _fieldController;
  late AnimationController _glowController;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<double> _glowAnimation;

  String? gender;
  ActivityLevel? activityLevel;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fieldController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      Future.delayed(const Duration(milliseconds: 200), () {
        _fieldController.forward();
      });
    });
  }

  Future<void> _onFinish() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    if (gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    if (activityLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your activity level')),
      );
      return;
    }
    
    try {
      setState(() => isLoading = true);
      HapticFeedback.mediumImpact();

      final age = int.parse(ageCtrl.text);
      final height = double.parse(heightCtrl.text);
      final weight = double.parse(weightCtrl.text);

      final calories = CalorieCalculator.calculateDailyCalories(
        age: age,
        gender: gender!,
        heightCm: height,
        weightKg: weight,
        activityLevel: activityLevel!,
      ).round();

      await UserApi.registerUser(
        email: widget.email,
        password: widget.password,
        username: widget.username,
        age: age,
        gender: gender!,
        height: height,
        weight: weight,
        activityLevel: activityLevel!.name,
        targetCalories: calories,
      );

      HapticFeedback.heavyImpact();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );

    } catch (e) {
      setState(() => isLoading = false);
      HapticFeedback.vibrate();

      debugPrint("Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(child: Text("Registration Failed: ${e.toString()}")),
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
  }

  @override
  void dispose() {
    _cardController.dispose();
    _fieldController.dispose();
    _glowController.dispose();
    ageCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
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
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
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
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                Text(
                                  'Your Details',
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                
                                SizedBox(height: 8.h),
                                
                                Text(
                                  'Help us personalize your experience',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                SizedBox(height: 32.h),
                                
                                _buildAnimatedField(
                                  controller: ageCtrl,
                                  label: 'Age',
                                  icon: Icons.cake_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Age required';
                                    final age = int.tryParse(value);
                                    if (age == null || age < 10 || age > 120) return 'Invalid age';
                                    return null;
                                  },
                                  delay: 0,
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                _buildAnimatedField(
                                  controller: heightCtrl,
                                  label: 'Height (cm)',
                                  icon: Icons.height,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Height required';
                                    final height = double.tryParse(value);
                                    if (height == null || height < 50 || height > 300) return 'Invalid height';
                                    return null;
                                  },
                                  delay: 0.1,
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                _buildAnimatedField(
                                  controller: weightCtrl,
                                  label: 'Weight (kg)',
                                  icon: Icons.monitor_weight_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Weight required';
                                    final weight = double.tryParse(value);
                                    if (weight == null || weight < 20 || weight > 500) return 'Invalid weight';
                                    return null;
                                  },
                                  delay: 0.2,
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                _buildAnimatedDropdown(
                                  label: 'Gender',
                                  value: gender,
                                  hint: 'Select Gender',
                                  items: const ['male', 'female'],
                                  onChanged: (v) {
                                    setState(() => gender = v);
                                    HapticFeedback.selectionClick();
                                  },
                                  delay: 0.3,
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                _buildAnimatedDropdown(
                                  label: 'Activity Level',
                                  value: activityLevel?.name,
                                  hint: 'Select Activity',
                                  items: const [
                                    'sedentary',
                                    'lightlyActive',
                                    'moderatelyActive',
                                    'veryActive',
                                  ],
                                  onChanged: (v) {
                                    setState(() {
                                      activityLevel = ActivityLevel.values.firstWhere((e) => e.name == v);
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                  delay: 0.4,
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
                                      onTap: isLoading ? null : _onFinish,
                                      borderRadius: BorderRadius.circular(16.r),
                                      splashColor: Colors.black.withOpacity(0.1),
                                      child: Center(
                                        child: isLoading
                                            ? const CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2027)),
                                              )
                                            : Text(
                                                'FINISH',
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
    );
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _fieldController,
      builder: (context, child) {
        final double fieldProgress = (_fieldController.value - delay).clamp(0.0, 0.15) / 0.15;
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
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.6),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
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
    );
  }

  Widget _buildAnimatedDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _fieldController,
      builder: (context, child) {
        final double fieldProgress = (_fieldController.value - delay).clamp(0.0, 0.15) / 0.15;
        return Transform.translate(
          offset: Offset(0, (1 - fieldProgress) * 20),
          child: Opacity(
            opacity: fieldProgress,
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12.sp,
              ),
            ),
            DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16.sp),
              ),
              isExpanded: true,
              dropdownColor: const Color(0xFF203A43),
              underline: SizedBox(),
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e[0].toUpperCase() + e.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
