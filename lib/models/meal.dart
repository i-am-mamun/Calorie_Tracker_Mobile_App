import 'food_item.dart';

enum MealType { breakfast, lunch, dinner, snack }

class Meal {
  final MealType type;
  final List<FoodItem> items;

  Meal({required this.type, List<FoodItem>? items}) : items = items ?? [];

  int get totalCalories => items.fold(0, (sum, item) => sum + item.totalCalories);
  double get totalProtein => items.fold(0.0, (sum, item) => sum + item.totalProtein);
  double get totalCarbs => items.fold(0.0, (sum, item) => sum + item.totalCarbs);
  double get totalFat => items.fold(0.0, (sum, item) => sum + item.totalFat);

  String get subtitle {
    if (items.isEmpty) return '';
    return items.map((e) => e.name).join(', ');
  }
}

class WeeklyData {
  final String day; // M, T, W, T, F, S, S
  final int calories;
  final bool isOver;
  final bool isFuture;
  final bool isToday;

  const WeeklyData({
    required this.day,
    required this.calories,
    this.isOver = false,
    this.isFuture = false,
    this.isToday = false,
  });
}

class WeightData {
  final DateTime date;
  final double weight;
  const WeightData({required this.date, required this.weight});
}
