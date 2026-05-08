import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/pet_model.dart';
import '../../providers/pets_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../pets/widgets/pet_avatar_widget.dart';
import 'widgets/pet_skin_selector.dart';

class AvatarCustomizerScreen extends ConsumerStatefulWidget {
  final String petId;

  const AvatarCustomizerScreen({super.key, required this.petId});

  @override
  ConsumerState<AvatarCustomizerScreen> createState() => _AvatarCustomizerScreenState();
}

class _AvatarCustomizerScreenState extends ConsumerState<AvatarCustomizerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _previewBreed;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petsProvider);
    final pet = pets.firstWhere((p) => p.id == widget.petId);
    final shopItems = ref.watch(shopProvider);
    final user = ref.watch(userProvider);
    final ownedItems = user?.ownedItems ?? [];

    final previewPet = _previewBreed != null
        ? pet.copyWith(breed: _previewBreed)
        : pet;

    final hats = shopItems.where((i) => i.category == 'hat' && ownedItems.contains(i.id)).toList();
    final collars = shopItems.where((i) => i.category == 'collar' && ownedItems.contains(i.id)).toList();
    final outfits = shopItems.where((i) => i.category == 'outfit' && ownedItems.contains(i.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Personalizar - ${pet.name}'),
        backgroundColor: const Color(0xFF9B59B6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/${widget.petId}'),
        ),
        actions: [
          TextButton(
            onPressed: () => _saveChanges(pet),
            child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview area
          Container(
            color: const Color(0xFF9B59B6).withOpacity(0.1),
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              children: [
                PetAvatarWidget(
                  pet: previewPet,
                  size: 140,
                  showAccessories: true,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  _previewBreed ?? pet.breed,
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Skin'),
              Tab(text: 'Chapéus'),
              Tab(text: 'Coleiras'),
            ],
            labelColor: const Color(0xFF9B59B6),
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: const Color(0xFF9B59B6),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Skin tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: PetSkinSelector(
                    pet: pet,
                    selectedBreed: _previewBreed,
                    onBreedSelected: (breed) {
                      setState(() => _previewBreed = breed);
                    },
                  ),
                ),

                // Hats tab
                hats.isEmpty
                    ? _EmptyAccessoryTab(
                        message: 'Nenhum chapéu ainda',
                        hint: 'Compre chapéus na loja!',
                        onShop: () => context.go('/shop/store'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSizes.md),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: AppSizes.sm,
                          mainAxisSpacing: AppSizes.sm,
                        ),
                        itemCount: hats.length,
                        itemBuilder: (context, index) {
                          final hat = hats[index];
                          final isEquipped = pet.equippedHat == hat.id;
                          return GestureDetector(
                            onTap: () {
                              ref.read(petsProvider.notifier).equipAccessory(
                                pet.id, hat.id, 'hat');
                            },
                            child: _AccessoryTile(
                              icon: hat.icon,
                              color: hat.color,
                              name: hat.name,
                              isEquipped: isEquipped,
                            ),
                          );
                        },
                      ),

                // Collars tab
                collars.isEmpty
                    ? _EmptyAccessoryTab(
                        message: 'Nenhuma coleira ainda',
                        hint: 'Compre coleiras na loja!',
                        onShop: () => context.go('/shop/store'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSizes.md),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: AppSizes.sm,
                          mainAxisSpacing: AppSizes.sm,
                        ),
                        itemCount: collars.length,
                        itemBuilder: (context, index) {
                          final collar = collars[index];
                          final isEquipped = pet.equippedCollar == collar.id;
                          return GestureDetector(
                            onTap: () {
                              ref.read(petsProvider.notifier).equipAccessory(
                                pet.id, collar.id, 'collar');
                            },
                            child: _AccessoryTile(
                              icon: collar.icon,
                              color: collar.color,
                              name: collar.name,
                              isEquipped: isEquipped,
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges(PetModel pet) async {
    if (_previewBreed != null) {
      await ref.read(petsProvider.notifier).updatePet(
        pet.copyWith(breed: _previewBreed),
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alterações salvas!'), backgroundColor: AppColors.success),
      );
      context.go('/pets/${widget.petId}');
    }
  }
}

class _AccessoryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final bool isEquipped;

  const _AccessoryTile({
    required this.icon,
    required this.color,
    required this.name,
    required this.isEquipped,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isEquipped ? color.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isEquipped ? color : Colors.grey.shade200,
          width: isEquipped ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              color: isEquipped ? color : AppColors.textDark,
              fontWeight: isEquipped ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          if (isEquipped) ...[
            const SizedBox(height: 2),
            const Icon(Icons.check_circle, color: AppColors.success, size: 14),
          ],
        ],
      ),
    );
  }
}

class _EmptyAccessoryTab extends StatelessWidget {
  final String message;
  final String hint;
  final VoidCallback onShop;

  const _EmptyAccessoryTab({
    required this.message,
    required this.hint,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 48, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: AppSizes.sm),
          Text(message, style: const TextStyle(color: AppColors.textLight, fontSize: 16)),
          const SizedBox(height: 4),
          Text(hint, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
          const SizedBox(height: AppSizes.md),
          ElevatedButton.icon(
            onPressed: onShop,
            icon: const Icon(Icons.storefront),
            label: const Text('Ir para a Loja'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017)),
          ),
        ],
      ),
    );
  }
}
