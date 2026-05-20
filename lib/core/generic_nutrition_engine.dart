//lib/core/generic_nutrition_engine.dart
import 'food_nutrition_base.dart';
import 'addon_nutrition_rules.dart';
import 'food_item.dart';

FoodItem calculateFoodFromAddons({
  required String foodLabel,
  required Map<String, dynamic> addons,
  required MealType mealType,
}) {
  final base = baseNutritionMap[foodLabel];

  if (base == null) {
    // fallback safety
    return FoodItem(
      name: foodLabel,
      mealType: mealType,
      calories: 0,
      protein: 0,
      carbs: 0,
      fats: 0,
      fiber: 0,
    );
  }

  int calories    = base.calories;
  double protein  = base.protein;
  double carbs    = base.carbs;
  double fats     = base.fats;
  double fiber    = base.fiber;

  addons.forEach((key, value) {
    if (value is int) {
      // counter (e.g., number of dosa)
      calories *= value;
      protein  *= value;
      carbs    *= value;
      fats     *= value;
      fiber    *= value;
    } else if (value is String) {
      // single choice
      final rule = addonNutritionRules[value];
      if (rule != null) {
        calories += rule.calories;
        protein  += rule.protein;
        carbs    += rule.carbs;
        fats     += rule.fats;
        fiber    += rule.fiber;
      }
    } else if (value is Set<String>) {
      // multi choice
      for (final v in value) {
        final rule = addonNutritionRules[v];
        if (rule != null) {
          calories += rule.calories;
          protein  += rule.protein;
          carbs    += rule.carbs;
          fats     += rule.fats;
          fiber    += rule.fiber;
        }
      }
    }
  });

  return FoodItem(
    name: foodLabel,
    mealType: mealType,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fats: fats,
    fiber: fiber,
    // 🆕 Micronutrients come from base (not scaled by addons for simplicity)
    vitaminA:   base.vitaminA,
    vitaminC:   base.vitaminC,
    vitaminB6:  base.vitaminB6,
    calcium:    base.calcium,
    iron:       base.iron,
    potassium:  base.potassium,
    magnesium:  base.magnesium,
    sodium:     base.sodium,
    zinc:       base.zinc,
  );
}
