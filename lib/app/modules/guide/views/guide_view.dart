import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../controllers/guide_controller.dart';

class GuideView extends GetView<GuideController> {
  const GuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(
        title: 'Cara Penggunaan',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Gap.hXl,
                _buildStepsGrid(context),
                Gap.hXl,
                _buildStartButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panduan Penggunaan',
            style: Responsive.value(
              context,
              mobile: AppTextStyles.h3,
              desktop: AppTextStyles.h2,
            ),
          ),
          Gap.hMd,
          Text(
            'Ikuti langkah-langkah berikut untuk melakukan analisis K-Means Clustering pada data stok fotocopy Anda.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsGrid(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: List.generate(controller.steps.length, (index) {
          return AnimatedBuilder(
            animation: controller.animations[index],
            builder: (context, child) {
              final value = controller.animations[index].value;
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: StepCard(
                      stepNumber: controller.steps[index].number,
                      title: controller.steps[index].title,
                      description: controller.steps[index].description,
                      icon: controller.steps[index].icon,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AppSpacing.lg) / 2;

        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: List.generate(controller.steps.length, (index) {
            return AnimatedBuilder(
              animation: controller.animations[index],
              builder: (context, child) {
                final value = controller.animations[index].value;
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: SizedBox(
                      width: itemWidth,
                      child: StepCard(
                        stepNumber: controller.steps[index].number,
                        title: controller.steps[index].title,
                        description: controller.steps[index].description,
                        icon: controller.steps[index].icon,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Center(
        child: PrimaryButton(
          text: 'Mulai Sekarang',
          icon: Icons.arrow_forward,
          onPressed: controller.navigateToKMeans,
        ),
      ),
    );
  }
}
