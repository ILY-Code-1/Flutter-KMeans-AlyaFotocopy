import 'package:flutter/material.dart';
import '../themes/themes.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? infoTooltip;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const CustomInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.infoTooltip,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            Text(label, style: AppTextStyles.label),
            if (infoTooltip != null) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: infoTooltip!,
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
