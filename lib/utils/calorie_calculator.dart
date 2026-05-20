enum ActivityLevel {
  sedentary,        // no workout
  lightlyActive,    // 1–3 days/week
  moderatelyActive, // 3–5 days/week
  veryActive,       // 6–7 days/week
}

class CalorieCalculator {
  static double calculateDailyCalories({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required ActivityLevel activityLevel,
  }) {
    // ----------------------------
    // BMR (Mifflin–St Jeor)
    // ----------------------------
    double bmr;

    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weightKg) +
          (6.25 * heightCm) -
          (5 * age) +
          5;
    } else {
      bmr = (10 * weightKg) +
          (6.25 * heightCm) -
          (5 * age) -
          161;
    }

    // ----------------------------
    // Activity Multiplier
    // ----------------------------
    final multiplier = _activityMultiplier(activityLevel);

    return bmr * multiplier;
  }

  static double _activityMultiplier(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
    }
  }
}
