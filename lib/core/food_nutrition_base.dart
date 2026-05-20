class BaseNutrition {
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final bool isHealthy;

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

  const BaseNutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0.0,
    required this.isHealthy,
    this.vitaminA = 0.0,
    this.vitaminC = 0.0,
    this.vitaminB6 = 0.0,
    this.calcium = 0.0,
    this.iron = 0.0,
    this.potassium = 0.0,
    this.magnesium = 0.0,
    this.sodium = 0.0,
    this.zinc = 0.0,
  });
}

const Map<String, BaseNutrition> baseNutritionMap = {

  // ──────────── HEALTHY ────────────

  'boiled_egg': BaseNutrition(
    calories: 78, protein: 6, carbs: 1, fats: 5, fiber: 0.0,
    isHealthy: true,
    vitaminA: 84.0, vitaminC: 0.0, vitaminB6: 0.1,
    calcium: 28.0, iron: 0.9, potassium: 63.0,
    magnesium: 5.0, sodium: 62.0, zinc: 0.5,
  ),

  'omelette': BaseNutrition(
    calories: 120, protein: 8, carbs: 2, fats: 9, fiber: 0.0,
    isHealthy: true,
    vitaminA: 140.0, vitaminC: 0.0, vitaminB6: 0.1,
    calcium: 50.0, iron: 1.2, potassium: 112.0,
    magnesium: 10.0, sodium: 180.0, zinc: 0.9,
  ),

  'idli': BaseNutrition(
    calories: 70, protein: 2, carbs: 14, fats: 1, fiber: 0.5,
    isHealthy: true,
    vitaminA: 0.0, vitaminC: 0.0, vitaminB6: 0.0,
    calcium: 10.0, iron: 0.5, potassium: 60.0,
    magnesium: 10.0, sodium: 200.0, zinc: 0.3,
  ),

  'dosa': BaseNutrition(
    calories: 160, protein: 4, carbs: 30, fats: 3, fiber: 1.0,
    isHealthy: true,
    vitaminA: 0.0, vitaminC: 0.0, vitaminB6: 0.1,
    calcium: 15.0, iron: 1.0, potassium: 80.0,
    magnesium: 18.0, sodium: 350.0, zinc: 0.5,
  ),

  'dal_curry': BaseNutrition(
    calories: 180, protein: 9, carbs: 20, fats: 5, fiber: 4.5,
    isHealthy: true,
    vitaminA: 15.0, vitaminC: 4.0, vitaminB6: 0.2,
    calcium: 35.0, iron: 3.0, potassium: 350.0,
    magnesium: 40.0, sodium: 280.0, zinc: 1.1,
  ),

  'roti': BaseNutrition(
    calories: 110, protein: 3, carbs: 20, fats: 2, fiber: 2.0,
    isHealthy: true,
    vitaminA: 0.0, vitaminC: 0.0, vitaminB6: 0.1,
    calcium: 18.0, iron: 1.5, potassium: 90.0,
    magnesium: 22.0, sodium: 90.0, zinc: 0.6,
  ),

  'rice': BaseNutrition(
    calories: 200, protein: 4, carbs: 45, fats: 1, fiber: 0.6,
    isHealthy: true,
    vitaminA: 0.0, vitaminC: 0.0, vitaminB6: 0.1,
    calcium: 15.0, iron: 1.8, potassium: 55.0,
    magnesium: 20.0, sodium: 5.0, zinc: 0.8,
  ),

  'sambar': BaseNutrition(
    calories: 90, protein: 4, carbs: 12, fats: 2, fiber: 3.0,
    isHealthy: true,
    vitaminA: 60.0, vitaminC: 8.0, vitaminB6: 0.1,
    calcium: 30.0, iron: 1.5, potassium: 220.0,
    magnesium: 25.0, sodium: 400.0, zinc: 0.5,
  ),

  // ──────────── JUNK / HEAVY ────────────

  'chicken_biryani': BaseNutrition(
    calories: 450, protein: 20, carbs: 55, fats: 18, fiber: 2.0,
    isHealthy: false,
    vitaminA: 30.0, vitaminC: 2.0, vitaminB6: 0.4,
    calcium: 45.0, iron: 2.5, potassium: 320.0,
    magnesium: 35.0, sodium: 800.0, zinc: 2.5,
  ),

  'burger': BaseNutrition(
    calories: 300, protein: 12, carbs: 30, fats: 15, fiber: 1.5,
    isHealthy: false,
    vitaminA: 20.0, vitaminC: 2.0, vitaminB6: 0.2,
    calcium: 80.0, iron: 2.0, potassium: 250.0,
    magnesium: 25.0, sodium: 560.0, zinc: 2.0,
  ),

  'pizza': BaseNutrition(
    calories: 350, protein: 14, carbs: 36, fats: 16, fiber: 2.0,
    isHealthy: false,
    vitaminA: 50.0, vitaminC: 3.0, vitaminB6: 0.2,
    calcium: 200.0, iron: 2.2, potassium: 230.0,
    magnesium: 22.0, sodium: 700.0, zinc: 1.8,
  ),

  'noodles': BaseNutrition(
    calories: 280, protein: 7, carbs: 40, fats: 10, fiber: 1.5,
    isHealthy: false,
    vitaminA: 5.0, vitaminC: 1.0, vitaminB6: 0.1,
    calcium: 20.0, iron: 1.5, potassium: 120.0,
    magnesium: 18.0, sodium: 900.0, zinc: 0.8,
  ),

  'puri': BaseNutrition(
    calories: 150, protein: 3, carbs: 20, fats: 7, fiber: 1.0,
    isHealthy: false,
    vitaminA: 0.0, vitaminC: 0.0, vitaminB6: 0.0,
    calcium: 12.0, iron: 1.2, potassium: 60.0,
    magnesium: 12.0, sodium: 150.0, zinc: 0.4,
  ),

  'vada': BaseNutrition(
    calories: 140, protein: 3, carbs: 18, fats: 6, fiber: 1.5,
    isHealthy: false,
    vitaminA: 0.0, vitaminC: 0.0, vitaminB6: 0.1,
    calcium: 14.0, iron: 1.0, potassium: 80.0,
    magnesium: 14.0, sodium: 200.0, zinc: 0.4,
  ),

  'samosa': BaseNutrition(
    calories: 180, protein: 4, carbs: 25, fats: 8, fiber: 2.0,
    isHealthy: false,
    vitaminA: 10.0, vitaminC: 5.0, vitaminB6: 0.1,
    calcium: 15.0, iron: 1.2, potassium: 150.0,
    magnesium: 16.0, sodium: 320.0, zinc: 0.5,
  ),

  'gulab_jamun': BaseNutrition(
    calories: 150, protein: 2, carbs: 30, fats: 5, fiber: 0.2,
    isHealthy: false,
    vitaminA: 15.0, vitaminC: 0.0, vitaminB6: 0.0,
    calcium: 55.0, iron: 0.4, potassium: 80.0,
    magnesium: 8.0, sodium: 90.0, zinc: 0.2,
  ),

  'jalebi': BaseNutrition(
    calories: 170, protein: 2, carbs: 35, fats: 6, fiber: 0.1,
    isHealthy: false,
    vitaminA: 0.0, vitaminC: 0.0, vitaminB6: 0.0,
    calcium: 12.0, iron: 0.5, potassium: 40.0,
    magnesium: 5.0, sodium: 40.0, zinc: 0.1,
  ),

  'soft_drinks': BaseNutrition(
    calories: 140, protein: 0, carbs: 35, fats: 0, fiber: 0.0,
    isHealthy: false,
    vitaminA: 0.0, vitaminC: 0.0, vitaminB6: 0.0,
    calcium: 5.0, iron: 0.1, potassium: 15.0,
    magnesium: 2.0, sodium: 40.0, zinc: 0.0,
  ),

  'mango_pickle': BaseNutrition(
    calories: 90, protein: 1, carbs: 10, fats: 6, fiber: 1.5,
    isHealthy: false,
    vitaminA: 20.0, vitaminC: 2.0, vitaminB6: 0.1,
    calcium: 10.0, iron: 0.8, potassium: 60.0,
    magnesium: 8.0, sodium: 1200.0, zinc: 0.2,
  ),

  'manchurian': BaseNutrition(
    calories: 220, protein: 6, carbs: 28, fats: 9, fiber: 2.0,
    isHealthy: false,
    vitaminA: 25.0, vitaminC: 8.0, vitaminB6: 0.2,
    calcium: 30.0, iron: 1.2, potassium: 180.0,
    magnesium: 20.0, sodium: 750.0, zinc: 0.6,
  ),
};
