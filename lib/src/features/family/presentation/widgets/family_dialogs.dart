import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/family_repository.dart';
import '../../data/wall_repository.dart';
import '../../data/profile_repository.dart';

/// Show add task bottom sheet
void showAddTaskDialog(BuildContext context, WidgetRef ref) {
  final textController = TextEditingController();
  String? selectedAssigneeId;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          final membersAsync = ref.watch(familyMembersProvider);
          
          return AppBottomSheet(
            title: '✨ Yeni Görev Ekle',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task title input
                TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Görev ne?',
                    hintText: 'Örn: Çöpü at, Fatura öde...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.task_alt, color: AppColors.familyAccent),
                  ),
                ),
                const SizedBox(height: 20),

                // Assignee dropdown
                Text('Kime Atanacak?', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                membersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Üyeler yüklenemedi'),
                  data: (members) => _buildAssigneeDropdown(
                    members: members,
                    selectedId: selectedAssigneeId,
                    onChanged: (val) => setState(() => selectedAssigneeId = val),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                AppBottomSheetButton(
                  label: 'Görev Ver',
                  backgroundColor: AppColors.familyAccent,
                  onPressed: () {
                    final familyId = ref.read(currentFamilyIdProvider);
                    if (familyId != null && textController.text.trim().isNotEmpty) {
                      ref.read(familyRepositoryProvider).addTask(
                        familyId: familyId,
                        title: textController.text.trim(),
                        assignedToId: selectedAssigneeId,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildAssigneeDropdown({
  required List<Profile> members,
  required String? selectedId,
  required ValueChanged<String?> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButton<String?>(
      value: selectedId,
      isExpanded: true,
      underline: const SizedBox(),
      hint: const Text('Herkes (Atama Yok)'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Herkes (Atama Yok)')),
        ...members.map((m) => DropdownMenuItem(
          value: m.id,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.familyAccent,
                child: Text(m.initial, style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Text(m.displayName),
            ],
          ),
        )),
      ],
      onChanged: onChanged,
    ),
  );
}

/// Show add note bottom sheet
void showAddNoteDialog(BuildContext context, WidgetRef ref) {
  final textController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AppBottomSheet(
      title: '📝 Panoya Not Bırak',
      child: Column(
        children: [
          TextField(
            controller: textController,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Eve gelirken ekmek al...',
              filled: true,
              fillColor: Colors.yellow.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppBottomSheetButton(
            label: 'Panoya As',
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black87,
            onPressed: () {
              final familyId = ref.read(currentFamilyIdProvider);
              if (familyId != null && textController.text.trim().isNotEmpty) {
                ref.read(wallRepositoryProvider).addNote(familyId, textController.text.trim());
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    ),
  );
}

/// Show invite dialog
Future<void> showInviteDialog(BuildContext context, WidgetRef ref) async {
  final familyId = ref.read(currentFamilyIdProvider);
  if (familyId == null) return;

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final data = await Supabase.instance.client
        .from('families')
        .select('invite_code, name')
        .eq('id', familyId)
        .single();

    final code = data['invite_code'] as String? ?? 'KODBULUNAMADI';
    final familyName = data['name'] as String? ?? 'Ailem';

    if (context.mounted) {
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.person_add_alt_1, color: AppColors.familyAccent),
              const SizedBox(width: 12),
              const Text('Aileye Davet Et'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Eşinin veya çocuklarının '$familyName' ailesine katılması için bu kodu kullanması gerekiyor:",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.familyAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.familyAccent.withOpacity(0.3)),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: AppColors.familyAccent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bu kodu paylaş! 📱',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
