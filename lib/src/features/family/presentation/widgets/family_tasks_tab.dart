import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/family_repository.dart';
import '../../data/profile_repository.dart';
import '../../domain/family_models.dart';
import 'member_filter_bar.dart';

/// Tasks tab with member filtering
class FamilyTasksTab extends ConsumerWidget {
  const FamilyTasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(familyTasksStreamProvider);
    final selectedUserId = ref.watch(selectedUserFilterProvider);

    return Column(
      children: [
        // Member filter bar
        const MemberFilterBar(),
        
        // Task list
        Expanded(
          child: tasksAsync.when(
            loading: () => const AppLoading(message: 'Görevler yükleniyor...'),
            error: (err, _) => EmptyState.error(err.toString()),
            data: (tasks) => _buildTaskList(context, ref, tasks, selectedUserId),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTaskList(
    BuildContext context,
    WidgetRef ref,
    List<FamilyTask> tasks,
    String? selectedUserId,
  ) {
    // Filter by selected user
    final filteredTasks = selectedUserId == null
        ? tasks
        : tasks.where((t) => t.assignedToId == selectedUserId).toList();

    if (filteredTasks.isEmpty) {
      return EmptyState(
        icon: Icons.task_alt,
        title: selectedUserId == null
            ? 'Henüz görev yok'
            : 'Bu kişiye atanmış görev yok',
        subtitle: selectedUserId == null ? '+ butonuna basarak ekle!' : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return _TaskCard(task: task);
      },
    );
  }
}

/// Individual task card widget
class _TaskCard extends ConsumerWidget {
  final FamilyTask task;
  
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CheckboxListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: task.assignedToId.isNotEmpty
            ? Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text('Atandı', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              )
            : null,
        value: task.isCompleted,
        activeColor: AppColors.familyAccent,
        onChanged: (_) => ref.read(familyRepositoryProvider).toggleTask(task.id),
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => ref.read(familyRepositoryProvider).deleteTask(task.id),
        ),
      ),
    );
  }
}
