import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'scaffold_with_bottom_nav.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/hub/presentation/hub_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
// Module screens
import '../features/budget/presentation/budget_screen.dart';
import '../features/travel/presentation/travel_screen.dart';
import '../features/travel/presentation/trip_detail_screen.dart';
import '../features/fitness/presentation/fitness_screen.dart';
import '../features/family/presentation/family_screen.dart';
import '../features/family/presentation/family_setup_screen.dart';
import '../features/home_manager/presentation/home_manager_screen.dart';
import '../features/pets/presentation/pets_screen.dart';
import '../features/pets/presentation/ai_trainer_screen.dart';
import '../features/pets/presentation/food_analysis_screen.dart';
import '../features/pets/presentation/add_pet_screen.dart';
import '../features/car/presentation/car_screen.dart';
import '../features/podcast/presentation/podcast_screen.dart';
import '../features/cycle/presentation/cycle_screen.dart';
import '../features/pregnancy/presentation/pregnancy_screen.dart';
import '../features/fashion/presentation/fashion_screen.dart';



/// Refresh notifier for auth state changes
class AuthRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

/// Global refresh notifier provider
final authRefreshProvider = Provider<AuthRefreshNotifier>((ref) {
  return AuthRefreshNotifier();
});

/// GoRouter provider with redirect logic
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(authRefreshProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final path = state.uri.path;
      final isLogin = path == '/login';
      final isFamilySetup = path == '/family-setup';

      // 1. Giriş yapmamışsa -> Login
      if (!isLoggedIn && !isLogin) {
        return '/login';
      }

      // 2. Giriş yapmışsa ve login'deyse -> family_id kontrol et
      if (isLoggedIn && isLogin) {
        return '/home'; // HomeScreen içinde family_id kontrolü yapılacak
      }

      // 3. Giriş yapmışsa ve family-setup'ta değilse -> family_id kontrol et
      if (isLoggedIn && !isFamilySetup && !isLogin) {
        try {
          final userId = session.user.id;
          final profile = await Supabase.instance.client
              .from('profiles')
              .select('family_id')
              .eq('id', userId)
              .maybeSingle();
          
          if (profile == null || profile['family_id'] == null) {
            return '/family-setup';
          }
        } catch (_) {
          // Hata durumunda devam et
        }
      }

      return null; // No redirect
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      
      // Family Setup
      GoRoute(
        path: '/family-setup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FamilySetupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Main app with ShellRoute (4 tabs)
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          // Tab 1: Home
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          // Tab 2: Calendar
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          // Tab 3: Hub (Apps)
          GoRoute(
            path: '/hub',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HubScreen(),
            ),
          ),
          // Tab 4: Settings
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // Module detail routes (outside shell for full-screen experience)
      GoRoute(
        path: '/budget',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const BudgetScreen(),
        ),
      ),
      GoRoute(
        path: '/travel',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TravelScreen(),
        ),
      ),
      GoRoute(
        path: '/travel-detail',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: TripDetailScreen(tripId: state.extra as String),
        ),
      ),
      GoRoute(
        path: '/fitness',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FitnessScreen(),
        ),
      ),
      GoRoute(
        path: '/family',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FamilyScreen(),
        ),
      ),
      // Placeholder routes for new modules
      GoRoute(
        path: '/car',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CarScreen(),
        ),
      ),
      GoRoute(
        path: '/pets',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PetsScreen(),
        ),
      ),
      GoRoute(
        path: '/pet-trainer',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AITrainerScreen(),
        ),
      ),
      GoRoute(
        path: '/pet-food',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FoodAnalysisScreen(),
        ),
      ),
      GoRoute(
        path: '/pet-add',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AddPetScreen(),
        ),
      ),
      GoRoute(
        path: '/podcast',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PodcastScreen(),
        ),
      ),
      GoRoute(
        path: '/home-module',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeManagerScreen(),
        ),
      ),
      GoRoute(
        path: '/cycle',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CycleScreen(),
        ),
      ),
      GoRoute(
        path: '/pregnancy',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PregnancyScreen(),
        ),
      ),
      GoRoute(
        path: '/fashion',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FashionScreen(),
        ),
      ),

    ],
  );
});

