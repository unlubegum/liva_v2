import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/core/config/supabase_config.dart';
import 'src/core/data/data.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/providers/onboarding_provider.dart';
import 'src/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Initialize PowerSync Database
  final db = await AppDatabase.initialize();

  // Listen to auth state changes and connect/disconnect PowerSync
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      await db.connect();
    } else if (event == AuthChangeEvent.signedOut) {
      await db.disconnect();
      await db.deleteLocalData();
    }
  });

  // Initial connection if already logged in
  if (Supabase.instance.client.auth.currentSession != null) {
    await db.connect();
  }
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const LivaApp(),
    ),
  );
}

/// Main Application Widget
class LivaApp extends ConsumerWidget {
  const LivaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Liva',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
