import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:calorie_tracker/core/theme/app_colors.dart';
import 'package:calorie_tracker/core/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers/progress_provider.dart';
import 'package:calorie_tracker/providers/locale_provider.dart';
import 'package:calorie_tracker/providers/theme_provider.dart';
import 'package:calorie_tracker/shared/widgets/app_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final s = AppLocalizations.of(locale);
    final prog = context.watch<ProgressProvider>();
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
                  _buildHeader(context, s, prog, isDark),
                  const SizedBox(height: 20),
                  _buildStatCards(context, s, prog, isDark),
                  const SizedBox(height: 24),
                  _buildCaloriesChart(context, s, prog, isDark),
                  const SizedBox(height: 24),
                  _buildWeightChart(context, s, prog, isDark),
                  const SizedBox(height: 20),
                  InsightCard(text: 'This portion covers your remaining protein gap for today.'),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings s, ProgressProvider prog, bool isDark) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Text(s.progress, style: Theme.of(context).textTheme.headlineLarge),
        SegmentedControl(
          options: [s.day, s.week, s.month],
          selected: prog.selectedPeriod == 'Day' ? s.day : prog.selectedPeriod == 'Month' ? s.month : s.week,
          onChanged: (val) {
            String period = 'Week';
            if (val == s.day) period = 'Day';
            if (val == s.month) period = 'Month';
            context.read<ProgressProvider>().setPeriod(period);
          },
        ),
      ],
    );
  }

  Widget _buildStatCards(BuildContext context, AppStrings s, ProgressProvider prog, bool isDark) {
    return Row(
      children: [
        Expanded(child: _statCard(context, '${prog.avgKcalPerDay}', s.avgKcalPerDay, null, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _statCard(context, '${prog.weightChange} kg', s.thisWeek, null, isDark, valueColor: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: _statCard(context, '${prog.dayStreak}', s.dayStreak, '🔥', isDark)),
      ],
    );
  }

  Widget _statCard(BuildContext context, String value, String label, String? emoji, bool isDark, {Color? valueColor}) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
              if (emoji != null) Text(emoji, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildCaloriesChart(BuildContext context, AppStrings s, ProgressProvider prog, bool isDark) {
    final goal = 2000.0;
    final maxY = 2600.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.caloriesVsGoal, style: Theme.of(context).textTheme.titleMedium),
              Text('${s.goal} 2,000', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (val.toInt() >= 0 && val.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[val.toInt()],
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1000,
                      reservedSize: 36,
                      getTitlesWidget: (val, meta) => Text(
                        val == 0 ? '0' : '${(val / 1000).round()}k',
                        style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: prog.weeklyData.asMap().entries.map((entry) {
                  final i = entry.key;
                  final data = entry.value;
                  Color barColor;
                  if (data.isFuture) {
                    barColor = isDark ? AppColors.dimBar : AppColors.dimBarLight;
                  } else if (data.isOver) {
                    barColor = AppColors.red;
                  } else {
                    barColor = AppColors.primary;
                  }

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data.isFuture ? goal * 0.08 : data.calories.toDouble(),
                        color: barColor,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: !data.isFuture,
                          toY: maxY,
                          color: isDark ? AppColors.dimBar.withOpacity(0.3) : AppColors.dimBarLight,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context, AppStrings s, ProgressProvider prog, bool isDark) {
    final spots = prog.weightData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.weight, style: Theme.of(context).textTheme.titleMedium),
              Text('${prog.currentWeight} kg · ${s.goal} ${prog.goalWeight.round()}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Text('100', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minY: 60,
                maxY: 90,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) {
                        final labels = ['Jun 1', '', 'Jun 15', '', 'Jul 1', '', 'Jul 13'];
                        final i = val.toInt();
                        if (i >= 0 && i < labels.length && labels[i].isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[i], style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: isDark ? AppColors.darkCard : Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.25),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text('0', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
