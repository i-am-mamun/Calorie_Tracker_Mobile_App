import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:calorie_tracker/core/theme/app_colors.dart';
import 'package:calorie_tracker/core/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers/locale_provider.dart';
import 'package:calorie_tracker/providers/theme_provider.dart';
import 'package:calorie_tracker/models/meal.dart';
import 'package:calorie_tracker/features/home/presentation/screens/home_screen.dart';
import 'package:calorie_tracker/features/progress/presentation/screens/progress_screen.dart';
import 'package:calorie_tracker/features/plan/presentation/screens/plan_screen.dart';
import 'package:calorie_tracker/features/profile/presentation/screens/profile_screen.dart';
import 'package:calorie_tracker/features/log_food/presentation/screens/log_food_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProgressScreen(),
    SizedBox(), // placeholder for FAB
    PlanScreen(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      _showLogFood();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showLogFood() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LogFoodScreen(mealType: MealType.dinner),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final s = AppLocalizations.of(locale);
    final isDark = context.watch<ThemeProvider>().isDark;
    final navBg = isDark ? AppColors.darkNavBar : AppColors.lightNavBar;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: navBg,
    ));

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavBar(context, s, isDark, navBg),
    );
  }

  Widget _buildNavBar(BuildContext context, AppStrings s, bool isDark, Color navBg) {
    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.home_outlined, Icons.home, s.today, 0, isDark),
              _navItem(context, Icons.bar_chart_outlined, Icons.bar_chart, s.progress, 1, isDark),
              _fabItem(context, isDark),
              _navItem(context, Icons.calendar_today_outlined, Icons.calendar_today, s.plan, 3, isDark),
              _navItem(context, Icons.person_outline, Icons.person, s.you, 4, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, IconData activeIcon, String label, int index, bool isDark) {
    final selected = _currentIndex == index;
    final activeColor = isDark ? AppColors.primary : AppColors.primaryDark;
    final inactiveColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: selected ? activeColor : inactiveColor, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 10,
              color: selected ? activeColor : inactiveColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _fabItem(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: _showLogFood,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x50C8F135), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }
}
