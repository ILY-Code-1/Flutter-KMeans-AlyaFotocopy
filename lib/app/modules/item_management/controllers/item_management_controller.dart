import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  final hargaController = TextEditingController();
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
    hargaController.dispose();
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

  // Hitung Hari Perkiraan Stok Habis secara otomatis
  void calculateHariPerkiraanHabis() {
    final stokAkhir = double.tryParse(stokAkhirController.text) ?? 0;
    final rataRataBulanan = double.tryParse(rataRataPemakaianController.text) ?? 0;

    if (stokAkhir > 0 && rataRataBulanan > 0) {
      final pemakaianPerHari = rataRataBulanan / 30;
      final estimasiHari = stokAkhir / pemakaianPerHari;
      hariPerkiraanHabisController.text = estimasiHari.toStringAsFixed(2);
    } else {
      hariPerkiraanHabisController.text = "0.00";
    }
  }

  // Hitung Fluktuasi Pemakaian Bulanan secara otomatis
  void calculateFluktuasiPemakaian() {
    final rataRataBulanan = double.tryParse(rataRataPemakaianController.text) ?? 0;

    if (rataRataBulanan > 0) {
      final std = 0.2 * rataRataBulanan;
      fluktuasiPemakaianController.text = std.toStringAsFixed(2);
    } else {
      fluktuasiPemakaianController.text = "0.00";
    }
  }

  // Reset form
  void resetForm() {
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
    hargaController.clear();
  }

  // Load data ke form untuk edit
  void loadItemToForm(Map<String, dynamic> item) {
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
    // Harga nullable - jika null, biarkan kosong
    final harga = item['harga'];
    hargaController.text = harga != null ? harga.toString() : '';
  }

  // Format angka ke Rupiah
  String formatRupiah(int? value) {
    if (value == null) return '-';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
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
        'hariPerkiraanHabis': double.parse(hariPerkiraanHabisController.text),
        'fluktuasiPemakaian': double.parse(fluktuasiPemakaianController.text),
        'updatedAt': DateTime.now(),
      };

      // Harga nullable - hanya simpan jika ada isi
      final hargaText = hargaController.text.trim();
      if (hargaText.isNotEmpty) {
        final harga = int.tryParse(hargaText);
        if (harga != null) {
          itemData['harga'] = harga;
        }
      }

      if (editingItemId == null) {
        // Create new item
        await _firestore.collection('items').add(itemData);

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
