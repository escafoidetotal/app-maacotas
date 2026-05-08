import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/deworming_model.dart';
import '../../../providers/pets_provider.dart';

class DewormingScreen extends ConsumerWidget {
  final String petId;

  const DewormingScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dewormings = ref.watch(dewormingProvider(petId));
    final pets = ref.watch(petsProvider);
    final pet = pets.firstWhere((p) => p.id == petId);

    final internal = dewormings.where((d) => d.type == 'internal').toList();
    final external = dewormings.where((d) => d.type == 'external').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Vermifugação - ${pet.name}'),
          backgroundColor: const Color(0xFFE67E22),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/pets/$petId'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/pets/$petId/deworming/add'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Interna'),
              Tab(text: 'Externa'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _DewormingList(
              dewormings: internal,
              type: 'internal',
              petId: petId,
            ),
            _DewormingList(
              dewormings: external,
              type: 'external',
              petId: petId,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/pets/$petId/deworming/add'),
          backgroundColor: const Color(0xFFE67E22),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar'),
        ),
      ),
    );
  }
}

class _DewormingList extends ConsumerWidget {
  final List<DewormingModel> dewormings;
  final String type;
  final String petId;

  const _DewormingList({
    required this.dewormings,
    required this.type,
    required this.petId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (dewormings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pest_control,
              size: 64,
              color: const Color(0xFFE67E22).withOpacity(0.3),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Nenhuma vermifugação ${type == 'internal' ? 'interna' : 'externa'} registrada',
              style: const TextStyle(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: dewormings.length,
      itemBuilder: (context, index) {
        final d = dewormings[index];
        final isOverdue = d.nextApplicationDate != null &&
            AppDateUtils.isOverdue(d.nextApplicationDate!);

        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            side: BorderSide(
              color: isOverdue ? AppColors.error : Colors.transparent,
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
                        color: const Color(0xFFE67E22).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Icon(Icons.pest_control, color: Color(0xFFE67E22)),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        d.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'delete') {
                          ref.read(dewormingProvider(petId).notifier).deleteDeworming(d.id);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Aplicado em: ${AppDateUtils.formatDate(d.applicationDate)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                    ),
                  ],
                ),
                if (d.nextApplicationDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isOverdue ? Icons.warning : Icons.schedule,
                        color: isOverdue ? AppColors.error : AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Próxima: ${AppDateUtils.formatDate(d.nextApplicationDate!)} (${AppDateUtils.timeUntil(d.nextApplicationDate!)})',
                        style: TextStyle(
                          fontSize: 13,
                          color: isOverdue ? AppColors.error : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
                if (d.notes != null && d.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    d.notes!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
