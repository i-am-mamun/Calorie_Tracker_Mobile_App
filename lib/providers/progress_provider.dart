import 'package:flutter/material.dart';
import '../models/meal.dart';

class ProgressProvider extends ChangeNotifier {
  String selectedPeriod = 'Week'; // Day, Week, Month

  final List<WeeklyData> weeklyData = const [
    WeeklyData(day: 'M', calories: 1820, isOver: false, isFuture: false),
    WeeklyData(day: 'T', calories: 2100, isOver: false, isFuture: false),
    WeeklyData(day: 'W', calories: 2380, isOver: true, isFuture: false),
    WeeklyData(day: 'T', calories: 1650, isOver: false, isFuture: false, isToday: true),
    WeeklyData(day: 'F', calories: 0, isOver: false, isFuture: true),
    WeeklyData(day: 'S', calories: 0, isOver: false, isFuture: true),
    WeeklyData(day: 'S', calories: 0, isOver: false, isFuture: true),
  ];

  final List<WeightData> weightData = [
    WeightData(date: DateTime(2026, 6, 1), weight: 79.5),
    WeightData(date: DateTime(2026, 6, 8), weight: 79.1),
    WeightData(date: DateTime(2026, 6, 15), weight: 78.8),
    WeightData(date: DateTime(2026, 6, 22), weight: 78.4),
    WeightData(date: DateTime(2026, 7, 1), weight: 77.9),
    WeightData(date: DateTime(2026, 7, 8), weight: 77.2),
    WeightData(date: DateTime(2026, 7, 13), weight: 76.2),
  ];

  int get avgKcalPerDay {
    final nonFuture = weeklyData.where((d) => !d.isFuture && d.calories > 0).toList();
    if (nonFuture.isEmpty) return 0;
    return (nonFuture.fold(0, (s, d) => s + d.calories) / nonFuture.length).round();
  }

  double get weightChange => -0.4;
  int get dayStreak => 12;
  double get currentWeight => 76.2;
  double get goalWeight => 72.0;

  void setPeriod(String period) {
    selectedPeriod = period;
    notifyListeners();
  }
}
