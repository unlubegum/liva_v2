import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Selectable avatar chip for filtering
class AvatarChip extends StatelessWidget {
  final String label;
  final String? avatarUrl;
  final String? initial;
  final bool isSelected;
  final Color? accentColor;
  final VoidCallback? onTap;
  final IconData? icon;
  
  const AvatarChip({
    super.key,
    required this.label,
    this.avatarUrl,
    this.initial,
    required this.isSelected,
    this.accentColor,
    this.onTap,
    this.icon,
  });

  Color get _accentColor => accentColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isSelected ? _accentColor : Colors.grey.shade300,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: _buildAvatarChild(),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _accentColor : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget? _buildAvatarChild() {
    if (avatarUrl != null) return null;
    
    if (icon != null) {
      return Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey.shade600,
      );
    }
    
    if (initial != null) {
      return Text(
        initial!,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    return null;
  }
}

/// Horizontal avatar filter bar
class AvatarFilterBar extends StatelessWidget {
  final List<AvatarChip> chips;
  final double height;
  
  const AvatarFilterBar({
    super.key,
    required this.chips,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: chips,
      ),
    );
  }
}
