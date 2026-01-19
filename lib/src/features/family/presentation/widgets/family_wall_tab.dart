import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/wall_repository.dart';

/// Wall/Notes tab
class FamilyWallTab extends ConsumerWidget {
  const FamilyWallTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(wallStreamProvider);

    return notesAsync.when(
      loading: () => const AppLoading(message: 'Notlar yükleniyor...'),
      error: (err, _) => EmptyState.error(err.toString()),
      data: (notes) {
        if (notes.isEmpty) {
          return EmptyState.noNotes();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _NoteCard(note: note);
          },
        );
      },
    );
  }
}

/// Individual note card (post-it style)
class _NoteCard extends ConsumerWidget {
  final FamilyNote note;
  
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.yellow.shade100,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(note.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                InkWell(
                  onTap: () => ref.read(wallRepositoryProvider).deleteNote(note.id),
                  child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
