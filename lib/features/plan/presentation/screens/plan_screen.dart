import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calorie_tracker/core/theme/app_colors.dart';
import 'package:calorie_tracker/core/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers/plan_provider.dart';
import 'package:calorie_tracker/providers/locale_provider.dart';
import 'package:calorie_tracker/providers/theme_provider.dart';
import 'package:calorie_tracker/shared/widgets/app_widgets.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final s = AppLocalizations.of(locale);
    final plan = context.watch<PlanProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context, s, plan, isDark),
                  const SizedBox(height: 16),
                  Text(s.builtForPlan, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  _buildTabBar(context, s, plan, isDark),
                  const SizedBox(height: 20),
                  ...plan.planItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMealCard(context, item, isDark),
                  )),
                  const SizedBox(height: 16),
                  _buildDayTotal(context, s, plan, isDark),
                  const SizedBox(height: 32),
                  _buildYourPlanSection(context, s, plan, isDark),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings s, PlanProvider plan, bool isDark) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Text(s.plan, style: Theme.of(context).textTheme.headlineLarge),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, size: 16, color: Colors.black),
                const SizedBox(width: 6),
                Text(s.regenerate.replaceAll('+ ', ''), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, AppStrings s, PlanProvider plan, bool isDark) {
    final tabs = [s.tomorrow, s.thisWeekPlan, s.recipes];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tabs.map((tab) {
        final sel = plan.selectedTab == tab ||
            (tab == s.tomorrow && plan.selectedTab == 'Tomorrow') ||
            (tab == s.thisWeekPlan && plan.selectedTab == 'This week') ||
            (tab == s.recipes && plan.selectedTab == 'Recipes');
        return GestureDetector(
            onTap: () => context.read<PlanProvider>().setTab(tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(tab, style: TextStyle(
                color: sel ? Colors.black : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              )),
            ),
          );
      }).toList(),
    );
  }

  Widget _buildMealCard(BuildContext context, MealPlanItem item, bool isDark) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // Color stripe image block
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.3),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            ),
            child: Icon(Icons.restaurant, color: item.color, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.mealType, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 2),
                  const SizedBox(height: 4),
                  Text('P ${item.protein.round()}g · C ${item.carbs.round()}g · F ${item.fat.round()}g',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTotal(BuildContext context, AppStrings s, PlanProvider plan, bool isDark) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(s.dayTotal, style: Theme.of(context).textTheme.titleMedium),
        Text('${plan.totalPlanCalories} ${s.kcal} · P ${plan.totalPlanProtein.round()}g',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
      ],
    );
  }

  Widget _buildYourPlanSection(BuildContext context, AppStrings s, PlanProvider plan, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(Icons.arrow_back_ios, size: 18, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(child: Center(child: Text(s.yourPlan, style: Theme.of(context).textTheme.titleLarge))),
            ],
          ),
          const SizedBox(height: 24),
          // Goal weight slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.goalWeight, style: Theme.of(context).textTheme.titleMedium),
              Text('-0.5 kg / week', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: plan.goalWeight,
              min: 60,
              max: 100,
              onChanged: (val) => context.read<PlanProvider>().setGoalWeight(val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${plan.goalWeight.round()}', style: Theme.of(context).textTheme.bodyMedium),
              Text('${plan.targetWeight.round()}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          Text('Now ${plan.goalWeight.toStringAsFixed(1)} kg · ${s.projectedArrival} Oct 4',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          // Daily budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.dailyBudget, style: Theme.of(context).textTheme.titleMedium),
              Text('${plan.dailyBudget} ${s.kcal}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Flexible(flex: (plan.proteinPct * 100).round(), child: Container(color: const Color(0xFF6B8CFF))),
                  Flexible(flex: (plan.carbsPct * 100).round(), child: Container(color: AppColors.primary)),
                  Flexible(flex: (plan.fatPct * 100).round(), child: Container(color: AppColors.orange)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _macroLegend(context, 'Protein ${(plan.proteinPct * 100).round()}% · ${(plan.dailyBudget * plan.proteinPct / 4).round()}g', const Color(0xFF6B8CFF)),
              _macroLegend(context, 'Carbs ${(plan.carbsPct * 100).round()}% · ${(plan.dailyBudget * plan.carbsPct / 4).round()}g', AppColors.primary),
              _macroLegend(context, 'Fat ${(plan.fatPct * 100).round()}% · ${(plan.dailyBudget * plan.fatPct / 9).round()}g', AppColors.orange),
            ],
          ),
          const SizedBox(height: 24),
          // Diet preference
          Text(s.dietPreference, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [s.balanced, s.keto, s.vegan, s.vegetarian, s.mediterranean, s.lowFodmap].map((diet) {
              final sel = plan.selectedDiet == diet;
              return GestureDetector(
                onTap: () => context.read<PlanProvider>().setDiet(diet),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: sel ? null : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Text(diet, style: TextStyle(
                    color: sel ? Colors.black : (isDark ? Colors.white : Colors.black),
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Activity level
          Text(s.activityLevel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [s.sedentary, s.active, s.athlete].map((act) {
                final sel = plan.selectedActivity == act;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.read<PlanProvider>().setActivity(act),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? (isDark ? AppColors.darkCard : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: sel ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)] : null,
                      ),
                      child: Center(
                        child: Text(act, style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13,
                        )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: s.savePlan, onTap: () {}),
        ],
      ),
    );
  }

  Widget _macroLegend(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
