import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/pawpoints_provider.dart';
import '../../providers/shop_provider.dart';
import '../../services/admob_service.dart';
import 'widgets/shop_item_card.dart';
import 'widgets/points_badge.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _categories = ['hat', 'collar', 'outfit', 'skin', 'theme'];
  static const List<String> _categoryLabels = ['Chapéus', 'Coleiras', 'Fantasias', 'Skins', 'Temas'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = ref.watch(pawPointsProvider);
    final shopItems = ref.watch(shopProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Loja'),
        backgroundColor: const Color(0xFFD4A017),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shop'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: Center(child: PointsBadge(points: points)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categoryLabels.map((l) => Tab(text: l)).toList(),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Column(
        children: [
          // Watch ad banner
          GestureDetector(
            onTap: () => _watchAd(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: AppSizes.md),
              color: AppColors.secondary.withOpacity(0.15),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_filled, color: AppColors.secondary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Assista um anúncio e ganhe +15 pts',
                    style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final items = shopItems.where((i) => i.category == category).toList();
                return _CategoryGrid(
                  items: items,
                  userPoints: points,
                  onBuy: (itemId) => _purchaseItem(context, itemId),
                );
              }).toList(),
            ),
          ),

          const BannerAdWidget(),
        ],
      ),
    );
  }

  Future<void> _purchaseItem(BuildContext context, String itemId) async {
    final item = ref.read(shopProvider).firstWhere((i) => i.id == itemId);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 48, color: item.color),
            const SizedBox(height: AppSizes.sm),
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(item.description, style: const TextStyle(color: AppColors.textLight)),
            const SizedBox(height: AppSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '${item.cost} PawPoints',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017)),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(shopProvider.notifier).purchaseItem(itemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Compra realizada! ${item.name} adquirido.' : 'PawPoints insuficientes!'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _watchAd(BuildContext context) async {
    final success = await AdmobService().showRewardedAd(
      onRewarded: (pts) async {
        await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.adWatched);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('+15 PawPoints ganhos!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );

    if (!success) {
      // Dev fallback
      await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.adWatched);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+15 PawPoints ganhos!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

class _CategoryGrid extends StatelessWidget {
  final List items;
  final int userPoints;
  final Function(String) onBuy;

  const _CategoryGrid({
    required this.items,
    required this.userPoints,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Nenhum item nesta categoria', style: TextStyle(color: AppColors.textLight)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSizes.md,
        mainAxisSpacing: AppSizes.md,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ShopItemCard(
          item: item,
          userPoints: userPoints,
          onBuy: () => onBuy(item.id),
        );
      },
    );
  }
}
