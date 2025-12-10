import 'package:flutter/material.dart';
import '../themes/themes.dart';

class PlaceholderImage extends StatelessWidget {
  final double width;
  final double height;
  final String? label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const PlaceholderImage({
    super.key,
    required this.width,
    required this.height,
    this.label,
    this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.softBlue,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.border,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.image_outlined,
            size: width * 0.2,
            color: iconColor ?? AppColors.primary.withValues(alpha: 0.5),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              label!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
