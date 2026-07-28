import 'package:flutter/material.dart';
import '../models/food_item.dart';

class MealPlanItem {
  final String mealType; // BREAKFAST, LUNCH, SNACK, DINNER
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final Color color;

  const MealPlanItem({
    required this.mealType,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.color,
  });
}

class PlanProvider extends ChangeNotifier {
  String selectedTab = 'Tomorrow'; // Tomorrow, This week, Recipes
  String selectedDiet = 'Balanced';
  String selectedActivity = 'Active';
  double goalWeight = 78.0;
  double targetWeight = 72.0;
  int dailyBudget = 2000;
  double proteinPct = 0.28;
  double carbsPct = 0.44;
  double fatPct = 0.28;

  final List<String> dietOptions = ['Balanced', 'Keto', 'Vegan', 'Vegetarian', 'Mediterranean', 'Low FODMAP'];
  final List<String> activityOptions = ['Sedentary', 'Active', 'Athlete'];

  final List<MealPlanItem> planItems = const [
    MealPlanItem(mealType: 'BREAKFAST · 420 kcal', name: 'Overnight oats, chia & berries', calories: 420, protein: 24, carbs: 52, fat: 10, color: Color(0xFF4A90D9)),
    MealPlanItem(mealType: 'LUNCH · 510 kcal', name: 'Sesame tofu & broccoli bowl', calories: 510, protein: 32, carbs: 64, fat: 18, color: Color(0xFF50C878)),
    MealPlanItem(mealType: 'SNACK · 180 kcal', name: 'Cottage cheese & peach', calories: 180, protein: 20, carbs: 18, fat: 4, color: Color(0xFFFFB347)),
    MealPlanItem(mealType: 'DINNER · 680 kcal', name: 'Harissa chicken, couscous & greens', calories: 680, protein: 48, carbs: 60, fat: 18, color: Color(0xFFE8735A)),
  ];

  int get totalPlanCalories => planItems.fold(0, (s, i) => s + i.calories);
  double get totalPlanProtein => planItems.fold(0.0, (s, i) => s + i.protein);

  void setTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }

  void setDiet(String diet) {
    selectedDiet = diet;
    notifyListeners();
  }

  void setActivity(String activity) {
    selectedActivity = activity;
    notifyListeners();
  }

  void setGoalWeight(double val) {
    goalWeight = val;
    notifyListeners();
  }
}
