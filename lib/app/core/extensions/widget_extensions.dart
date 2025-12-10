import 'package:flutter/material.dart';
import '../../themes/app_spacing.dart';

extension WidgetExtensions on Widget {
  // Padding Extensions
  Widget padAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  Widget padSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: this,
      );

  Widget padOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
        child: this,
      );

  // Common Padding Presets
  Widget get padXs => padAll(AppSpacing.xs);
  Widget get padSm => padAll(AppSpacing.sm);
  Widget get padMd => padAll(AppSpacing.md);
  Widget get padLg => padAll(AppSpacing.lg);
  Widget get padXl => padAll(AppSpacing.xl);

  // Horizontal Padding
  Widget get padHorizontalSm => padSymmetric(horizontal: AppSpacing.sm);
  Widget get padHorizontalMd => padSymmetric(horizontal: AppSpacing.md);
  Widget get padHorizontalLg => padSymmetric(horizontal: AppSpacing.lg);

  // Vertical Padding
  Widget get padVerticalSm => padSymmetric(vertical: AppSpacing.sm);
  Widget get padVerticalMd => padSymmetric(vertical: AppSpacing.md);
  Widget get padVerticalLg => padSymmetric(vertical: AppSpacing.lg);

  // Margin Extensions (using Container)
  Widget marginAll(double value) => Container(
        margin: EdgeInsets.all(value),
        child: this,
      );

  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) =>
      Container(
        margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: this,
      );

  Widget marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Container(
        margin: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
        child: this,
      );

  // Expanded & Flexible
  Widget get expanded => Expanded(child: this);
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);

  // Center
  Widget get centered => Center(child: this);

  // Align
  Widget align(AlignmentGeometry alignment) => Align(
        alignment: alignment,
        child: this,
      );

  // Opacity
  Widget opacity(double value) => Opacity(
        opacity: value,
        child: this,
      );

  // Visibility
  Widget visible(bool isVisible) => Visibility(
        visible: isVisible,
        child: this,
      );

  // GestureDetector wrapper
  Widget onTap(VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        child: this,
      );

  // InkWell wrapper
  Widget inkWell({VoidCallback? onTap, BorderRadius? borderRadius}) => InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: this,
      );

  // ClipRRect
  Widget clipRRect(double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: this,
      );

  // Card wrapper
  Widget card({
    Color? color,
    double elevation = 2,
    double borderRadius = AppSpacing.radiusLg,
  }) =>
      Card(
        color: color,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: this,
      );

  // SizedBox wrapper
  Widget sized({double? width, double? height}) => SizedBox(
        width: width,
        height: height,
        child: this,
      );
}

// SizedBox spacing helpers
class Gap {
  Gap._();

  static SizedBox h(double height) => SizedBox(height: height);
  static SizedBox w(double width) => SizedBox(width: width);

  // Common vertical gaps
  static SizedBox get hXs => h(AppSpacing.xs);
  static SizedBox get hSm => h(AppSpacing.sm);
  static SizedBox get hMd => h(AppSpacing.md);
  static SizedBox get hLg => h(AppSpacing.lg);
  static SizedBox get hXl => h(AppSpacing.xl);
  static SizedBox get hXxl => h(AppSpacing.xxl);

  // Common horizontal gaps
  static SizedBox get wXs => w(AppSpacing.xs);
  static SizedBox get wSm => w(AppSpacing.sm);
  static SizedBox get wMd => w(AppSpacing.md);
  static SizedBox get wLg => w(AppSpacing.lg);
  static SizedBox get wXl => w(AppSpacing.xl);
}
