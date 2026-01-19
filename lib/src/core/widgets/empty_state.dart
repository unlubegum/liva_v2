import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Empty state widget for when there's no data
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Widget? action;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
  
  /// Factory for no tasks state
  factory EmptyState.noTasks() => const EmptyState(
    icon: Icons.task_alt,
    title: 'Henüz görev yok',
    subtitle: '+ butonuna basarak ekle!',
  );
  
  /// Factory for no notes state  
  factory EmptyState.noNotes() => const EmptyState(
    icon: Icons.sticky_note_2_outlined,
    title: 'Pano boş',
    subtitle: 'Ailene bir not bırak! 📝',
  );
  
  /// Factory for no members state
  factory EmptyState.noMembers() => const EmptyState(
    icon: Icons.people_outline,
    title: 'Aile üyesi bulunamadı',
  );
  
  /// Factory for error state
  factory EmptyState.error(String message) => EmptyState(
    icon: Icons.error_outline,
    title: 'Bir hata oluştu',
    subtitle: message,
    iconColor: AppColors.error,
  );
}
