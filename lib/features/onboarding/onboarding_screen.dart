import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Bem-vindo ao MaaCOTAS!',
      description: 'Gerencie a saúde e felicidade dos seus pets em um só lugar, com carinho e praticidade.',
      emoji: '🐾',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      title: 'Saúde em Dia',
      description: 'Acompanhe vacinas, vermifugação, medicamentos e consultas veterinárias de todos os seus pets.',
      emoji: '💉',
      color: AppColors.secondary,
    ),
    _OnboardingPage(
      title: 'Passeios e Rotina',
      description: 'Registre os passeios diários, mantenha uma rotina saudável e receba lembretes importantes.',
      emoji: '🦮',
      color: const Color(0xFF9B59B6),
    ),
    _OnboardingPage(
      title: 'Ganhe PawPoints!',
      description: 'Cuide dos seus pets e ganhe pontos para personalizar avatares, comprar acessórios e temas exclusivos.',
      emoji: '⭐',
      color: const Color(0xFFD4A017),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      context.go('/home');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Pular',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Começar' : 'Próximo',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final String emoji;
  final Color color;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });
}
