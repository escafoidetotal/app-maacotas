import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_item_model.dart';
import 'user_provider.dart';
import 'pawpoints_provider.dart';

class ShopNotifier extends StateNotifier<List<ShopItemModel>> {
  final Ref ref;

  ShopNotifier(this.ref) : super(ShopItemModel.defaultItems) {
    _syncOwned();
  }

  void _syncOwned() {
    final user = ref.read(userProvider);
    if (user == null) return;
    state = state.map((item) {
      return item..isOwned = user.ownedItems.contains(item.id);
    }).toList();
  }

  List<ShopItemModel> getByCategory(String category) {
    return state.where((item) => item.category == category).toList();
  }

  Future<bool> purchaseItem(String itemId) async {
    final item = state.firstWhere((i) => i.id == itemId);
    if (item.isOwned) return false;

    final success = await ref.read(pawPointsProvider.notifier).spendPoints(item.cost);
    if (!success) return false;

    await ref.read(userProvider.notifier).addOwnedItem(itemId);

    state = state.map((i) {
      if (i.id == itemId) {
        return i..isOwned = true;
      }
      return i;
    }).toList();

    return true;
  }

  bool isOwned(String itemId) {
    return state.any((i) => i.id == itemId && i.isOwned);
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, List<ShopItemModel>>((ref) {
  return ShopNotifier(ref);
});

final shopCategoryProvider = Provider.family<List<ShopItemModel>, String>((ref, category) {
  return ref.watch(shopProvider).where((item) => item.category == category).toList();
});
