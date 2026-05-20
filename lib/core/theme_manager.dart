import 'dart:async';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../core/app_state.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  
  ThemeManager._internal() {
    _loadTheme();
    _startTicker();
  }

  // 1. EVENT THEME STATE (was ThemeNotifier)
  String _currentThemeName = 'default';
  String get currentThemeName => _currentThemeName;
  Timer? _ticker;

  // 2. DEV OVERRIDES STATE
  Color? _backgroundColorOverride;
  Color? _cardColorOverride; 
  Color? _primaryColorOverride;
  double _opacityOverride = 0.2; 

  // Getters
  Color? get backgroundColorOverride => _backgroundColorOverride;
  Color? get cardColorOverride => _cardColorOverride;
  Color? get primaryColorOverride => _primaryColorOverride;
  double get opacityOverride => _opacityOverride;

  // -------------------------
  // THEME DATA GENERATION
  // -------------------------
  ThemeData get currentThemeData {
    // Start with the base time-based theme
    ThemeData base = AppTheme.getTheme(_currentThemeName);

    // Apply overrides
    return base.copyWith(
      scaffoldBackgroundColor: _backgroundColorOverride ?? base.scaffoldBackgroundColor,
      primaryColor: _primaryColorOverride ?? base.primaryColor,
      // Note: cardColor in ThemeData isn't always used by custom widgets, but we set it for consistency
      cardColor: _cardColorOverride ?? base.cardColor,
    );
  }

  // -------------------------
  // EVENT THEME LOGIC
  // -------------------------
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_currentThemeName == 'default') {
        notifyListeners(); // Trigger rebuild for time-based changes
      }
    });
  }

  Future<void> _loadTheme() async {
    _currentThemeName = await AppState.getTheme();
    notifyListeners();
  }

  Future<void> setThemeName(String theme) async {
    _currentThemeName = theme;
    await AppState.setTheme(theme);
    notifyListeners();
  }

  // -------------------------
  // DEV TOOLS OVERRIDES
  // -------------------------
  void setBackgroundColor(Color color) {
    _backgroundColorOverride = color;
    notifyListeners();
  }

  void setCardColor(Color color) {
    _cardColorOverride = color;
    notifyListeners();
  }
  
  void setPrimaryColor(Color color) {
    _primaryColorOverride = color;
    notifyListeners();
  }

  void setOpacity(double value) {
    _opacityOverride = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void reset() {
    _backgroundColorOverride = null;
    _cardColorOverride = null;
    _primaryColorOverride = null;
    _opacityOverride = 0.2;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
