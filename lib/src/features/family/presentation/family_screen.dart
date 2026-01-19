/// Family Screen - Main entry point
/// 
/// Clean, focused screen that composes child widgets.
/// All sub-widgets are in the widgets/ folder.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../data/family_repository.dart';
import 'widgets/widgets.dart';

/// Main Family Screen
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(currentFamilyIdProvider);

    // Show loading while family ID is being fetched
    if (familyId == null) {
      return const Scaffold(
        body: AppLoading(message: 'Aile bilgisi yükleniyor...'),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context, ref),
        body: const TabBarView(
          children: [
            FamilyTasksTab(),
            FamilyWallTab(),
          ],
        ),
        floatingActionButton: _buildFab(context, ref),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Ailem'),
      backgroundColor: AppColors.familyAccent,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_alt_1),
          tooltip: 'Aileye Davet Et',
          onPressed: () => showInviteDialog(context, ref),
        ),
      ],
      bottom: const TabBar(
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(icon: Icon(Icons.check_circle_outline), text: 'Görevler'),
          Tab(icon: Icon(Icons.note_alt_outlined), text: 'Pano'),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (ctx) => FloatingActionButton(
        backgroundColor: AppColors.familyAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          final tabIndex = DefaultTabController.of(ctx).index;
          if (tabIndex == 0) {
            showAddTaskDialog(context, ref);
          } else {
            showAddNoteDialog(context, ref);
          }
        },
      ),
    );
  }
}