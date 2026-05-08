import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../models/shop_item_model.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItemModel item;
  final int userPoints;
  final VoidCallback onBuy;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.userPoints,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = userPoints >= item.cost;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: item.isOwned
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(item.icon, size: 52, color: item.color),
                  if (item.isOwned)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 2),
                        Text(
                          '${item.cost}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: canAfford ? AppColors.primary : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    if (item.isOwned)
                      const Text(
                        'Possuído',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: canAfford ? onBuy : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: canAfford
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                          ),
                          child: Text(
                            'Comprar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: canAfford ? Colors.white : AppColors.textLight,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
