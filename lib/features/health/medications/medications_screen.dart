import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/medication_model.dart';
import '../../../providers/pets_provider.dart';

class MedicationsScreen extends ConsumerWidget {
  final String petId;

  const MedicationsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationsProvider(petId));
    final pets = ref.watch(petsProvider);
    final pet = pets.firstWhere((p) => p.id == petId);

    final active = medications.where((m) => m.isActive).toList();
    final inactive = medications.where((m) => !m.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Medicamentos - ${pet.name}'),
        backgroundColor: const Color(0xFFE74C3C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/$petId'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/pets/$petId/medications/add'),
          ),
        ],
      ),
      body: medications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication, size: 64, color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: AppSizes.md),
                  const Text('Nenhum medicamento registrado', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                  const SizedBox(height: AppSizes.xl),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/pets/$petId/medications/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Medicamento'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                if (active.isNotEmpty) ...[
                  const Text(
                    'Ativos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...active.map((m) => _MedicationCard(
                    medication: m,
                    petId: petId,
                  )),
                ],
                if (inactive.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'Concluídos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textLight),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...inactive.map((m) => _MedicationCard(
                    medication: m,
                    petId: petId,
                    isInactive: true,
                  )),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/pets/$petId/medications/add'),
        backgroundColor: const Color(0xFFE74C3C),
        icon: const Icon(Icons.add),
        label: const Text('Medicamento'),
      ),
    );
  }
}

class _MedicationCard extends ConsumerWidget {
  final MedicationModel medication;
  final String petId;
  final bool isInactive;

  const _MedicationCard({
    required this.medication,
    required this.petId,
    this.isInactive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Opacity(
      opacity: isInactive ? 0.7 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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
                      color: const Color(0xFFE74C3C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Icon(Icons.medication, color: Color(0xFFE74C3C)),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${medication.dose} - ${medication.frequencyLabel}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: medication.isActive,
                    onChanged: (_) {
                      ref.read(medicationsProvider(petId).notifier).toggleActive(medication.id);
                    },
                    activeColor: const Color(0xFFE74C3C),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Icon(Icons.play_arrow, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Início: ${AppDateUtils.formatDate(medication.startDate)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                  ),
                  if (medication.endDate != null) ...[
                    const SizedBox(width: AppSizes.md),
                    Icon(Icons.stop, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      'Fim: ${AppDateUtils.formatDate(medication.endDate!)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                    ),
                  ],
                ],
              ),
              if (medication.notes != null && medication.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.xs),
                Text(medication.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
              const SizedBox(height: AppSizes.xs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(medicationsProvider(petId).notifier).deleteMedication(medication.id);
                  },
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                  label: const Text('Excluir', style: TextStyle(color: AppColors.error, fontSize: 12)),
                  style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
