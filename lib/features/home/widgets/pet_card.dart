import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/pet_model.dart';
import '../../pets/widgets/pet_avatar_widget.dart';

class PetCard extends StatelessWidget {
  final PetModel pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/pets/${pet.id}'),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PetAvatarWidget(
                pet: pet,
                size: 80,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                pet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                pet.breed,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.formatAge(pet.birthdate),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
