import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/walk_model.dart';
import '../../providers/pets_provider.dart';
import '../../providers/pawpoints_provider.dart';

class WalksScreen extends ConsumerStatefulWidget {
  final String petId;

  const WalksScreen({super.key, required this.petId});

  @override
  ConsumerState<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends ConsumerState<WalksScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final walks = ref.watch(walksProvider(widget.petId));
    final pets = ref.watch(petsProvider);
    final pet = pets.firstWhere((p) => p.id == widget.petId);

    final completedWalks = walks.where((w) => w.isCompleted).toList();
    final scheduledWalks = walks.where((w) => w.isScheduled && !w.isCompleted).toList();

    final totalWalks = completedWalks.length;
    final totalMinutes = completedWalks.fold<int>(0, (sum, w) => sum + w.durationMinutes);
    final totalKm = completedWalks.fold<double>(0, (sum, w) => sum + (w.distanceKm ?? 0));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Passeios - ${pet.name}'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/${widget.petId}'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats header
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.lg),
              child: Row(
                children: [
                  _StatCard(label: 'Total', value: '$totalWalks passeios'),
                  const SizedBox(width: AppSizes.sm),
                  _StatCard(label: 'Tempo', value: '${totalMinutes} min'),
                  const SizedBox(width: AppSizes.sm),
                  _StatCard(label: 'Distância', value: '${totalKm.toStringAsFixed(1)} km'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Log walk button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Row(
                      children: [
                        const Text('🐕', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Registrar Passeio',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const Text(
                                'Ganhe +10 PawPoints hoje!',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showLogWalkDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Registrar'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Schedule walk
                  OutlinedButton.icon(
                    onPressed: () => _showScheduleDialog(context),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Agendar Passeio'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  if (scheduledWalks.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    const Text(
                      'Agendados',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    ...scheduledWalks.map((walk) => _WalkCard(
                      walk: walk,
                      petId: widget.petId,
                      onComplete: () {
                        ref.read(walksProvider(widget.petId).notifier).completeWalk(walk.id);
                      },
                      onDelete: () {
                        ref.read(walksProvider(widget.petId).notifier).deleteWalk(walk.id);
                      },
                    )),
                  ],

                  if (completedWalks.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    const Text(
                      'Histórico',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    ...completedWalks.take(10).map((walk) => _WalkCard(
                      walk: walk,
                      petId: widget.petId,
                      onComplete: null,
                      onDelete: () {
                        ref.read(walksProvider(widget.petId).notifier).deleteWalk(walk.id);
                      },
                    )),
                  ],

                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogWalkDialog(BuildContext context) {
    final durationController = TextEditingController();
    final distanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Text('🐕 '),
            Text('Registrar Passeio'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duração (minutos) *',
                prefixIcon: Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Distância (km)',
                prefixIcon: Icon(Icons.straighten),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '+10 PawPoints pelo passeio de hoje!',
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
              final duration = int.tryParse(durationController.text);
              if (duration == null || duration <= 0) return;

              final distance = double.tryParse(distanceController.text.replaceAll(',', '.'));

              await ref.read(walksProvider(widget.petId).notifier).logWalk(
                durationMinutes: duration,
                distanceKm: distance,
              );

              final earned = await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.walkLogged);

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(earned
                        ? 'Passeio registrado! +10 PawPoints'
                        : 'Passeio registrado! (pontos já ganhos hoje)'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    final durationController = TextEditingController();
    DateTime scheduledDate = DateTime.now().add(const Duration(hours: 2));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Agendar Passeio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: Text(DateFormat('dd/MM/yyyy HH:mm').format(scheduledDate)),
                subtitle: const Text('Data e hora'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: scheduledDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null && ctx.mounted) {
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(scheduledDate),
                    );
                    if (time != null) {
                      setDialogState(() {
                        scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  }
                },
              ),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duração planejada (minutos)',
                ),
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
                final duration = int.tryParse(durationController.text) ?? 30;
                await ref.read(walksProvider(widget.petId).notifier).scheduleWalk(
                  walkDate: scheduledDate,
                  durationMinutes: duration,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passeio agendado!')),
                  );
                }
              },
              child: const Text('Agendar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkCard extends StatelessWidget {
  final WalkModel walk;
  final String petId;
  final VoidCallback? onComplete;
  final VoidCallback onDelete;

  const _WalkCard({
    required this.walk,
    required this.petId,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isScheduled = walk.isScheduled && !walk.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isScheduled ? AppColors.warning : AppColors.primary).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                isScheduled ? Icons.schedule : Icons.directions_walk,
                color: isScheduled ? AppColors.warning : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(walk.walkDate),
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  Text(
                    '${walk.durationMinutes} min${walk.distanceKm != null ? ' · ${walk.distanceKm!.toStringAsFixed(1)} km' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            if (isScheduled && onComplete != null) ...[
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                onPressed: onComplete,
                tooltip: 'Marcar como feito',
              ),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: onDelete,
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}
