import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../controllers/quick_calc_controller.dart';

class QuickCalcView extends GetView<QuickCalcController> {
  const QuickCalcView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(
        title: 'Hitung Cepat K-Means',
        showBackButton: true,
        onBackPressed: () => Get.offNamed('/'),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(context),
                Gap.hXl,
                _buildDataList(context),
                Gap.hXl,
                Align(
                  alignment: Alignment.center,
                  child: _buildSubmitButton(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Item Dari Management', style: AppTextStyles.h4),
                    const SizedBox(height: 4),
                    Text(
                      'Data diambil secara otomatis dari Firebase collection "items"',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Data Item', style: AppTextStyles.h4),
            Obx(
              () => Text(
                'Total: ${controller.items.length} item',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        Gap.hSm,
        Text(
          'Daftar item yang akan dianalisis',
          style: AppTextStyles.bodySmall,
        ),
        Gap.hMd,
        Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.items.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.softBlue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  Gap.hMd,
                  Text(
                    'Belum ada data',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  Gap.hSm,
                  Text(
                    'Tambahkan item melalui menu Kelola Item (Admin)',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return DataListTile(
                isQuickCalc: true,
                index: index,
                title: item.namaBarang,
                subtitle:
                    'Stok Awal dan Akhir: ${item.stokAwal.toStringAsFixed(0)} → ${item.stokAkhir.toStringAsFixed(0)}',
                data: item.toDisplayMap(),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () => PrimaryButton(
            text: 'Mulai Clustering',
            icon: Icons.hub,
            backgroundColor: AppColors.secondary,
            isLoading: controller.isProcessing.value,
            onPressed: controller.isProcessing.value
                ? null
                : controller.performKMeansClustering,
          ),
        ),
        Gap.hMd,
        Obx(
          () => Text(
            'Minimal 3 item diperlukan untuk clustering',
            style: AppTextStyles.caption.copyWith(
              color: controller.items.length < 3
                  ? AppColors.error
                  : AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}
