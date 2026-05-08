import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/pets_provider.dart';

class VaccinesScreen extends ConsumerWidget {
  final String petId;

  const VaccinesScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccines = ref.watch(vaccinesProvider(petId));
    final pets = ref.watch(petsProvider);
    final pet = pets.firstWhere((p) => p.id == petId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Vacinas - ${pet.name}'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/$petId'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/pets/$petId/vaccines/add'),
          ),
        ],
      ),
      body: vaccines.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.vaccines, size: 64, color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: AppSizes.md),
                  const Text('Nenhuma vacina registrada', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                  const SizedBox(height: AppSizes.xl),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/pets/$petId/vaccines/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Vacina'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: vaccines.length,
              itemBuilder: (context, index) {
                final vaccine = vaccines[index];
                final isOverdue = vaccine.nextDoseDate != null &&
                    AppDateUtils.isOverdue(vaccine.nextDoseDate!);
                final isDueSoon = vaccine.nextDoseDate != null &&
                    !isOverdue &&
                    AppDateUtils.daysDifference(DateTime.now(), vaccine.nextDoseDate!) <= 30;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    side: BorderSide(
                      color: isOverdue
                          ? AppColors.error
                          : isDueSoon
                              ? AppColors.warning
                              : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3498DB).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: const Icon(Icons.vaccines, color: Color(0xFF3498DB), size: 22),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vaccine.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  if (vaccine.veterinarian != null)
                                    Text(
                                      'Dr. ${vaccine.veterinarian}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  ref.read(vaccinesProvider(petId).notifier).deleteVaccine(vaccine.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        const Divider(height: 1),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          children: [
                            _VaccineInfoItem(
                              label: 'Aplicada em',
                              value: AppDateUtils.formatDate(vaccine.vaccineDate),
                              icon: Icons.check_circle,
                              color: AppColors.success,
                            ),
                            if (vaccine.nextDoseDate != null) ...[
                              const SizedBox(width: AppSizes.lg),
                              _VaccineInfoItem(
                                label: 'Próxima dose',
                                value: AppDateUtils.formatDate(vaccine.nextDoseDate!),
                                icon: isOverdue
                                    ? Icons.warning
                                    : isDueSoon
                                        ? Icons.schedule
                                        : Icons.event,
                                color: isOverdue
                                    ? AppColors.error
                                    : isDueSoon
                                        ? AppColors.warning
                                        : AppColors.textLight,
                              ),
                            ],
                          ],
                        ),
                        if (vaccine.nextDoseDate != null) ...[
                          const SizedBox(height: AppSizes.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOverdue
                                  ? AppColors.error.withOpacity(0.1)
                                  : isDueSoon
                                      ? AppColors.warning.withOpacity(0.1)
                                      : AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: Text(
                              AppDateUtils.timeUntil(vaccine.nextDoseDate!),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isOverdue
                                    ? AppColors.error
                                    : isDueSoon
                                        ? AppColors.warning
                                        : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                        if (vaccine.notes != null && vaccine.notes!.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            vaccine.notes!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/pets/$petId/vaccines/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VaccineInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _VaccineInfoItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
