import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/user_provider.dart';

class StreakCalendar extends ConsumerStatefulWidget {
  const StreakCalendar({super.key});

  @override
  ConsumerState<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends ConsumerState<StreakCalendar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Returns the set of date strings (yyyy-MM-dd) that are active in pointsLog.
  Set<String> _getActiveDays(Map<String, dynamic> pointsLog) {
    final activeDays = <String>{};
    for (final key in pointsLog.keys) {
      // Keys are either "yyyy-MM-dd" (daily) or "yyyy-MM" (monthly)
      // We only care about the daily ones for the calendar
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key)) {
        activeDays.add(key);
      }
    }
    return activeDays;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getMilestoneMessage(int streak) {
    if (streak >= 100) return '¡Leyenda! 100+ días seguidos 🏆';
    if (streak >= 30) return '¡Increíble! Más de un mes seguido 🌟';
    if (streak >= 7) return '¡Una semana completa! 🎉';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final streak = user?.currentStreak ?? 0;
    final pointsLog = user?.pointsLog ?? {};
    final activeDays = _getActiveDays(pointsLog);

    final today = DateTime.now();
    // Start of the 7-week window: go back 48 days so we always show 7 full weeks
    // ending on today.
    // We arrange the grid column-by-column (weeks), left-to-right, oldest first.
    // Each column has 7 days (Mon–Sun is not enforced; we just fill from oldest to today).
    // Total cells: 7 cols x 7 rows = 49. We'll anchor so that today is in the last column.

    // Determine grid start: the Monday of 6 weeks ago
    // For simplicity, just go back 48 days from today (49 cells total, today is the last one)
    final gridStart = today.subtract(const Duration(days: 48));

    final milestoneMsg = _getMilestoneMessage(streak);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSizes.sm),
              const Text(
                'Actividad últimas 7 semanas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Grid
          _buildGrid(gridStart, today, activeDays),

          const SizedBox(height: AppSizes.md),

          // Legend
          Row(
            children: [
              _LegendDot(
                  color: const Color(0xFF4CAF50), label: 'Activo'),
              const SizedBox(width: AppSizes.md),
              _LegendDot(
                  color: const Color(0xFFE0E0E0), label: 'Sin actividad'),
              const SizedBox(width: AppSizes.md),
              _LegendDot(
                  color: AppColors.primary,
                  label: 'Hoy',
                  isBorder: true),
            ],
          ),

          const SizedBox(height: AppSizes.md),

          // Streak row
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 28)),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡$streak días seguidos!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (milestoneMsg.isNotEmpty)
                        Text(
                          milestoneMsg,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        )
                      else
                        Text(
                          streak == 0
                              ? 'Registra un paseo para comenzar'
                              : 'Faltan ${7 - (streak % 7 == 0 ? 7 : streak % 7)} días para el próximo logro',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
      DateTime gridStart, DateTime today, Set<String> activeDays) {
    const cols = 7;
    const rows = 7;
    const cellSize = 28.0;
    const gap = 4.0;

    return SizedBox(
      height: rows * cellSize + (rows - 1) * gap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(cols, (col) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(rows, (row) {
              final dayIndex = col * rows + row;
              final date = gridStart.add(Duration(days: dayIndex));
              final isToday = _isSameDay(date, today);
              final isFuture = date.isAfter(today);
              final dateStr = _formatDate(date);
              final isActive = !isFuture && activeDays.contains(dateStr);

              if (isToday) {
                return AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: _buildCell(
                    size: cellSize,
                    isActive: isActive,
                    isToday: true,
                    isFuture: false,
                  ),
                );
              }

              return _buildCell(
                size: cellSize,
                isActive: isActive,
                isToday: false,
                isFuture: isFuture,
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildCell({
    required double size,
    required bool isActive,
    required bool isToday,
    required bool isFuture,
  }) {
    Color fillColor;
    Border? border;

    if (isFuture) {
      fillColor = const Color(0xFFF5F5F5);
    } else if (isActive) {
      fillColor = const Color(0xFF4CAF50);
    } else {
      fillColor = const Color(0xFFE0E0E0);
    }

    if (isToday) {
      border = Border.all(color: AppColors.primary, width: 2);
      if (!isActive) fillColor = AppColors.primary.withOpacity(0.15);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isBorder;

  const _LegendDot({
    required this.color,
    required this.label,
    this.isBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isBorder ? color.withOpacity(0.15) : color,
            borderRadius: BorderRadius.circular(3),
            border: isBorder ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
        ),
      ],
    );
  }
}
