import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calorie_tracker/core/theme/app_colors.dart';
import 'package:calorie_tracker/core/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers/diary_provider.dart';
import 'package:calorie_tracker/providers/locale_provider.dart';
import 'package:calorie_tracker/providers/theme_provider.dart';
import 'package:calorie_tracker/models/meal.dart';
import 'package:calorie_tracker/models/food_item.dart';
import 'package:calorie_tracker/shared/widgets/app_widgets.dart';

enum _LogTab { photo, barcode, search }

class LogFoodScreen extends StatefulWidget {
  final MealType mealType;
  const LogFoodScreen({super.key, required this.mealType});

  @override
  State<LogFoodScreen> createState() => _LogFoodScreenState();
}

class _LogFoodScreenState extends State<LogFoodScreen> with TickerProviderStateMixin {
  _LogTab _tab = _LogTab.photo;
  final _searchCtrl = TextEditingController();
  List<FoodItem> _results = [];
  List<FoodItem> _detected = [];
  bool _barcodeScanned = false;
  FoodItem? _scannedProduct;
  double _scannedServings = 1.0;
  final Set<String> _selectedDetected = {};

  late AnimationController _scanAnimCtrl;
  late Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _results = FoodDatabase.search('');
    _detected = [
      FoodItem(id: '6', name: 'Spaghetti, marinara', calories: 320, protein: 11, carbs: 58, fat: 6, portionLabel: '1.5 cups'),
      FoodItem(id: '7', name: 'Beef meatballs', calories: 240, protein: 18, carbs: 8, fat: 16, portionLabel: '3 · 9 pkg'),
      FoodItem(id: '8', name: 'Parmesan, grated', calories: 25, protein: 2, carbs: 0, fat: 2, portionLabel: '1 tbsp · to adjust'),
    ];
    _selectedDetected.addAll(['6', '7']);

    _scanAnimCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0.15, end: 0.85).animate(CurvedAnimation(parent: _scanAnimCtrl, curve: Curves.easeInOut));

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _tab == _LogTab.barcode) {
        setState(() => _barcodeScanned = true);
      }
    });
  }

  @override
  void dispose() {
    _scanAnimCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _mealLabel(AppStrings s) {
    switch (widget.mealType) {
      case MealType.breakfast: return s.addToBreakfast;
      case MealType.lunch: return s.addToLunch;
      case MealType.dinner: return s.addToDinner;
      case MealType.snack: return s.addToSnack;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final s = AppLocalizations.of(locale);
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Tab switcher
            _buildTabBar(context, s, isDark),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(context, s, isDark, surfaceColor, ctrl)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppStrings s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
          const Spacer(),
          _tabBtn(context, s.photo, _LogTab.photo, isDark),
          const SizedBox(width: 4),
          _tabBtn(context, s.barcode, _LogTab.barcode, isDark),
          const SizedBox(width: 4),
          _tabBtn(context, s.search, _LogTab.search, isDark),
          const Spacer(),
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.flash_on, color: Colors.black, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(BuildContext context, String label, _LogTab tab, bool isDark) {
    final selected = _tab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tab = tab;
          if (tab == _LogTab.barcode) {
            _barcodeScanned = false;
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _tab == _LogTab.barcode) setState(() => _barcodeScanned = true);
            });
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: selected ? null : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.black : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        )),
      ),
    );
  }

  Widget _buildBody(BuildContext ctx, AppStrings s, bool isDark, Color surfaceColor, ScrollController ctrl) {
    switch (_tab) {
      case _LogTab.photo: return _buildPhotoTab(ctx, s, isDark, surfaceColor);
      case _LogTab.barcode: return _buildBarcodeTab(ctx, s, isDark, surfaceColor);
      case _LogTab.search: return _buildSearchTab(ctx, s, isDark, ctrl);
    }
  }

  // ─── PHOTO TAB ─────────────────────────────────────────────────────────────
  Widget _buildPhotoTab(BuildContext context, AppStrings s, bool isDark, Color surfaceColor) {
    final totalCal = _detected
        .where((f) => _selectedDetected.contains(f.id))
        .fold(0, (sum, f) => sum + f.calories);

    return Column(
      children: [
        // Fake camera view
        Expanded(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? const Color(0xFF1C2A14) : const Color(0xFF2A3A1C),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80'),
                    fit: BoxFit.cover,
                    opacity: 0.85,
                  ),
                ),
                child: Stack(
                  children: [
                    // Scan frame corners
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: CustomPaint(painter: _ScanFramePainter()),
                      ),
                    ),
                  ],
                ),
              ),
              // Result sheet at bottom
              Positioned(
                bottom: 0, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 28, height: 28,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.black, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('${_detected.length} ${s.itemsFound} · $totalCal ${s.kcal}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isDark ? Colors.white : Colors.black),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 10),
                        Text('94% ${s.confident}', style: Theme.of(context).textTheme.bodySmall),
                      ]),
                      const SizedBox(height: 12),
                      ..._detected.map((food) => _detectedFoodRow(context, food, isDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(child: Text(s.editItems, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: '${_mealLabel(s)} · $totalCal ${s.kcal}',
                  fontSize: 14,
                  onTap: () {
                    final diary = context.read<DiaryProvider>();
                    for (final food in _detected.where((f) => _selectedDetected.contains(f.id))) {
                      diary.addFoodToMeal(widget.mealType, food);
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detectedFoodRow(BuildContext context, FoodItem food, bool isDark) {
    final selected = _selectedDetected.contains(food.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () => setState(() {
          if (selected) _selectedDetected.remove(food.id);
          else _selectedDetected.add(food.id);
        }),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: selected ? null : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: selected ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(food.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                if (food.portionLabel != null)
                  Text(food.portionLabel!, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
            Text('${food.calories}', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  // ─── BARCODE TAB ───────────────────────────────────────────────────────────
  Widget _buildBarcodeTab(BuildContext context, AppStrings s, bool isDark, Color surfaceColor) {
    _scannedProduct ??= FoodDatabase.items.firstWhere((f) => f.id == '9');
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Fake camera
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? const Color(0xFF1A1A2A) : const Color(0xFF2A2A3A),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1616400619175-5beda3a17896?w=600&q=80'),
                    fit: BoxFit.cover,
                    opacity: 0.7,
                  ),
                ),
                child: Stack(children: [
                  // Animated scan line
                  AnimatedBuilder(
                    animation: _scanAnim,
                    builder: (_, __) => Positioned(
                      left: 40, right: 40,
                      top: MediaQuery.of(context).size.height * 0.25 * _scanAnim.value,
                      child: Container(height: 2, color: AppColors.primary.withOpacity(0.8)),
                    ),
                  ),
                  // Barcode frame
                  Center(
                    child: Container(
                      width: 220, height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ]),
              ),
              // Product card at bottom
              if (_barcodeScanned && _scannedProduct != null)
                Positioned(
                  bottom: 0, left: 20, right: 20,
                  child: _buildProductCard(context, s, _scannedProduct!, isDark),
                ),
            ],
          ),
        ),
        if (_barcodeScanned && _scannedProduct != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: PrimaryButton(
              label: '${_mealLabel(s)} · ${(_scannedProduct!.calories * _scannedServings).round()} ${s.kcal}',
              onTap: () {
                context.read<DiaryProvider>().addFoodToMeal(widget.mealType, _scannedProduct!.copyWith(servings: _scannedServings));
                Navigator.pop(context);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, AppStrings s, FoodItem food, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFC107), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.local_grocery_store, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(food.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              if (food.brand != null) Text('${food.brand} · ${food.portionLabel}', style: Theme.of(context).textTheme.bodySmall),
            ])),
            Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Center(child: Text('A', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)))),
          ]),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _nutriCol(context, '${food.calories}', s.kcal),
            _nutriCol(context, '${food.protein}g', s.protein),
            _nutriCol(context, '${food.carbs}g', s.carbs),
            _nutriCol(context, '${food.fat}g', s.fat),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Text(s.servings, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _scannedServings = (_scannedServings - 1).clamp(1, 10).toDouble()),
              child: _servingBtn(Icons.remove, isDark),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('${_scannedServings.round()}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            GestureDetector(
              onTap: () => setState(() => _scannedServings = (_scannedServings + 1).clamp(1, 10).toDouble()),
              child: _servingBtn(Icons.add, isDark),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _servingBtn(IconData icon, bool isDark) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: isDark ? Colors.white : Colors.black),
    );
  }

  Widget _nutriCol(BuildContext context, String val, String label) {
    return Column(children: [
      Text(val, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }

  // ─── SEARCH TAB ────────────────────────────────────────────────────────────
  Widget _buildSearchTab(BuildContext context, AppStrings s, bool isDark, ScrollController ctrl) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _results = FoodDatabase.search(val)),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: s.searchFood,
                      hintStyle: TextStyle(color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      prefixIcon: Icon(Icons.search, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(s.cancel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [s.all, s.myFoods, s.recipes, s.recent].map((label) {
              final sel = label == s.all;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(label, style: TextStyle(
                    color: sel ? Colors.black : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  )),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            controller: ctrl,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _results.length,
            itemBuilder: (_, i) => _searchResultRow(context, _results[i], s, isDark),
          ),
        ),
      ],
    );
  }

  Widget _searchResultRow(BuildContext context, FoodItem food, AppStrings s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(food.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
                  if (food.isVerified) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(s.verified, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ],
                  if (food.isMyFood) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF4A90D9).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(s.myFood, style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(food.portionLabel ?? s.per100g, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
            Text('${food.calories}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                context.read<DiaryProvider>().addFoodToMeal(widget.mealType, food);
                Navigator.pop(context);
              },
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.black, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for scan frame corners
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 24.0;

    // Top-left
    canvas.drawLine(Offset(0, len), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - len, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - len), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
