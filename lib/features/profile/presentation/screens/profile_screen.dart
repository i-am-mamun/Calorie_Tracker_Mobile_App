import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calorie_tracker/core/theme/app_colors.dart';
import 'package:calorie_tracker/core/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers/locale_provider.dart';
import 'package:calorie_tracker/providers/theme_provider.dart';
import 'package:calorie_tracker/providers/diary_provider.dart';
import 'package:calorie_tracker/shared/widgets/app_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final s = AppLocalizations.of(locale);
    final isDark = context.watch<ThemeProvider>().isDark;
    final diary = context.watch<DiaryProvider>();

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
                  Text(s.you, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 24),
                  _buildProfileCard(context, isDark),
                  const SizedBox(height: 20),
                  _buildStatsRow(context, s, diary, isDark),
                  const SizedBox(height: 24),
                  _buildAppearanceSection(context, s, isDark),
                  const SizedBox(height: 16),
                  _buildGoalSection(context, s, diary, isDark),
                  const SizedBox(height: 16),
                  _buildAboutSection(context, s, isDark),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, bool isDark) {
    return AppCard(
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                child: Text('N', style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w700)),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? AppColors.darkBg : AppColors.lightBg, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, size: 12, color: isDark ? AppColors.primary : AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nasim', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('nasim@email.com', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primary : AppColors.primaryDark).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: isDark ? AppColors.primary : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '12 day streak',
                        style: TextStyle(
                          color: isDark ? AppColors.primary : AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppStrings s, DiaryProvider diary, bool isDark) {
    return Row(
      children: [
        Expanded(child: _miniStatCard(context, '${diary.calorieGoal}', '${s.calorieGoal}', isDark)),
        const SizedBox(width: 10),
        Expanded(child: _miniStatCard(context, '76.2 kg', '${s.weight}', isDark)),
        const SizedBox(width: 10),
        Expanded(child: _miniStatCard(context, '72 kg', '${s.goalWeight}', isDark)),
      ],
    );
  }

  Widget _miniStatCard(BuildContext context, String val, String label, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(val, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppStrings s, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.appSettings, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          // Theme toggle
          _settingRow(
            context,
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            iconColor: const Color(0xFFFFCC00),
            title: s.theme,
            trailing: GestureDetector(
              onTap: () => context.read<ThemeProvider>().toggle(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    _themeOption(context, s.darkMode.replaceAll(' mode', '').replaceAll(' মোড', ''), isDark, true),
                    _themeOption(context, s.lightMode.replaceAll(' mode', '').replaceAll(' মোড', ''), !isDark, false),
                  ],
                ),
              ),
            ),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _divider(isDark),
          const SizedBox(height: 12),
          // Language toggle
          _settingRow(
            context,
            icon: Icons.language,
            iconColor: const Color(0xFF4A90D9),
            title: s.language,
            trailing: GestureDetector(
              onTap: () => context.read<LocaleProvider>().toggle(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    _langOption(context, 'EN', !context.watch<LocaleProvider>().isBangla, isDark),
                    _langOption(context, 'বাং', context.watch<LocaleProvider>().isBangla, isDark),
                  ],
                ),
              ),
            ),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _divider(isDark),
          const SizedBox(height: 12),
          _settingRow(
            context,
            icon: Icons.notifications_outlined,
            iconColor: AppColors.orange,
            title: s.notifications,
            trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _themeOption(BuildContext context, String label, bool selected, bool isDarkOpt) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final tp = context.read<ThemeProvider>();
          if (isDarkOpt && !tp.isDark) tp.toggle();
          if (!isDarkOpt && tp.isDark) tp.toggle();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? Colors.black : (context.watch<ThemeProvider>().isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            )),
          ),
        ),
      ),
    );
  }

  Widget _langOption(BuildContext context, String label, bool selected, bool isDark) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.black : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          )),
        ),
      ),
    );
  }

  Widget _buildGoalSection(BuildContext context, AppStrings s, DiaryProvider diary, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.goalSettings, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _settingRow(
            context,
            icon: Icons.local_fire_department_outlined,
            iconColor: AppColors.red,
            title: s.calorieGoal,
            subtitle: '${diary.calorieGoal} kcal/day',
            trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _divider(isDark),
          const SizedBox(height: 12),
          _settingRow(
            context,
            icon: Icons.monitor_weight_outlined,
            iconColor: AppColors.primary,
            title: s.weightGoal,
            subtitle: '72 kg · -0.5 kg/week',
            trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, AppStrings s, bool isDark) {
    return AppCard(
      child: Column(
        children: [
          _settingRow(context, icon: Icons.info_outline, iconColor: const Color(0xFF888888), title: 'About', trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary), isDark: isDark),
          const SizedBox(height: 12),
          _divider(isDark),
          const SizedBox(height: 12),
          _settingRow(context, icon: Icons.privacy_tip_outlined, iconColor: const Color(0xFF888888), title: 'Privacy', trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary), isDark: isDark),
          const SizedBox(height: 12),
          _divider(isDark),
          const SizedBox(height: 12),
          _settingRow(context, icon: Icons.logout, iconColor: AppColors.red, title: 'Sign out', trailing: const SizedBox(), isDark: isDark),
        ],
      ),
    );
  }

  Widget _settingRow(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null) Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Container(height: 0.5, color: isDark ? AppColors.darkBorder : AppColors.lightBorder);
  }
}
