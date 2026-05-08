import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/pawpoints_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/admob_service.dart';
import 'widgets/points_badge.dart';
import 'widgets/streak_calendar.dart';

class PawPointsScreen extends ConsumerWidget {
  const PawPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(pawPointsProvider);
    final streak = ref.watch(currentStreakProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PawPoints'),
        backgroundColor: const Color(0xFFD4A017),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            onPressed: () => context.go('/shop/store'),
            tooltip: 'Ir para a Loja',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD4A017), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '$points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'PawPoints',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/shop/store'),
                    icon: const Icon(Icons.storefront, color: Color(0xFFD4A017)),
                    label: const Text(
                      'Ir para a Loja',
                      style: TextStyle(color: Color(0xFFD4A017), fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(180, 44),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak calendar
                  const StreakCalendar(),
                  const SizedBox(height: AppSizes.lg),

                  // Streak card
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sequência de Passeios',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$streak ${streak == 1 ? 'dia' : 'dias'} consecutivos',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                streak >= 7
                                    ? 'Bônus ganho! Continue assim!'
                                    : 'Faltam ${7 - streak % 7} dia(s) para o bônus de +50 pts',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // How to earn
                  const Text(
                    'Como ganhar PawPoints',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  _EarnCard(
                    icon: Icons.directions_walk,
                    color: AppColors.primary,
                    title: 'Passeio Diário',
                    description: 'Registre um passeio por dia',
                    points: '+10 pts',
                  ),
                  _EarnCard(
                    icon: Icons.vaccines,
                    color: const Color(0xFF3498DB),
                    title: 'Vacina Atualizada',
                    description: 'Registre uma nova vacina',
                    points: '+25 pts',
                  ),
                  _EarnCard(
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFE74C3C),
                    title: 'Sequência de 7 Dias',
                    description: 'Passeie 7 dias consecutivos',
                    points: '+50 pts',
                  ),
                  _EarnCard(
                    icon: Icons.monitor_weight,
                    color: const Color(0xFF2ECC71),
                    title: 'Peso Mensal',
                    description: 'Registre o peso uma vez por mês',
                    points: '+10 pts',
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Watch ad for points
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_filled, color: AppColors.secondary, size: 36),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assistir Anúncio',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const Text(
                                'Assista um vídeo e ganhe pontos',
                                style: TextStyle(fontSize: 12, color: AppColors.textLight),
                              ),
                              const Text(
                                '+15 PawPoints',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _watchAd(context, ref),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                          child: const Text('Assistir'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Spending section
                  const Text(
                    'O que você pode comprar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  _SpendCard(icon: Icons.celebration, label: 'Chapéus', from: 50),
                  _SpendCard(icon: Icons.favorite, label: 'Coleiras', from: 40),
                  _SpendCard(icon: Icons.checkroom, label: 'Fantasias', from: 100),
                  _SpendCard(icon: Icons.palette, label: 'Temas', from: 300),
                  _SpendCard(icon: Icons.pets, label: 'Skins', from: 250),

                  const SizedBox(height: AppSizes.md),

                  OutlinedButton.icon(
                    onPressed: () => context.go('/shop/store'),
                    icon: const Icon(Icons.storefront),
                    label: const Text('Ver Loja Completa'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _watchAd(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carregando anúncio...')),
    );

    final success = await AdmobService().showRewardedAd(
      onRewarded: (points) async {
        await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.adWatched);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('+15 PawPoints ganhos!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );

    if (!success && context.mounted) {
      // In dev mode, award points anyway
      await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.adWatched);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+15 PawPoints ganhos!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

class _EarnCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String points;

  const _EarnCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: Text(
              points,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4A017),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int from;

  const _SpendCard({required this.icon, required this.label, required this.from});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textLight),
          const SizedBox(width: AppSizes.sm),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
          const Spacer(),
          Text(
            'A partir de $from pts',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
