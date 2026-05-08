import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class QuickActionsRow extends StatelessWidget {
  final String? petId;

  const QuickActionsRow({super.key, this.petId});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Vacinas',
        icon: Icons.vaccines,
        color: const Color(0xFF3498DB),
        onTap: () => petId != null
            ? context.go('/pets/$petId/vaccines')
            : context.go('/pets'),
      ),
      _QuickAction(
        label: 'Peso',
        icon: Icons.monitor_weight,
        color: const Color(0xFF2ECC71),
        onTap: () => petId != null
            ? context.go('/pets/$petId/weight')
            : context.go('/pets'),
      ),
      _QuickAction(
        label: 'Passeio',
        icon: Icons.directions_walk,
        color: AppColors.primary,
        onTap: () => petId != null
            ? context.go('/pets/$petId/walks')
            : context.go('/pets'),
      ),
      _QuickAction(
        label: 'Vet',
        icon: Icons.local_hospital,
        color: const Color(0xFFE74C3C),
        onTap: () => context.go('/calendar'),
      ),
      _QuickAction(
        label: 'Loja',
        icon: Icons.storefront,
        color: const Color(0xFFD4A017),
        onTap: () => context.go('/shop'),
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: action.onTap,
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: AppSizes.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
