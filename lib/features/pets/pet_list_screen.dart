import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/pets_provider.dart';
import '../../services/admob_service.dart';
import 'widgets/pet_avatar_widget.dart';

class PetListScreen extends ConsumerWidget {
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Pets'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/pets/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: pets.isEmpty
                ? _buildEmpty(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        child: InkWell(
                          onTap: () => context.go('/pets/${pet.id}'),
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.md),
                            child: Row(
                              children: [
                                PetAvatarWidget(pet: pet, size: 72),
                                const SizedBox(width: AppSizes.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pet.breed,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _InfoChip(
                                            label: AppDateUtils.formatAge(pet.birthdate),
                                            icon: Icons.cake,
                                          ),
                                          const SizedBox(width: 8),
                                          _InfoChip(
                                            label: '${pet.weight} kg',
                                            icon: Icons.monitor_weight,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      pet.gender == 'male' ? Icons.male : Icons.female,
                                      color: pet.gender == 'male'
                                          ? Colors.blue
                                          : Colors.pink,
                                    ),
                                    const SizedBox(height: 4),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textLight,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/pets/add'),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Pet'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Nenhum pet adicionado ainda',
            style: TextStyle(fontSize: 18, color: AppColors.textLight),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Adicione seu primeiro pet!',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
          ),
          const SizedBox(height: AppSizes.xl),
          ElevatedButton.icon(
            onPressed: () => context.go('/pets/add'),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Pet'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
