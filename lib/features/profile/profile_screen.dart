import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/user_provider.dart';
import '../../providers/pawpoints_provider.dart';
import '../../providers/pets_provider.dart';
import '../../services/admob_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final points = ref.watch(pawPointsProvider);
    final streak = ref.watch(currentStreakProvider);
    final pets = ref.watch(petsProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditNameDialog(context, ref, user.name),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickPhoto(context, ref),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          backgroundImage: user.photoPath != null
                              ? NetworkImage(user.photoPath!) as ImageProvider
                              : null,
                          child: user.photoPath == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.email != null) ...[
                    const SizedBox(height: 4),
                    Text(user.email!, style: const TextStyle(color: Colors.white70)),
                  ],
                ],
              ),
            ),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              color: Colors.white,
              child: Row(
                children: [
                  _StatItem(label: 'PawPoints', value: '$points', icon: '⭐'),
                  _VerticalDivider(),
                  _StatItem(label: 'Sequência', value: '$streak dias', icon: '🔥'),
                  _VerticalDivider(),
                  _StatItem(label: 'Pets', value: '${pets.length}', icon: '🐾'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu items
                  _SectionTitle('Conta'),
                  _MenuCard(
                    icon: Icons.person,
                    color: AppColors.primary,
                    title: 'Editar Nome',
                    subtitle: user.name,
                    onTap: () => _showEditNameDialog(context, ref, user.name),
                  ),
                  _MenuCard(
                    icon: Icons.email,
                    color: const Color(0xFF3498DB),
                    title: 'Email',
                    subtitle: user.email ?? 'Não definido',
                    onTap: () => _showEditEmailDialog(context, ref, user.email),
                  ),

                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('App'),

                  _MenuCard(
                    icon: Icons.notifications,
                    color: const Color(0xFFE67E22),
                    title: 'Notificações',
                    subtitle: 'Gerenciar alertas e lembretes',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configurações de notificação')),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.palette,
                    color: const Color(0xFF9B59B6),
                    title: 'Temas',
                    subtitle: 'Personalizar aparência do app',
                    onTap: () => context.go('/shop/store'),
                  ),

                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('Ganhar Pontos'),

                  _MenuCard(
                    icon: Icons.play_circle_filled,
                    color: AppColors.secondary,
                    title: 'Assistir Anúncio',
                    subtitle: '+15 PawPoints por vídeo assistido',
                    onTap: () => _watchAd(context, ref),
                  ),
                  _MenuCard(
                    icon: Icons.storefront,
                    color: const Color(0xFFD4A017),
                    title: 'Loja de PawPoints',
                    subtitle: 'Gastar pontos em itens especiais',
                    onTap: () => context.go('/shop/store'),
                  ),

                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('Sobre'),

                  _MenuCard(
                    icon: Icons.info,
                    color: AppColors.textLight,
                    title: 'Sobre o MaaCOTAS',
                    subtitle: 'Versão 1.0.0',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'MaaCOTAS',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2025 MaaCOTAS',
                        children: [
                          const Text('App para gerenciar a saúde e felicidade dos seus pets.'),
                        ],
                      );
                    },
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

  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await ref.read(userProvider.notifier).updatePhoto(image.path);
    }
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Seu nome'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref.read(userProvider.notifier).updateName(controller.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context, WidgetRef ref, String? currentEmail) {
    final controller = TextEditingController(text: currentEmail ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Email'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Seu email'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(userProvider.notifier).updateEmail(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _watchAd(BuildContext context, WidgetRef ref) async {
    final success = await AdmobService().showRewardedAd(
      onRewarded: (pts) async {
        await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.adWatched);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('+15 PawPoints ganhos!'), backgroundColor: AppColors.success),
          );
        }
      },
    );

    if (!success) {
      await ref.read(pawPointsProvider.notifier).earnPoints(PointsEvent.adWatched);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('+15 PawPoints ganhos!'), backgroundColor: AppColors.success),
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }
}
