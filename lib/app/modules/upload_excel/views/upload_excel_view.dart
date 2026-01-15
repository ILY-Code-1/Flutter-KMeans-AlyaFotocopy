import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../controllers/upload_excel_controller.dart';

class UploadExcelView extends GetView<UploadExcelController> {
  const UploadExcelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(
        title: 'Upload File Excel',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInstructionCard(context),
                    Gap.hLg,
                    _buildUploadCard(context),
                    Gap.hLg,
                    Obx(() {
                      if (controller.items.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildPreviewCard(context);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard(BuildContext context) {
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
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.info.withOpacity(0.1),
              AppColors.softBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.info.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 28,
                ),
                Gap.wMd,
                Text(
                  'Format File Excel',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            Gap.hMd,
            Text(
              'File Excel harus memiliki format kolom sebagai berikut:',
              style: AppTextStyles.bodyMedium,
            ),
            Gap.hSm,
            _buildColumnList(),
            Gap.hMd,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  Gap.wSm,
                  Expanded(
                    child: Text(
                      'Baris pertama (header) akan diabaikan. Data dimulai dari baris kedua.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnList() {
    final columns = [
      '1. Nama Barang',
      '2. Stok Awal',
      '3. Stok Akhir',
      '4. Jumlah Masuk',
      '5. Jumlah Keluar',
      '6. Rata-rata Pemakaian',
      '7. Frekuensi Restock',
      '8. Day To Stock Out',
      '9. Fluktuasi Pemakaian',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.map((column) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.success,
              ),
              Gap.wSm,
              Text(
                column,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadCard(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
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
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return Column(
                  children: [
                    const CircularProgressIndicator(),
                    Gap.hMd,
                    Text(
                      'Membaca file Excel...',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                );
              }

              if (controller.uploadedFileName.value.isNotEmpty) {
                return Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: AppColors.success,
                    ),
                    Gap.hMd,
                    Text(
                      'File Berhasil Diupload',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Gap.hSm,
                    Text(
                      controller.uploadedFileName.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Gap.hMd,
                    Text(
                      '${controller.items.length} item berhasil diparse',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 64,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  Gap.hMd,
                  Text(
                    'Upload File Excel',
                    style: AppTextStyles.h4,
                  ),
                  Gap.hSm,
                  Text(
                    'Klik tombol di bawah untuk memilih file Excel (.xlsx, .xls)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }),
            Gap.hXl,
            Obx(() => PrimaryButton(
                  text: controller.uploadedFileName.value.isEmpty
                      ? 'Pilih File Excel'
                      : 'Upload File Lain',
                  icon: Icons.folder_open,
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.pickExcelFile,
                )),
            Gap.hMd,
            Obx(() {
              if (controller.items.isNotEmpty) {
                return PrimaryButton(
                  text: 'Proses K-Means',
                  icon: Icons.analytics,
                  onPressed: controller.isProcessing.value
                      ? null
                      : controller.processAndSave,
                  isLoading: controller.isProcessing.value,
                  backgroundColor: AppColors.success,
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
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
      child: Container(
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
            Text(
              'Preview Data (${controller.items.length} items)',
              style: AppTextStyles.h4,
            ),
            Gap.hMd,
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  children: controller.items.take(10).map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaBarang,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gap.hSm,
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _buildDataChip('Stok Awal',
                                  item.stokAwal.toStringAsFixed(0)),
                              _buildDataChip('Stok Akhir',
                                  item.stokAkhir.toStringAsFixed(0)),
                              _buildDataChip('Jml Masuk',
                                  item.jumlahMasuk.toStringAsFixed(0)),
                              _buildDataChip('Jml Keluar',
                                  item.jumlahKeluar.toStringAsFixed(0)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (controller.items.length > 10) ...[
              Gap.hMd,
              Text(
                'Dan ${controller.items.length - 10} item lainnya...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
