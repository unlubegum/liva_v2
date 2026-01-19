import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/family_repository.dart';
import '../../data/profile_repository.dart';

/// Member filter bar with avatars
class MemberFilterBar extends ConsumerWidget {
  const MemberFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(familyMembersProvider);
    final selectedUserId = ref.watch(selectedUserFilterProvider);

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: membersAsync.when(
        loading: () => const Center(child: AppLoadingInline()),
        error: (_, __) => const Center(child: Text('Üyeler yüklenemedi')),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('Aile üyesi bulunamadı'));
          }
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              // "All" option
              AvatarChip(
                label: 'Hepsi',
                icon: Icons.groups,
                isSelected: selectedUserId == null,
                accentColor: AppColors.familyAccent,
                onTap: () => ref.read(selectedUserFilterProvider.notifier).state = null,
              ),
              
              // Members
              ...members.map((member) => AvatarChip(
                label: member.displayName,
                avatarUrl: member.avatarUrl,
                initial: member.initial,
                isSelected: selectedUserId == member.id,
                accentColor: AppColors.familyAccent,
                onTap: () => ref.read(selectedUserFilterProvider.notifier).state = member.id,
              )),
            ],
          );
        },
      ),
    );
  }
}
