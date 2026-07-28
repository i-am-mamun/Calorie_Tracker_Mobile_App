import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/food_item.dart';

class DiaryProvider extends ChangeNotifier {
  final int calorieGoal = 2000;
  final double proteinGoal = 140;
  final double carbsGoal = 220;
  final double fatGoal = 65;
  int waterCups = 6;
  int waterGoal = 8;

  final List<Meal> meals = [
    Meal(
      type: MealType.breakfast,
      items: [FoodItem(id: '5', name: 'Greek yogurt bowl', calories: 320, protein: 22, carbs: 38, fat: 8, portionLabel: '1 bowl')],
    ),
    Meal(
      type: MealType.lunch,
      items: [FoodItem(id: '4', name: 'Chicken burrito bowl', calories: 640, protein: 35, carbs: 68, fat: 22, portionLabel: '1 bowl', isMyFood: true)],
    ),
    Meal(type: MealType.dinner, items: []),
    Meal(type: MealType.snack, items: []),
  ];

  int get totalCalories => meals.fold(0, (sum, m) => sum + m.totalCalories);
  int get caloriesLeft => calorieGoal - totalCalories;
  int get caloriesBurned => 312;
  double get totalProtein => meals.fold(0.0, (sum, m) => sum + m.totalProtein);
  double get totalCarbs => meals.fold(0.0, (sum, m) => sum + m.totalCarbs);
  double get totalFat => meals.fold(0.0, (sum, m) => sum + m.totalFat);

  double get proteinPercent => (totalProtein / proteinGoal).clamp(0.0, 1.0);
  double get carbsPercent => (totalCarbs / carbsGoal).clamp(0.0, 1.0);
  double get fatPercent => (totalFat / fatGoal).clamp(0.0, 1.0);
  double get caloriePercent => (totalCalories / calorieGoal).clamp(0.0, 1.0);

  void addFoodToMeal(MealType type, FoodItem food) {
    final meal = meals.firstWhere((m) => m.type == type);
    meal.items.add(food.copyWith(servings: food.servings));
    notifyListeners();
  }

  void removeFoodFromMeal(MealType type, String foodId) {
    final meal = meals.firstWhere((m) => m.type == type);
    meal.items.removeWhere((f) => f.id == foodId);
    notifyListeners();
  }

  void incrementWater() {
    if (waterCups < waterGoal) {
      waterCups++;
      notifyListeners();
    }
  }

  void decrementWater() {
    if (waterCups > 0) {
      waterCups--;
      notifyListeners();
    }
  }
}
