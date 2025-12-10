import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../controllers/kmeans_controller.dart';

class KMeansView extends GetView<KMeansController> {
  const KMeansView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(
        title: 'K-Means Clustering',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormSection(context),
                Gap.hXl,
                _buildDataList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
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
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  controller.isEditing.value ? 'Edit Data Item' : 'Tambah Data Item',
                  style: AppTextStyles.h4,
                )),
            Gap.hMd,
            Text(
              'Masukkan data item untuk analisis clustering',
              style: AppTextStyles.bodySmall,
            ),
            Gap.hLg,
            _buildFormFields(context),
            Gap.hLg,
            _buildFormButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final fields = [
      CustomInput(
        label: 'Nama Barang',
        hint: 'Masukkan nama barang',
        controller: controller.namaBarangController,
        validator: controller.validateRequired,
        prefixIcon: const Icon(Icons.inventory_2_outlined),
        infoTooltip: 'Nama produk atau barang yang akan dianalisis',
      ),
      CustomInput(
        label: 'Stok Awal',
        hint: '0',
        controller: controller.stokAwalController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.inventory_outlined),
        infoTooltip: 'Jumlah stok di awal periode',
      ),
      CustomInput(
        label: 'Stok Akhir',
        hint: '0',
        controller: controller.stokAkhirController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.inventory),
        infoTooltip: 'Jumlah stok di akhir periode',
      ),
      CustomInput(
        label: 'Jumlah Masuk',
        hint: '0',
        controller: controller.jumlahMasukController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.add_box_outlined),
        infoTooltip: 'Total barang yang masuk selama periode',
      ),
      CustomInput(
        label: 'Jumlah Keluar',
        hint: '0',
        controller: controller.jumlahKeluarController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.outbox_outlined),
        infoTooltip: 'Total barang yang keluar/terjual selama periode',
      ),
      CustomInput(
        label: 'Rata-Rata Pemakaian Bulanan',
        hint: '0.00',
        controller: controller.rataRataPemakaianController,
        validator: controller.validateNumber,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: const Icon(Icons.trending_flat),
        infoTooltip: 'Rata-rata jumlah pemakaian per bulan',
      ),
      CustomInput(
        label: 'Frekuensi Restock',
        hint: '0',
        controller: controller.frekuensiRestockController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.replay),
        infoTooltip: 'Berapa kali barang di-restock dalam periode',
      ),
      CustomInput(
        label: 'Day To Stock Out',
        hint: '0.0',
        controller: controller.dayToStockOutController,
        validator: controller.validateNumber,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: const Icon(Icons.schedule),
        infoTooltip: 'Estimasi hari hingga stok habis',
      ),
      CustomInput(
        label: 'Fluktuasi Pemakaian Bulanan',
        hint: '0.00',
        controller: controller.fluktuasiPemakaianController,
        validator: controller.validateNumber,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: const Icon(Icons.show_chart),
        infoTooltip: 'Standar deviasi pemakaian bulanan',
      ),
    ];

    if (isMobile) {
      return Column(
        children: fields.map((field) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: field,
        )).toList(),
      );
    }

    final List<Widget> rows = [];
    for (int i = 0; i < fields.length; i += 2) {
      final hasSecond = i + 1 < fields.length;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: fields[i]),
              if (hasSecond) ...[
                Gap.wMd,
                Expanded(child: fields[i + 1]),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildFormButtons(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        Obx(() => PrimaryButton(
              text: controller.isEditing.value ? 'Update' : 'Tambah',
              icon: controller.isEditing.value ? Icons.save : Icons.add,
              onPressed: controller.addOrUpdateItem,
            )),
        Obx(() => controller.isEditing.value
            ? PrimaryButton(
                text: 'Batal',
                isOutlined: true,
                icon: Icons.close,
                onPressed: controller.clearForm,
              )
            : const SizedBox.shrink()),
        PrimaryButton(
          text: 'Lanjutkan',
          icon: Icons.arrow_forward,
          backgroundColor: AppColors.secondary,
          onPressed: controller.navigateToForm,
        ),
      ],
    );
  }

  Widget _buildDataList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data Item', style: AppTextStyles.h4),
        Gap.hSm,
        Text(
          'Daftar item yang akan dianalisis',
          style: AppTextStyles.bodySmall,
        ),
        Gap.hMd,
        Obx(() {
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
                    'Tambahkan item menggunakan form di atas',
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
                index: index,
                title: item.namaBarang,
                subtitle: 'Stok: ${item.stokAwal.toStringAsFixed(0)} → ${item.stokAkhir.toStringAsFixed(0)}',
                data: item.toDisplayMap(),
                onEdit: () => controller.editItem(item),
                onDelete: () => controller.deleteItem(item.id),
              );
            },
          );
        }),
      ],
    );
  }
}
