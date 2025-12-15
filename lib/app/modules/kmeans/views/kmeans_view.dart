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
            Align(
              alignment: Alignment.centerRight,
              child: _buildFormButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    void hitungDayToStockOut() {
      final stokAkhir = double.tryParse(controller.stokAkhirController.text) ?? 0;
      final rataRataBulanan = double.tryParse(controller.rataRataPemakaianController.text) ?? 0;
      if (stokAkhir > 0 && rataRataBulanan > 0) {
        final pemakaianPerHari = rataRataBulanan / 30;
        final estimasiHari = stokAkhir / pemakaianPerHari;
        controller.dayToStockOutController.text = estimasiHari.toStringAsFixed(2);
      } else {
        controller.dayToStockOutController.text = "0.00";
      }
    }

    void hitungFluktuasi() {
      final rataRataBulanan = double.tryParse(controller.rataRataPemakaianController.text) ?? 0;
      if (rataRataBulanan > 0) {
        final std = 0.2 * rataRataBulanan;
        controller.fluktuasiPemakaianController.text = std.toStringAsFixed(2);
      } else {
        controller.fluktuasiPemakaianController.text = "0.00";
      }
    }

    final fields = [
      CustomInput(
        label: 'Nama Barang',
        hint: 'Kertas A4',
        controller: controller.namaBarangController,
        validator: controller.validateRequired,
        prefixIcon: const Icon(Icons.inventory_2_outlined),
        infoTooltip: 'Nama produk atau barang yang akan dianalisis',
      ),
      CustomInput(
        label: 'Stok Awal',
        hint: '5',
        controller: controller.stokAwalController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.inventory_outlined),
        infoTooltip: 'Jumlah stok di awal periode (unit)',
      ),
      CustomInput(
        label: 'Stok Akhir',
        hint: '2',
        controller: controller.stokAkhirController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.inventory),
        infoTooltip: 'Jumlah stok di akhir periode (unit)',
        onChanged: (_) {
          hitungDayToStockOut();
        },
      ),
      CustomInput(
        label: 'Jumlah Barang Masuk',
        hint: '7',
        controller: controller.jumlahMasukController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.add_box_outlined),
        infoTooltip: 'Total barang yang masuk/terbeli selama periode (unit)',
      ),
      CustomInput(
        label: 'Jumlah Barang Keluar',
        hint: '10',
        controller: controller.jumlahKeluarController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.outbox_outlined),
        infoTooltip: 'Total barang yang keluar/terjual selama periode (unit)',
      ),
      CustomInput(
        label: 'Rata-Rata Pemakaian Bulanan',
        hint: '0.83',
        controller: controller.rataRataPemakaianController,
        validator: controller.validateNumber,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: const Icon(Icons.trending_flat),
        infoTooltip: 'Rata-rata jumlah (unit) pemakaian per bulan',
        onChanged: (_) {
          hitungDayToStockOut();
          hitungFluktuasi();
        },
      ),
      CustomInput(
        label: 'Frekuensi Pembaruan Stok',
        hint: '1',
        controller: controller.frekuensiRestockController,
        validator: controller.validateNumber,
        keyboardType: TextInputType.number,
        prefixIcon: const Icon(Icons.replay),
        infoTooltip: 'Berapa kali barang diisi ulang dalam satu periode',
      ),
      CustomInput(
        label: 'Hari Perkiraan Stok Habis (otomatis)',
        hint: '74.07',
        controller: controller.dayToStockOutController,
        validator: controller.validateNumber,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: const Icon(Icons.schedule),
        infoTooltip: 'Estimasi berapa hari hingga stok habis -> stok_akhir / (rata_rata_pemakaian_bulanan / 30)',
        enabled: false,
      ),
      CustomInput(
        label: 'Fluktuasi Pemakaian Bulanan (otomatis)',
        hint: '0.16',
        controller: controller.fluktuasiPemakaianController,
        validator: controller.validateNumber,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: const Icon(Icons.show_chart),
        infoTooltip: 'Standar deviasi pemakaian bulanan -> 0.2 x rata_rata_pemakaian_bulanan',
        enabled: false,
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
              text: controller.isEditing.value ? 'Perbarui' : 'Tambah',
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
            : PrimaryButton(
                text: 'Bersihkan',
                isOutlined: true,
                icon: Icons.cleaning_services,
                onPressed: controller.clearForm,
              )),
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
                subtitle: 'Stok Awal dan Akhir: ${item.stokAwal.toStringAsFixed(0)} → ${item.stokAkhir.toStringAsFixed(0)}',
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

  Widget _buildSubmitButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PrimaryButton(
          text: 'Mulai Clustering',
          icon: Icons.hub,
          backgroundColor: AppColors.secondary,
          onPressed: controller.navigateToForm,
        ),
      ],
    );
  }
}
