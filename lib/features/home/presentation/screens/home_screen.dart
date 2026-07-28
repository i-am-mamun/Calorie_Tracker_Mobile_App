import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:calorie_tracker/core/theme/app_colors.dart';
import 'package:calorie_tracker/core/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers/diary_provider.dart';
import 'package:calorie_tracker/providers/locale_provider.dart';
import 'package:calorie_tracker/providers/theme_provider.dart';
import 'package:calorie_tracker/models/meal.dart';
import 'package:calorie_tracker/shared/widgets/app_widgets.dart';
import 'package:calorie_tracker/features/log_food/presentation/screens/log_food_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting(AppStrings s) {
    final h = DateTime.now().hour;
    if (h < 12) return s.goodMorning;
    if (h < 17) return s.goodAfternoon;
    return s.goodEvening;
  }

  String _dateStr() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final s = AppLocalizations.of(locale);
    final diary = context.watch<DiaryProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context, s, isDark),
                  const SizedBox(height: 28),
                  _buildCalorieRing(context, s, diary, isDark),
                  const SizedBox(height: 20),
                  _buildMacroRow(context, s, diary, isDark),
                  const SizedBox(height: 16),
                  InsightCard(text: s.insightTip),
                  const SizedBox(height: 24),
                  _buildMealSection(context, s, diary, MealType.breakfast, isDark),
                  const SizedBox(height: 12),
                  _buildMealSection(context, s, diary, MealType.lunch, isDark),
                  const SizedBox(height: 12),
                  _buildMealSection(context, s, diary, MealType.dinner, isDark),
                  const SizedBox(height: 20),
                  _buildWaterTracker(context, s, diary, isDark),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings s, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_dateStr(), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('${_greeting(s)}, Nasim', style: Theme.of(context).textTheme.headlineLarge),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary,
          child: Text('N', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildCalorieRing(BuildContext context, AppStrings s, DiaryProvider diary, bool isDark) {
    final pct = (diary.totalCalories / diary.calorieGoal).clamp(0.0, 1.0);
    return Center(
      child: CircularPercentIndicator(
        radius: 110,
        lineWidth: 12,
        percent: pct,
        backgroundColor: isDark ? AppColors.ringTrack : AppColors.ringTrackLight,
        progressColor: AppColors.primary,
        circularStrokeCap: CircularStrokeCap.round,
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${diary.caloriesLeft}',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(s.kcalLeft, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_drop_up, color: AppColors.primary, size: 18),
                Text(
                  '${diary.caloriesBurned} ${s.kcalBurned}',
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(BuildContext context, AppStrings s, DiaryProvider diary, bool isDark) {
    return Row(
      children: [
        Expanded(child: _macroCard(context, s.protein, diary.totalProtein, diary.proteinGoal, diary.proteinPercent, const Color(0xFF6B8CFF), isDark)),
        const SizedBox(width: 10),
        Expanded(child: _macroCard(context, s.carbs, diary.totalCarbs, diary.carbsGoal, diary.carbsPercent, AppColors.primary, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _macroCard(context, s.fat, diary.totalFat, diary.fatGoal, diary.fatPercent, const Color(0xFFFF8C42), isDark)),
      ],
    );
  }

  Widget _macroCard(BuildContext context, String label, double current, double goal, double pct, Color color, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(current.round().toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
              Text('g', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          MacroFillBar(value: pct, color: color, height: 4),
        ],
      ),
    );
  }

  Widget _buildMealSection(BuildContext context, AppStrings s, DiaryProvider diary, MealType type, bool isDark) {
    final meal = diary.meals.firstWhere((m) => m.type == type);
    final mealName = type == MealType.breakfast ? s.breakfast : type == MealType.lunch ? s.lunch : s.dinner;
    final addLabel = type == MealType.breakfast ? s.addBreakfast : type == MealType.lunch ? s.addLunch : s.addDinner;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          if (meal.items.isEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mealName, style: Theme.of(context).textTheme.titleMedium),
                ]),
                GestureDetector(
                  onTap: () => _openLogFood(context, type),
                  child: Text(addLabel, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mealName, style: Theme.of(context).textTheme.titleMedium),
                Text('${meal.totalCalories}', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 6),
            ...meal.items.map((item) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.name, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                  Text('${item.totalCalories}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openLogFood(context, type),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(addLabel, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openLogFood(BuildContext context, MealType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogFoodScreen(mealType: type),
    );
  }

  Widget _buildWaterTracker(BuildContext context, AppStrings s, DiaryProvider diary, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.water_drop_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text('${s.water} · ${diary.waterCups} ${s.of} ${diary.waterGoal}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis),
          ),
          ...List.generate(diary.waterGoal, (i) => Padding(
            padding: const EdgeInsets.only(left: 4),
            child: GestureDetector(
              onTap: () {
                if (i < diary.waterCups) {
                  context.read<DiaryProvider>().decrementWater();
                } else {
                  context.read<DiaryProvider>().incrementWater();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < diary.waterCups
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
