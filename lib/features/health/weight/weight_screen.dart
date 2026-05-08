import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/pets_provider.dart';
import '../../../providers/pawpoints_provider.dart';
import 'weight_chart_widget.dart';

class WeightScreen extends ConsumerWidget {
  final String petId;

  const WeightScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(weightRecordsProvider(petId));
    final pets = ref.watch(petsProvider);
    final pet = pets.firstWhere((p) => p.id == petId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Peso - ${pet.name}'),
        backgroundColor: const Color(0xFF2ECC71),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/$petId'),
        ),
      ),
      body: Column(
        children: [
          // Current weight card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            color: const Color(0xFF2ECC71),
            child: Column(
              children: [
                const Text(
                  'Peso Atual',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '${pet.weight} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (records.length >= 2) ...[
                  const SizedBox(height: 4),
                  Builder(builder: (context) {
                    final last = records[records.length - 1].weight;
                    final prev = records[records.length - 2].weight;
                    final diff = last - prev;
                    final isGain = diff > 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isGain ? Icons.trending_up : Icons.trending_down,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isGain ? '+' : ''}${diff.toStringAsFixed(1)} kg desde o último registro',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    );
                  }),
                ],
              ],
            ),
          ),

          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monitor_weight, size: 64, color: AppColors.primary.withOpacity(0.3)),
                        const SizedBox(height: AppSizes.md),
                        const Text('Nenhum registro de peso ainda', style: TextStyle(color: AppColors.textLight)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (records.length >= 2) ...[
                          const Text(
                            'Evolução do Peso',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          WeightChartWidget(records: records),
                          const SizedBox(height: AppSizes.lg),
                        ],
                        const Text(
                          'Histórico',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        ...records.reversed.map((record) => Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.sm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2ECC71).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: const Icon(Icons.monitor_weight, color: Color(0xFF2ECC71)),
                            ),
                            title: Text(
                              '${record.weight} kg',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(AppDateUtils.formatDate(record.recordDate)),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'delete') {
                                  ref.read(weightRecordsProvider(petId).notifier)
                                      .deleteWeightRecord(record.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWeightDialog(context, ref),
        backgroundColor: const Color(0xFF2ECC71),
        icon: const Icon(Icons.add),
        label: const Text('Registrar Peso'),
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar Peso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                suffixText: 'kg',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ganhe +10 PawPoints pelo registro mensal!',
              style: TextStyle(fontSize: 12, color: AppColors.success),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text.replaceAll(',', '.'));
              if (weight != null && weight > 0) {
                await ref.read(weightRecordsProvider(petId).notifier).addWeightRecord(
                  weight: weight,
                );
                await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.weightUpdated);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Peso registrado! +10 PawPoints'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
