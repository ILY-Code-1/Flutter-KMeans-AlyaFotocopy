import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemData {
  String id;
  String namaBarang;
  double stokAwal;
  double stokAkhir;
  double jumlahMasuk;
  double jumlahKeluar;
  double rataRataPemakaian;
  double frekuensiRestock;
  double dayToStockOut;
  double fluktuasiPemakaian;

  ItemData({
    required this.id,
    required this.namaBarang,
    required this.stokAwal,
    required this.stokAkhir,
    required this.jumlahMasuk,
    required this.jumlahKeluar,
    required this.rataRataPemakaian,
    required this.frekuensiRestock,
    required this.dayToStockOut,
    required this.fluktuasiPemakaian,
  });

  Map<String, String> toDisplayMap() {
    return {
      'Stok Awal': stokAwal.toStringAsFixed(0),
      'Stok Akhir': stokAkhir.toStringAsFixed(0),
      'Jml Masuk': jumlahMasuk.toStringAsFixed(0),
      'Jml Keluar': jumlahKeluar.toStringAsFixed(0),
      'Rata² Pemakaian': rataRataPemakaian.toStringAsFixed(2),
      'Frek. Restock': frekuensiRestock.toStringAsFixed(0),
      'Day To Stock Out': dayToStockOut.toStringAsFixed(1),
      'Fluktuasi': fluktuasiPemakaian.toStringAsFixed(2),
    };
  }
}

class KMeansController extends GetxController {
  final items = <ItemData>[].obs;
  final isEditing = false.obs;
  final editingId = ''.obs;

  // Form Controllers
  final namaBarangController = TextEditingController();
  final stokAwalController = TextEditingController();
  final stokAkhirController = TextEditingController();
  final jumlahMasukController = TextEditingController();
  final jumlahKeluarController = TextEditingController();
  final rataRataPemakaianController = TextEditingController();
  final frekuensiRestockController = TextEditingController();
  final dayToStockOutController = TextEditingController();
  final fluktuasiPemakaianController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    namaBarangController.dispose();
    stokAwalController.dispose();
    stokAkhirController.dispose();
    jumlahMasukController.dispose();
    jumlahKeluarController.dispose();
    rataRataPemakaianController.dispose();
    frekuensiRestockController.dispose();
    dayToStockOutController.dispose();
    fluktuasiPemakaianController.dispose();
    super.onClose();
  }

  void clearForm() {
    namaBarangController.clear();
    stokAwalController.clear();
    stokAkhirController.clear();
    jumlahMasukController.clear();
    jumlahKeluarController.clear();
    rataRataPemakaianController.clear();
    frekuensiRestockController.clear();
    dayToStockOutController.clear();
    fluktuasiPemakaianController.clear();
    isEditing.value = false;
    editingId.value = '';
  }

  void addOrUpdateItem() {
    if (!formKey.currentState!.validate()) return;

    final item = ItemData(
      id: isEditing.value ? editingId.value : DateTime.now().millisecondsSinceEpoch.toString(),
      namaBarang: namaBarangController.text,
      stokAwal: double.tryParse(stokAwalController.text) ?? 0,
      stokAkhir: double.tryParse(stokAkhirController.text) ?? 0,
      jumlahMasuk: double.tryParse(jumlahMasukController.text) ?? 0,
      jumlahKeluar: double.tryParse(jumlahKeluarController.text) ?? 0,
      rataRataPemakaian: double.tryParse(rataRataPemakaianController.text) ?? 0,
      frekuensiRestock: double.tryParse(frekuensiRestockController.text) ?? 0,
      dayToStockOut: double.tryParse(dayToStockOutController.text) ?? 0,
      fluktuasiPemakaian: double.tryParse(fluktuasiPemakaianController.text) ?? 0,
    );

    if (isEditing.value) {
      final index = items.indexWhere((e) => e.id == editingId.value);
      if (index != -1) {
        items[index] = item;
      }
      Get.snackbar(
        'Berhasil',
        'Data berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } else {
      items.add(item);
      Get.snackbar(
        'Berhasil',
        'Data berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }

    clearForm();
  }

  void editItem(ItemData item) {
    isEditing.value = true;
    editingId.value = item.id;

    namaBarangController.text = item.namaBarang;
    stokAwalController.text = item.stokAwal.toStringAsFixed(0);
    stokAkhirController.text = item.stokAkhir.toStringAsFixed(0);
    jumlahMasukController.text = item.jumlahMasuk.toStringAsFixed(0);
    jumlahKeluarController.text = item.jumlahKeluar.toStringAsFixed(0);
    rataRataPemakaianController.text = item.rataRataPemakaian.toStringAsFixed(2);
    frekuensiRestockController.text = item.frekuensiRestock.toStringAsFixed(0);
    dayToStockOutController.text = item.dayToStockOut.toStringAsFixed(1);
    fluktuasiPemakaianController.text = item.fluktuasiPemakaian.toStringAsFixed(2);
  }

  void deleteItem(String id) {
    items.removeWhere((e) => e.id == id);
    Get.snackbar(
      'Berhasil',
      'Data berhasil dihapus',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }

  void navigateToForm() {
    if (items.length < 3) {
      Get.snackbar(
        'Peringatan',
        'Tambahkan minimal 3 item data terlebih dahulu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    // k-means clustering
    // save to firebase

    Get.toNamed('/form');
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field ini wajib diisi';
    }
    if (double.tryParse(value) == null) {
      return 'Masukkan angka yang valid';
    }
    return null;
  }
}
