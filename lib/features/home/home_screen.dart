import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/pets_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/pawpoints_provider.dart';
import '../../services/hive_service.dart';
import '../gamification/widgets/points_badge.dart';
import 'widgets/pet_card.dart';
import 'widgets/quick_actions_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider);
    final user = ref.watch(userProvider);
    final points = ref.watch(pawPointsProvider);
    final upcomingAppointments = HiveService.getAllUpcomingAppointments();
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: false,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md, AppSizes.md, AppSizes.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                user?.name ?? 'Tutor',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.go('/shop'),
                            child: PointsBadge(points: points),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.md),

                  // Quick actions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Text(
                      'Acesso Rápido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  QuickActionsRow(petId: pets.isNotEmpty ? pets.first.id : null),

                  const SizedBox(height: AppSizes.lg),

                  // My pets section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Meus Pets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/pets'),
                          child: const Text(
                            'Ver todos',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  if (pets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: _EmptyPetsCard(),
                    )
                  else
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                        itemCount: pets.length + 1,
                        itemBuilder: (context, index) {
                          if (index == pets.length) {
                            return _AddPetButton();
                          }
                          return PetCard(pet: pets[index]);
                        },
                      ),
                    ),

                  const SizedBox(height: AppSizes.lg),

                  // Upcoming events
                  if (upcomingAppointments.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: Text(
                        'Próximos Compromissos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    ...upcomingAppointments.take(3).map((apt) {
                      final pet = HiveService.pets.get(apt.petId);
                      return _AppointmentCard(
                        petName: pet?.name ?? 'Pet',
                        vetName: apt.vetName,
                        date: apt.appointmentDate,
                        clinic: apt.clinic,
                      );
                    }),
                    const SizedBox(height: AppSizes.md),
                  ],

                  // Streak card
                  _buildStreakCard(ref),

                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(WidgetRef ref) {
    final streak = ref.watch(currentStreakProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE66D), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 36)),
            const SizedBox(width: AppSizes.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sequência de Passeios',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$streak ${streak == 1 ? 'dia' : 'dias'} consecutivos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                const SizedBox(height: 4),
                Text(
                  streak >= 7 ? 'Incrível!' : '${7 - streak % 7} p/ bônus',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia,';
    if (hour < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }
}

class _EmptyPetsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/pets/add'),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.pets, size: 48, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Adicione seu primeiro pet!',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
          ],
        ),
      ),
    );
  }
}

class _AddPetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/pets/add'),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            const Text(
              'Adicionar',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String petName;
  final String vetName;
  final DateTime date;
  final String? clinic;

  const _AppointmentCard({
    required this.petName,
    required this.vetName,
    required this.date,
    this.clinic,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy - HH:mm');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.local_hospital, color: Color(0xFFE74C3C)),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$petName - $vetName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                if (clinic != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    clinic!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  formatter.format(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
