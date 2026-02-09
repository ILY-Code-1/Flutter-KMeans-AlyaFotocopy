import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../widgets/custom_input.dart';
import '../controllers/item_management_controller.dart';
import '../../admin_dashboard/widgets/admin_drawer.dart';

class ItemManagementView extends GetView<ItemManagementController> {
  const ItemManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/item-management'),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kelola Item',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchItems,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 158, 199, 249).withOpacity(0.1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Belum ada item',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Klik tombol + untuk menambah item baru',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daftar Item',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_2,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Total: ${controller.items.length} item',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Table Card
                    _buildItemTable(context),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => showItemFormDialog(),
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'Tambah Item',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildItemTable(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      return _buildItemCards();
    } else {
      return _buildDataTable();
    }
  }

  Widget _buildItemCards() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: controller.items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppColors.softBlue.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.primary.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['namaBarang'] ?? '',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Stok: ${item['stokAkhir'] ?? 0}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip('Masuk: ${item['barangMasuk'] ?? 0}', Icons.input),
                      _buildInfoChip('Keluar: ${item['barangKeluar'] ?? 0}', Icons.output),
                      _buildInfoChip('Hari Habis: ${item['hariPerkiraanHabis'] ?? 0}', Icons.timer),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: Colors.blue.shade700,
                          onPressed: () =>
                              showItemFormDialog(item: item),
                          tooltip: 'Edit',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red.shade700,
                          onPressed: () => controller.deleteItem(
                            item['id'],
                            item['namaBarang'],
                          ),
                          tooltip: 'Hapus',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(Get.context!).size.width - 48,
          ),
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 24,
            headingRowHeight: 60,
            dataRowMinHeight: 70,
            dataRowMaxHeight: 80,
            headingRowColor: WidgetStateProperty.all(
              AppColors.primary.withOpacity(0.08),
            ),
            columns: [
              _buildDataColumn('Nama Barang', Icons.inventory_2_outlined),
              _buildDataColumn('Stok Awal', Icons.looks_one_outlined),
              _buildDataColumn('Stok Akhir', Icons.looks_two_outlined),
              _buildDataColumn('Barang Masuk', Icons.input_outlined),
              _buildDataColumn('Barang Keluar', Icons.output_outlined),
              _buildDataColumn('Rata-rata', Icons.calendar_month_outlined),
              _buildDataColumn('Frekuensi', Icons.update_outlined),
              _buildDataColumn('Hari Habis', Icons.timer_outlined),
              _buildDataColumn('Fluktuasi', Icons.trending_up_outlined),
              _buildDataColumn('Aksi', Icons.settings_outlined),
            ],
            rows: controller.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                  if (index.isEven) {
                    return AppColors.softBlue.withOpacity(0.3);
                  }
                  return Colors.white;
                }),
                cells: [
                  _buildDataCell(item['namaBarang'] ?? ''),
                  _buildDataCell((item['stokAwal'] ?? 0).toString()),
                  _buildDataCell((item['stokAkhir'] ?? 0).toString()),
                  _buildDataCell((item['barangMasuk'] ?? 0).toString()),
                  _buildDataCell((item['barangKeluar'] ?? 0).toString()),
                  _buildDataCell((item['rataRataPemakaian'] ?? 0).toString()),
                  _buildDataCell((item['frekuensiPembaruan'] ?? 0).toString()),
                  _buildDataCell((item['hariPerkiraanHabis'] ?? 0).toString()),
                  _buildDataCell((item['fluktuasiPemakaian'] ?? 0).toString()),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: Colors.blue.shade700,
                            tooltip: 'Edit',
                            onPressed: () => showItemFormDialog(item: item),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red.shade700,
                            tooltip: 'Hapus',
                            onPressed: () => controller.deleteItem(
                              item['id'],
                              item['namaBarang'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, IconData icon) {
    return DataColumn(
      label: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildDataCell(String text) {
    return DataCell(
      Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void showItemFormDialog({Map<String, dynamic>? item}) {
    if (item == null) {
      controller.resetForm();
    } else {
      controller.loadItemToForm(item);
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item == null ? 'Tambah Item Baru' : 'Edit Item',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nama Barang field
                  CustomInput(
                    label: 'Nama Barang',
                    hint: 'Kertas A4',
                    controller: controller.namaBarangController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama barang tidak boleh kosong';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    infoTooltip: 'Nama produk atau barang yang akan dikelola',
                  ),
                  const SizedBox(height: 16),

                  // Stok Awal field
                  CustomInput(
                    label: 'Stok Awal',
                    hint: '5',
                    controller: controller.stokAwalController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok awal tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.looks_one_outlined),
                    infoTooltip: 'Jumlah stok di awal periode (unit)',
                  ),
                  const SizedBox(height: 16),

                  // Stok Akhir field
                  CustomInput(
                    label: 'Stok Akhir',
                    hint: '2',
                    controller: controller.stokAkhirController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok akhir tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.looks_two_outlined),
                    infoTooltip: 'Jumlah stok di akhir periode (unit)',
                    onChanged: (_) => controller.calculateHariPerkiraanHabis(),
                  ),
                  const SizedBox(height: 16),

                  // Barang Masuk field
                  CustomInput(
                    label: 'Jumlah Barang Masuk',
                    hint: '7',
                    controller: controller.barangMasukController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah barang masuk tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.input_outlined),
                    infoTooltip: 'Total barang yang masuk/terbeli selama periode (unit)',
                  ),
                  const SizedBox(height: 16),

                  // Barang Keluar field
                  CustomInput(
                    label: 'Jumlah Barang Keluar',
                    hint: '10',
                    controller: controller.barangKeluarController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah barang keluar tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.output_outlined),
                    infoTooltip: 'Total barang yang keluar/terjual selama periode (unit)',
                  ),
                  const SizedBox(height: 16),

                  // Rata-rata Pemakaian Bulanan field
                  CustomInput(
                    label: 'Rata-rata Pemakaian Bulanan',
                    hint: '0.83',
                    controller: controller.rataRataPemakaianController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Rata-rata pemakaian tidak boleh kosong';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                    infoTooltip: 'Rata-rata jumlah (unit) pemakaian per bulan',
                    onChanged: (_) {
                      controller.calculateHariPerkiraanHabis();
                      controller.calculateFluktuasiPemakaian();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Frekuensi Pembaruan Stok field
                  CustomInput(
                    label: 'Frekuensi Pembaruan Stok',
                    hint: '1',
                    controller: controller.frekuensiPembaruanController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Frekuensi pembaruan tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.update_outlined),
                    infoTooltip: 'Berapa kali barang diisi ulang dalam satu periode',
                  ),
                  const SizedBox(height: 16),

                  // Hari Perkiraan Stok Habis field (otomatis)
                  CustomInput(
                    label: 'Hari Perkiraan Stok Habis (otomatis)',
                    hint: '74.07',
                    controller: controller.hariPerkiraanHabisController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: false,
                    prefixIcon: const Icon(Icons.timer_outlined),
                    infoTooltip: 'Estimasi berapa hari hingga stok habis -> stok_akhir / (rata_rata_pemakaian_bulanan / 30)',
                  ),
                  const SizedBox(height: 16),

                  // Fluktuasi Pemakaian Bulanan field (otomatis)
                  CustomInput(
                    label: 'Fluktuasi Pemakaian Bulanan (otomatis)',
                    hint: '0.16',
                    controller: controller.fluktuasiPemakaianController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: false,
                    prefixIcon: const Icon(Icons.trending_up_outlined),
                    infoTooltip: 'Standar deviasi pemakaian bulanan -> 0.2 x rata_rata_pemakaian_bulanan',
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => controller.saveItem().then((_) {
                          if (controller.formKey.currentState?.validate() ?? false) {
                            Get.back();
                          }
                        }),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(item == null ? 'Tambah' : 'Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
