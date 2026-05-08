import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/pets_provider.dart';
import 'widgets/pet_avatar_widget.dart';

class PetDetailScreen extends ConsumerWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider);
    final pet = pets.firstWhere(
      (p) => p.id == petId,
      orElse: () => pets.isNotEmpty ? pets.first : throw Exception('Pet not found'),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/pets'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Edit functionality
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Excluir pet'),
                        content: Text('Deseja excluir ${pet.name}? Esta ação não pode ser desfeita.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(petsProvider.notifier).deletePet(petId);
                      if (context.mounted) context.go('/pets');
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text('Excluir pet')),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () => context.go('/pets/$petId/avatar'),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          PetAvatarWidget(pet: pet, size: 100),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      pet.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pet.breed,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Idade',
                          value: AppDateUtils.formatAge(pet.birthdate),
                          icon: Icons.cake,
                          color: const Color(0xFF9B59B6),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _InfoCard(
                          label: 'Peso',
                          value: '${pet.weight} kg',
                          icon: Icons.monitor_weight,
                          color: const Color(0xFF2ECC71),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _InfoCard(
                          label: 'Sexo',
                          value: pet.gender == 'male' ? 'Macho' : 'Fêmea',
                          icon: pet.gender == 'male' ? Icons.male : Icons.female,
                          color: pet.gender == 'male' ? Colors.blue : Colors.pink,
                        ),
                      ),
                    ],
                  ),

                  if (pet.microchipNumber != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    _DetailRow(
                      label: 'Microchip',
                      value: pet.microchipNumber!,
                      icon: Icons.qr_code,
                    ),
                  ],
                  if (pet.insuranceInfo != null) ...[
                    const SizedBox(height: AppSizes.xs),
                    _DetailRow(
                      label: 'Seguro',
                      value: pet.insuranceInfo!,
                      icon: Icons.shield,
                    ),
                  ],

                  const SizedBox(height: AppSizes.lg),

                  // Health sections
                  const Text(
                    'Saúde',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  _HealthMenuCard(
                    title: 'Vacinas',
                    subtitle: 'Calendário de vacinação',
                    icon: Icons.vaccines,
                    color: const Color(0xFF3498DB),
                    onTap: () => context.go('/pets/$petId/vaccines'),
                  ),
                  _HealthMenuCard(
                    title: 'Peso',
                    subtitle: 'Histórico e gráfico de peso',
                    icon: Icons.monitor_weight,
                    color: const Color(0xFF2ECC71),
                    onTap: () => context.go('/pets/$petId/weight'),
                  ),
                  _HealthMenuCard(
                    title: 'Vermifugação',
                    subtitle: 'Controle interno e externo',
                    icon: Icons.pest_control,
                    color: const Color(0xFFE67E22),
                    onTap: () => context.go('/pets/$petId/deworming'),
                  ),
                  _HealthMenuCard(
                    title: 'Medicamentos',
                    subtitle: 'Lembretes de medicação',
                    icon: Icons.medication,
                    color: const Color(0xFFE74C3C),
                    onTap: () => context.go('/pets/$petId/medications'),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  const Text(
                    'Atividades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  _HealthMenuCard(
                    title: 'Passeios',
                    subtitle: 'Registrar e agendar passeios',
                    icon: Icons.directions_walk,
                    color: AppColors.primary,
                    onTap: () => context.go('/pets/$petId/walks'),
                  ),
                  _HealthMenuCard(
                    title: 'Alimentación',
                    subtitle: 'Plan y horario de comidas',
                    icon: Icons.food_bank,
                    color: const Color(0xFF00BCD4),
                    onTap: () => context.go('/pets/$petId/feeding'),
                  ),
                  _HealthMenuCard(
                    title: 'Personalizar Avatar',
                    subtitle: 'Acessórios e skins',
                    icon: Icons.color_lens,
                    color: const Color(0xFF9B59B6),
                    onTap: () => context.go('/pets/$petId/avatar'),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  const Text(
                    'Información',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  _HealthMenuCard(
                    title: 'Info de raza',
                    subtitle: 'Características, salud y cuidados',
                    icon: Icons.info_outline,
                    color: const Color(0xFF00897B),
                    onTap: () => context.go(
                      '/pets/$petId/breed-info?breed=${Uri.encodeComponent(pet.breed)}',
                    ),
                  ),
                  _HealthMenuCard(
                    title: 'Exportar historial PDF',
                    subtitle: 'Genera un informe de salud',
                    icon: Icons.picture_as_pdf,
                    color: const Color(0xFFE53935),
                    onTap: () => context.go('/pdf-export'),
                  ),

                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textLight),
          const SizedBox(width: AppSizes.sm),
          Text(
            '$label: ',
            style: const TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HealthMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
