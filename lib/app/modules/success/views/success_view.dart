import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(
        title: 'Sukses',
        showBackButton: false,
      ),
      body: Center(
        child: ResponsiveContainer(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: AppColors.success,
                    ),
                  ),
                  Gap.hLg,
                  Text(
                    'Analisis Selesai!',
                    style: AppTextStyles.h3.copyWith(color: AppColors.success),
                  ),
                  Gap.hMd,
                  Text(
                    'Hasil analisis K-Means Clustering berhasil disimpan.\nAnda dapat melihat riwayat analisis di menu admin.\nTerima kasih telah menggunakan sistem kami! 🙏',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap.hXl,
                  PrimaryButton(
                    text: 'Kembali ke Beranda',
                    icon: Icons.home,
                    onPressed: () => Get.offAllNamed('/'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
