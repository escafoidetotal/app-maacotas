import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/supabase_service.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/pets/pet_list_screen.dart';
import '../../features/pets/pet_detail_screen.dart';
import '../../features/pets/add_pet_screen.dart';
import '../../features/health/vaccines/vaccines_screen.dart';
import '../../features/health/vaccines/add_vaccine_screen.dart';
import '../../features/health/weight/weight_screen.dart';
import '../../features/health/deworming/deworming_screen.dart';
import '../../features/health/deworming/add_deworming_screen.dart';
import '../../features/health/medications/medications_screen.dart';
import '../../features/health/medications/add_medication_screen.dart';
import '../../features/walks/walks_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/gamification/pawpoints_screen.dart';
import '../../features/gamification/shop_screen.dart';
import '../../features/gamification/avatar_customizer_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/vets/vet_locator_screen.dart';
import '../../features/health/pdf_export_screen.dart';
import '../../features/feeding/feeding_screen.dart';
import '../../features/pets/breed_info_screen.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final String currentLocation;

  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _routes = ['/home', '/pets', '/calendar', '/shop', '/profile'];

  int get _currentIndex {
    for (int i = 0; i < _routes.length; i++) {
      if (widget.currentLocation.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => context.go(_routes[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Tienda',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';
      final isOnboarding = path == '/onboarding';

      // Check onboarding first
      if (!isOnboarding && !isAuthRoute) {
        final prefs = await SharedPreferences.getInstance();
        final onboardingDone = prefs.getBool('onboarding_done') ?? false;
        if (!onboardingDone) return '/onboarding';
      }

      // Auth guard: redirect to login if not logged in
      if (!isAuthRoute && !isOnboarding && !SupabaseService.isLoggedIn) {
        return '/login';
      }

      // If already logged in and going to auth routes, redirect to home
      if (isAuthRoute && SupabaseService.isLoggedIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentLocation: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/pets',
            builder: (context, state) => const PetListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddPetScreen(),
              ),
              GoRoute(
                path: ':petId',
                builder: (context, state) {
                  final petId = state.pathParameters['petId']!;
                  return PetDetailScreen(petId: petId);
                },
                routes: [
                  GoRoute(
                    path: 'vaccines',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return VaccinesScreen(petId: petId);
                    },
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          return AddVaccineScreen(petId: petId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'weight',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return WeightScreen(petId: petId);
                    },
                  ),
                  GoRoute(
                    path: 'deworming',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return DewormingScreen(petId: petId);
                    },
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          return AddDewormingScreen(petId: petId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'medications',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return MedicationsScreen(petId: petId);
                    },
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) {
                          final petId = state.pathParameters['petId']!;
                          return AddMedicationScreen(petId: petId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'walks',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return WalksScreen(petId: petId);
                    },
                  ),
                  GoRoute(
                    path: 'avatar',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return AvatarCustomizerScreen(petId: petId);
                    },
                  ),
                  GoRoute(
                    path: 'feeding',
                    builder: (context, state) {
                      final petId = state.pathParameters['petId']!;
                      return FeedingScreen(petId: petId);
                    },
                  ),
                  GoRoute(
                    path: 'breed-info',
                    builder: (context, state) {
                      final breed = state.uri.queryParameters['breed'] ?? '';
                      return BreedInfoScreen(breed: breed);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/pdf-export',
            builder: (context, state) => const PdfExportScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const PawPointsScreen(),
            routes: [
              GoRoute(
                path: 'store',
                builder: (context, state) => const ShopScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/vets',
            builder: (context, state) => const VetLocatorScreen(),
          ),
        ],
      ),
    ],
  );
}

final appRouter = buildAppRouter();
