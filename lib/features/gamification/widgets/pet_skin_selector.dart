import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../models/pet_model.dart';
import '../../pets/widgets/pet_avatar_widget.dart';

class PetSkinSelector extends StatelessWidget {
  final PetModel pet;
  final String? selectedBreed;
  final Function(String breed) onBreedSelected;

  const PetSkinSelector({
    super.key,
    required this.pet,
    required this.selectedBreed,
    required this.onBreedSelected,
  });

  static const List<Map<String, dynamic>> _availableBreeds = [
    {'id': 'labrador', 'name': 'Labrador', 'emoji': '🟡'},
    {'id': 'husky', 'name': 'Husky', 'emoji': '⚫'},
    {'id': 'poodle', 'name': 'Poodle', 'emoji': '⚪'},
    {'id': 'bulldog', 'name': 'Bulldog', 'emoji': '🟤'},
    {'id': 'german shepherd', 'name': 'Alemão', 'emoji': '🟫'},
    {'id': 'golden retriever', 'name': 'Golden', 'emoji': '🟠'},
    {'id': 'dachshund', 'name': 'Dachshund', 'emoji': '🔴'},
    {'id': 'pug', 'name': 'Pug', 'emoji': '🟤'},
    {'id': 'shih tzu', 'name': 'Shih Tzu', 'emoji': '🍦'},
    {'id': 'border collie', 'name': 'Collie', 'emoji': '🖤'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione a Skin do Pet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        const Text(
          'A skin muda a aparência visual do avatar',
          style: TextStyle(fontSize: 12, color: AppColors.textLight),
        ),
        const SizedBox(height: AppSizes.md),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableBreeds.length,
            itemBuilder: (context, index) {
              final breed = _availableBreeds[index];
              final isSelected = (selectedBreed ?? pet.breed).toLowerCase().contains(breed['id']);

              return GestureDetector(
                onTap: () => onBreedSelected(breed['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 90,
                  margin: const EdgeInsets.only(right: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary.withOpacity(0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _BreedPreviewAvatar(breedId: breed['id']),
                      const SizedBox(height: 4),
                      Text(
                        breed['name'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.secondary : AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BreedPreviewAvatar extends StatelessWidget {
  final String breedId;

  const _BreedPreviewAvatar({required this.breedId});

  @override
  Widget build(BuildContext context) {
    final skin = BreedSkins.getSkin(breedId);
    return SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(
        painter: PetFacePainter(skin: skin),
      ),
    );
  }
}
