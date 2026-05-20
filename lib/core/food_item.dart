enum MealType { breakfast, lunch, snack, dinner, lateNight }

class FoodItem {
  final String name;
  final MealType mealType;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final DateTime time;

  // Micronutrients
  final double vitaminA;   // µg
  final double vitaminC;   // mg
  final double vitaminB6;  // mg
  final double calcium;    // mg
  final double iron;       // mg
  final double potassium;  // mg
  final double magnesium;  // mg
  final double sodium;     // mg
  final double zinc;       // mg

  FoodItem({
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0.0,
    DateTime? time,
    this.vitaminA = 0.0,
    this.vitaminC = 0.0,
    this.vitaminB6 = 0.0,
    this.calcium = 0.0,
    this.iron = 0.0,
    this.potassium = 0.0,
    this.magnesium = 0.0,
    this.sodium = 0.0,
    this.zinc = 0.0,
  }) : time = time ?? DateTime.now();
}
