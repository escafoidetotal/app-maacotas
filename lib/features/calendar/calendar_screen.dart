import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/vet_appointment_model.dart';
import '../../providers/pets_provider.dart';
import '../../services/hive_service.dart';

const _uuid = Uuid();

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petsProvider);
    final allAppointments = HiveService.getAllUpcomingAppointments();
    final allPastAppointments = HiveService.vetAppointments.values
        .where((a) => a.appointmentDate.isBefore(DateTime.now()) || a.isCompleted)
        .toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendário'),
        backgroundColor: const Color(0xFF9B59B6),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini calendar header
            Container(
              color: const Color(0xFF9B59B6),
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () => setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                        }),
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'pt_BR').format(_focusedMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        onPressed: () => setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                        }),
                      ),
                    ],
                  ),
                  _buildMiniCalendar(allAppointments),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upcoming appointments
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Próximas Consultas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      if (pets.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _showAddAppointmentDialog(context, pets),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Adicionar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),

                  if (allAppointments.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.event_available, size: 48, color: const Color(0xFF9B59B6).withOpacity(0.3)),
                          const SizedBox(height: AppSizes.sm),
                          const Text('Nenhuma consulta agendada', style: TextStyle(color: AppColors.textLight)),
                          if (pets.isNotEmpty) ...[
                            const SizedBox(height: AppSizes.md),
                            ElevatedButton.icon(
                              onPressed: () => _showAddAppointmentDialog(context, pets),
                              icon: const Icon(Icons.add),
                              label: const Text('Agendar Consulta'),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9B59B6)),
                            ),
                          ] else ...[
                            const SizedBox(height: AppSizes.sm),
                            TextButton(
                              onPressed: () => context.go('/pets/add'),
                              child: const Text('Adicione um pet primeiro'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    ...allAppointments.map((apt) => _AppointmentCard(
                      appointment: apt,
                      petName: HiveService.pets.get(apt.petId)?.name ?? 'Pet',
                      onDelete: () => HiveService.deleteVetAppointment(apt.id),
                      onComplete: () async {
                        final updated = apt.copyWith(isCompleted: true);
                        await HiveService.saveVetAppointment(updated);
                        if (mounted) setState(() {});
                      },
                    )),
                  ],

                  if (allPastAppointments.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    const Text(
                      'Histórico',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textLight),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    ...allPastAppointments.take(5).map((apt) => _AppointmentCard(
                      appointment: apt,
                      petName: HiveService.pets.get(apt.petId)?.name ?? 'Pet',
                      isPast: true,
                      onDelete: () => HiveService.deleteVetAppointment(apt.id),
                      onComplete: null,
                    )),
                  ],

                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: pets.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddAppointmentDialog(context, pets),
              backgroundColor: const Color(0xFF9B59B6),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildMiniCalendar(List<VetAppointmentModel> appointments) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startingWeekday = firstDay.weekday % 7; // 0 = Sunday

    final appointmentDays = appointments
        .where((a) => a.appointmentDate.year == _focusedMonth.year &&
            a.appointmentDate.month == _focusedMonth.month)
        .map((a) => a.appointmentDate.day)
        .toSet();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
              .map((d) => SizedBox(
                    width: 32,
                    child: Text(d, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: startingWeekday + lastDay.day,
          itemBuilder: (context, index) {
            if (index < startingWeekday) return const SizedBox.shrink();
            final day = index - startingWeekday + 1;
            final isToday = DateTime.now().year == _focusedMonth.year &&
                DateTime.now().month == _focusedMonth.month &&
                DateTime.now().day == day;
            final hasAppointment = appointmentDays.contains(day);

            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white
                    : hasAppointment
                        ? Colors.white.withOpacity(0.3)
                        : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      color: isToday ? const Color(0xFF9B59B6) : Colors.white,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  if (hasAppointment && !isToday)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddAppointmentDialog(BuildContext context, List pets) {
    String selectedPetId = pets.first.id;
    final vetController = TextEditingController();
    final clinicController = TextEditingController();
    final reasonController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nova Consulta Veterinária'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedPetId,
                  decoration: const InputDecoration(labelText: 'Pet'),
                  items: pets.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedPetId = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vetController,
                  decoration: const InputDecoration(labelText: 'Veterinário *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clinicController,
                  decoration: const InputDecoration(labelText: 'Clínica'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Motivo'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF9B59B6)),
                  title: Text(DateFormat('dd/MM/yyyy HH:mm').format(selectedDate)),
                  subtitle: const Text('Data e hora'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null && ctx.mounted) {
                      final time = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (vetController.text.trim().isEmpty) return;
                final apt = VetAppointmentModel(
                  id: _uuid.v4(),
                  petId: selectedPetId,
                  vetName: vetController.text.trim(),
                  clinic: clinicController.text.trim().isNotEmpty ? clinicController.text.trim() : null,
                  appointmentDate: selectedDate,
                  reason: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : null,
                );
                await HiveService.saveVetAppointment(apt);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (mounted) setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9B59B6)),
              child: const Text('Agendar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final VetAppointmentModel appointment;
  final String petName;
  final bool isPast;
  final VoidCallback onDelete;
  final VoidCallback? onComplete;

  const _AppointmentCard({
    required this.appointment,
    required this.petName,
    this.isPast = false,
    required this.onDelete,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.7 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: BorderSide(
            color: appointment.isCompleted ? AppColors.success : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (appointment.isCompleted ? AppColors.success : const Color(0xFF9B59B6)).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  appointment.isCompleted ? Icons.check_circle : Icons.local_hospital,
                  color: appointment.isCompleted ? AppColors.success : const Color(0xFF9B59B6),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$petName - Dr. ${appointment.vetName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (appointment.clinic != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        appointment.clinic!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                    if (appointment.reason != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        appointment.reason!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy - HH:mm').format(appointment.appointmentDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9B59B6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (onComplete != null && !appointment.isCompleted)
                    IconButton(
                      icon: const Icon(Icons.check, color: AppColors.success, size: 20),
                      onPressed: onComplete,
                      tooltip: 'Marcar como feito',
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Excluir',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
