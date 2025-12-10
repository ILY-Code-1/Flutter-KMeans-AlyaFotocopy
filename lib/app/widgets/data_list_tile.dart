import 'package:flutter/material.dart';
import '../themes/themes.dart';

class DataListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Map<String, String>? data;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const DataListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.data,
    this.onEdit,
    this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.all(AppSpacing.md),
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
            child: Text(
              '${index + 1}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.caption) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: onDelete,
                tooltip: 'Hapus',
              ),
            ],
          ),
          children: [
            if (data != null) _buildDataGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDataGrid(BuildContext context) {
    final entries = data!.entries.toList();
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: entries.map((entry) {
        return Container(
          constraints: const BoxConstraints(minWidth: 150),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${entry.key}: ',
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                entry.value,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
