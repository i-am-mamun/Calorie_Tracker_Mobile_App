class FoodItem {
  final String id;
  final String name;
  final String? brand;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? portionLabel;
  final bool isVerified;
  final bool isMyFood;
  double servings;

  FoodItem({
    required this.id,
    required this.name,
    this.brand,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.portionLabel,
    this.isVerified = false,
    this.isMyFood = false,
    this.servings = 1.0,
  });

  int get totalCalories => (calories * servings).round();
  double get totalProtein => protein * servings;
  double get totalCarbs => carbs * servings;
  double get totalFat => fat * servings;

  FoodItem copyWith({double? servings}) {
    return FoodItem(
      id: id,
      name: name,
      brand: brand,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      portionLabel: portionLabel,
      isVerified: isVerified,
      isMyFood: isMyFood,
      servings: servings ?? this.servings,
    );
  }
}

// Sample food database
class FoodDatabase {
  static final List<FoodItem> items = [
    FoodItem(id: '1', name: 'Chicken breast, grilled', calories: 165, protein: 31, carbs: 0, fat: 3.6, portionLabel: '100 g', isVerified: true),
    FoodItem(id: '2', name: 'Chicken breast, roasted, skinless', calories: 157, protein: 30, carbs: 0, fat: 4, portionLabel: '100 g', isVerified: true),
    FoodItem(id: '3', name: 'Chicken breast tenders, breaded', calories: 252, protein: 16, carbs: 15, fat: 13, portionLabel: '100 g'),
    FoodItem(id: '4', name: 'Chicken burrito bowl', calories: 640, protein: 35, carbs: 68, fat: 22, portionLabel: '1 bowl', isMyFood: true),
    FoodItem(id: '5', name: 'Greek yogurt bowl', calories: 320, protein: 22, carbs: 38, fat: 8, portionLabel: '1 bowl'),
    FoodItem(id: '6', name: 'Spaghetti, marinara', calories: 320, protein: 11, carbs: 58, fat: 6, portionLabel: '1.5 cups'),
    FoodItem(id: '7', name: 'Beef meatballs', calories: 240, protein: 18, carbs: 8, fat: 16, portionLabel: '3 meatballs'),
    FoodItem(id: '8', name: 'Parmesan, grated', calories: 25, protein: 2, carbs: 0, fat: 2, portionLabel: '1 tbsp'),
    FoodItem(id: '9', name: "Lay's Classic Potato Chips", calories: 90, protein: 1, carbs: 10, fat: 6, portionLabel: '170 g container', brand: 'FreshMart'),
    FoodItem(id: '10', name: 'Overnight oats, chia & berries', calories: 420, protein: 24, carbs: 52, fat: 10, portionLabel: '1 bowl'),
    FoodItem(id: '11', name: 'Sesame tofu & broccoli bowl', calories: 510, protein: 32, carbs: 64, fat: 18, portionLabel: '1 bowl'),
    FoodItem(id: '12', name: 'Cottage cheese & peach', calories: 180, protein: 20, carbs: 18, fat: 4, portionLabel: '1 cup'),
    FoodItem(id: '13', name: 'Harissa chicken, couscous & greens', calories: 680, protein: 48, carbs: 60, fat: 18, portionLabel: '1 bowl'),
    FoodItem(id: '14', name: 'Banana', calories: 89, protein: 1, carbs: 23, fat: 0, portionLabel: '1 medium'),
    FoodItem(id: '15', name: 'Oatmeal', calories: 150, protein: 5, carbs: 27, fat: 2, portionLabel: '1 cup cooked'),
    FoodItem(id: '16', name: 'Egg, scrambled', calories: 148, protein: 10, carbs: 2, fat: 11, portionLabel: '2 large eggs'),
    FoodItem(id: '17', name: 'Whole milk', calories: 149, protein: 8, carbs: 12, fat: 8, portionLabel: '1 cup'),
    FoodItem(id: '18', name: 'Brown rice', calories: 215, protein: 5, carbs: 45, fat: 2, portionLabel: '1 cup cooked'),
  ];

  static List<FoodItem> search(String query) {
    if (query.isEmpty) return items.take(6).toList();
    final q = query.toLowerCase();
    return items.where((f) => f.name.toLowerCase().contains(q) || (f.brand?.toLowerCase().contains(q) ?? false)).toList();
  }
}
