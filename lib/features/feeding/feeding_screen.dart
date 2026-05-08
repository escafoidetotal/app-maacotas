import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/feeding_model.dart';
import '../../services/hive_service.dart';
import 'add_feeding_screen.dart';

class FeedingScreen extends StatefulWidget {
  final String petId;

  const FeedingScreen({super.key, required this.petId});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  List<FeedingModel> _feedings = [];

  @override
  void initState() {
    super.initState();
    _loadFeedings();
  }

  void _loadFeedings() {
    setState(() {
      _feedings = HiveService.getFeedingsForPet(widget.petId);
    });
  }

  // Returns true if this feeding applies today
  bool _appliesToday(FeedingModel feeding) {
    final today = DateTime.now().weekday; // 1=Monday, 7=Sunday
    return feeding.daysOfWeek.contains(today);
  }

  // Find the next scheduled meal for today
  FeedingModel? _getNextMeal() {
    final now = TimeOfDay.now();
    final todayFeedings = _feedings.where(_appliesToday).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    for (final f in todayFeedings) {
      final parts = f.time.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      if (hour > now.hour || (hour == now.hour && minute > now.minute)) {
        return f;
      }
    }
    // If no upcoming, return first of today (already passed)
    return todayFeedings.isNotEmpty ? todayFeedings.first : null;
  }

  String _daysLabel(List<int> days) {
    if (days.length == 7) return 'Todos los días';
    const map = {1: 'L', 2: 'M', 3: 'X', 4: 'J', 5: 'V', 6: 'S', 7: 'D'};
    final sorted = List.from(days)..sort();
    return sorted.map((d) => map[d] ?? '?').join(' ');
  }

  Color _foodTypeColor(String foodType) {
    switch (foodType) {
      case 'Pienso seco':
        return const Color(0xFFE67E22);
      case 'Pienso húmedo':
        return const Color(0xFF3498DB);
      case 'Comida casera':
        return const Color(0xFF2ECC71);
      case 'Mixto':
        return const Color(0xFF9B59B6);
      default:
        return AppColors.secondary;
    }
  }

  IconData _foodTypeIcon(String foodType) {
    switch (foodType) {
      case 'Pienso seco':
        return Icons.grain;
      case 'Pienso húmedo':
        return Icons.water_drop;
      case 'Comida casera':
        return Icons.home;
      case 'Mixto':
        return Icons.blender;
      default:
        return Icons.food_bank;
    }
  }

  Future<void> _deleteFeeding(FeedingModel feeding) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar comida'),
        content: Text('¿Eliminar "${feeding.mealName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HiveService.deleteFeeding(feeding.id);
      _loadFeedings();
    }
  }

  Future<void> _openAdd({FeedingModel? existing}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddFeedingScreen(petId: widget.petId, existing: existing),
      ),
    );
    if (result == true) _loadFeedings();
  }

  @override
  Widget build(BuildContext context) {
    final nextMeal = _getNextMeal();
    final todayFeedings = _feedings.where(_appliesToday).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final otherFeedings = _feedings.where((f) => !_appliesToday(f)).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Plan de alimentación'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: _feedings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.food_bank_outlined,
                    size: 72,
                    color: AppColors.textLight.withOpacity(0.4),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'Sin comidas programadas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'Pulsa el botón + para añadir\nuna comida al horario',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, AppSizes.md, AppSizes.md, 100),
              children: [
                // Next meal highlight
                if (nextMeal != null) ...[
                  _NextMealCard(
                    feeding: nextMeal,
                    foodColor: _foodTypeColor(nextMeal.foodType),
                    foodIcon: _foodTypeIcon(nextMeal.foodType),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],

                // Today's schedule
                if (todayFeedings.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.today, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppSizes.xs),
                      const Text(
                        'Hoy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...todayFeedings.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final f = entry.value;
                    final isNext = nextMeal?.id == f.id;
                    return _FeedingTimelineItem(
                      feeding: f,
                      isLast: idx == todayFeedings.length - 1,
                      isHighlighted: isNext,
                      foodColor: _foodTypeColor(f.foodType),
                      foodIcon: _foodTypeIcon(f.foodType),
                      daysLabel: _daysLabel(f.daysOfWeek),
                      onEdit: () => _openAdd(existing: f),
                      onDelete: () => _deleteFeeding(f),
                    );
                  }),
                ],

                // Other feedings not for today
                if (otherFeedings.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.lg),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.textLight),
                      const SizedBox(width: AppSizes.xs),
                      const Text(
                        'Otros días',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...otherFeedings.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final f = entry.value;
                    return _FeedingTimelineItem(
                      feeding: f,
                      isLast: idx == otherFeedings.length - 1,
                      isHighlighted: false,
                      foodColor: _foodTypeColor(f.foodType).withOpacity(0.5),
                      foodIcon: _foodTypeIcon(f.foodType),
                      daysLabel: _daysLabel(f.daysOfWeek),
                      onEdit: () => _openAdd(existing: f),
                      onDelete: () => _deleteFeeding(f),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}

class _NextMealCard extends StatelessWidget {
  final FeedingModel feeding;
  final Color foodColor;
  final IconData foodIcon;

  const _NextMealCard({
    required this.feeding,
    required this.foodColor,
    required this.foodIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(foodIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próxima comida',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  feeding.mealName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${feeding.foodType}  •  ${feeding.quantityGrams}g',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                feeding.time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Horas',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedingTimelineItem extends StatelessWidget {
  final FeedingModel feeding;
  final bool isLast;
  final bool isHighlighted;
  final Color foodColor;
  final IconData foodIcon;
  final String daysLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FeedingTimelineItem({
    required this.feeding,
    required this.isLast,
    required this.isHighlighted,
    required this.foodColor,
    required this.foodIcon,
    required this.daysLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(feeding.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // We handle deletion ourselves
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(
                    feeding.time,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isHighlighted ? AppColors.primary : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isHighlighted ? AppColors.primary : Colors.grey.shade300,
                      border: isHighlighted
                          ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 3)
                          : null,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey.shade200,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            // Card
            Expanded(
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.sm),
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: isHighlighted
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: foodColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Icon(foodIcon, color: foodColor, size: 20),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  feeding.mealName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (isHighlighted) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Próxima',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 9),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '${feeding.foodType}  •  ${feeding.quantityGrams}g',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textLight),
                            ),
                            if (feeding.notes != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                feeding.notes!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                    fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.textLight),
                          const SizedBox(height: 4),
                          Text(
                            daysLabel,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
