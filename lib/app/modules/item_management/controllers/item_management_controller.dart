import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final items = <Map<String, dynamic>>[].obs;

  // Controllers untuk form
  final namaBarangController = TextEditingController();
  final stokAwalController = TextEditingController();
  final stokAkhirController = TextEditingController();
  final barangMasukController = TextEditingController();
  final barangKeluarController = TextEditingController();
  final rataRataPemakaianController = TextEditingController();
  final frekuensiPembaruanController = TextEditingController();
  final hariPerkiraanHabisController = TextEditingController();
  final fluktuasiPemakaianController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Mode edit atau tambah
  String? editingItemId;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  void onClose() {
    namaBarangController.dispose();
    stokAwalController.dispose();
    stokAkhirController.dispose();
    barangMasukController.dispose();
    barangKeluarController.dispose();
    rataRataPemakaianController.dispose();
    frekuensiPembaruanController.dispose();
    hariPerkiraanHabisController.dispose();
    fluktuasiPemakaianController.dispose();
    super.onClose();
  }

  // Fetch semua items dari Firebase
  Future<void> fetchItems() async {
    try {
      isLoading.value = true;

      final querySnapshot = await _firestore
          .collection('items')
          .orderBy('namaBarang')
          .get();

      items.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data item: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Show form dialog untuk tambah/edit item
  void showItemFormDialog({Map<String, dynamic>? item}) {
    // Reset form
    if (item == null) {
      // Mode tambah
      editingItemId = null;
      namaBarangController.clear();
      stokAwalController.clear();
      stokAkhirController.clear();
      barangMasukController.clear();
      barangKeluarController.clear();
      rataRataPemakaianController.clear();
      frekuensiPembaruanController.clear();
      hariPerkiraanHabisController.clear();
      fluktuasiPemakaianController.clear();
    } else {
      // Mode edit
      editingItemId = item['id'];
      namaBarangController.text = item['namaBarang'] ?? '';
      stokAwalController.text = (item['stokAwal'] ?? 0).toString();
      stokAkhirController.text = (item['stokAkhir'] ?? 0).toString();
      barangMasukController.text = (item['barangMasuk'] ?? 0).toString();
      barangKeluarController.text = (item['barangKeluar'] ?? 0).toString();
      rataRataPemakaianController.text = (item['rataRataPemakaian'] ?? 0).toString();
      frekuensiPembaruanController.text = (item['frekuensiPembaruan'] ?? 0).toString();
      hariPerkiraanHabisController.text = (item['hariPerkiraanHabis'] ?? 0).toString();
      fluktuasiPemakaianController.text = (item['fluktuasiPemakaian'] ?? 0).toString();
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
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    editingItemId == null ? 'Tambah Item Baru' : 'Edit Item',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nama Barang field
                  TextFormField(
                    controller: namaBarangController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Barang',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama barang tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Stok Awal field
                  TextFormField(
                    controller: stokAwalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stok Awal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.looks_one_outlined),
                    ),
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
                  ),
                  const SizedBox(height: 16),

                  // Stok Akhir field
                  TextFormField(
                    controller: stokAkhirController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stok Akhir',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.looks_two_outlined),
                    ),
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
                  ),
                  const SizedBox(height: 16),

                  // Barang Masuk field
                  TextFormField(
                    controller: barangMasukController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Barang Masuk',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.input_outlined),
                    ),
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
                  ),
                  const SizedBox(height: 16),

                  // Barang Keluar field
                  TextFormField(
                    controller: barangKeluarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Barang Keluar',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.output_outlined),
                    ),
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
                  ),
                  const SizedBox(height: 16),

                  // Rata-rata Pemakaian Bulanan field
                  TextFormField(
                    controller: rataRataPemakaianController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rata-rata Pemakaian Bulanan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
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
                  ),
                  const SizedBox(height: 16),

                  // Frekuensi Pembaruan Stok field
                  TextFormField(
                    controller: frekuensiPembaruanController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Frekuensi Pembaruan Stok',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.update_outlined),
                    ),
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
                  ),
                  const SizedBox(height: 16),

                  // Hari Perkiraan Stok Habis field
                  TextFormField(
                    controller: hariPerkiraanHabisController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hari Perkiraan Stok Habis',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hari perkiraan tidak boleh kosong';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fluktuasi Pemakaian Bulanan field
                  TextFormField(
                    controller: fluktuasiPemakaianController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Fluktuasi Pemakaian Bulanan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.trending_up_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Fluktuasi pemakaian tidak boleh kosong';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
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
                        onPressed: () => saveItem(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(editingItemId == null ? 'Tambah' : 'Simpan'),
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

  // Save item (Create or Update)
  Future<void> saveItem() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final itemData = {
        'namaBarang': namaBarangController.text.trim(),
        'stokAwal': int.parse(stokAwalController.text),
        'stokAkhir': int.parse(stokAkhirController.text),
        'barangMasuk': int.parse(barangMasukController.text),
        'barangKeluar': int.parse(barangKeluarController.text),
        'rataRataPemakaian': double.parse(rataRataPemakaianController.text),
        'frekuensiPembaruan': int.parse(frekuensiPembaruanController.text),
        'hariPerkiraanHabis': int.parse(hariPerkiraanHabisController.text),
        'fluktuasiPemakaian': double.parse(fluktuasiPemakaianController.text),
        'updatedAt': DateTime.now(),
      };

      if (editingItemId == null) {
        // Create new item
        await _firestore.collection('items').add(itemData);

        Get.back(); // Close dialog

        Get.snackbar(
          'Berhasil',
          'Item berhasil ditambahkan',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // Update existing item
        await _firestore
            .collection('items')
            .doc(editingItemId)
            .update(itemData);

        Get.back(); // Close dialog

        Get.snackbar(
          'Berhasil',
          'Item berhasil diperbarui',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );
      }

      // Refresh list
      await fetchItems();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan item: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete item
  void deleteItem(String itemId, String namaBarang) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus item "$namaBarang"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await _deleteItemConfirmed(itemId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItemConfirmed(String itemId) async {
    try {
      isLoading.value = true;

      await _firestore.collection('items').doc(itemId).delete();

      Get.snackbar(
        'Berhasil',
        'Item berhasil dihapus',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );

      // Refresh list
      await fetchItems();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus item: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
