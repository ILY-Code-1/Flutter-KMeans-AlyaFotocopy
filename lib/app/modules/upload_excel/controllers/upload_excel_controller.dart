import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../kmeans/controllers/kmeans_controller.dart';

class UploadExcelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final isProcessing = false.obs;
  final uploadedFileName = ''.obs;
  final items = <ItemData>[].obs;

  // Pick Excel file
  Future<void> pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        isLoading.value = true;
        uploadedFileName.value = result.files.single.name;

        // Parse Excel
        await _parseExcelFile(result.files.single.bytes!);

        Get.snackbar(
          'Berhasil',
          'File Excel berhasil diupload dan diparse',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membaca file Excel: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Parse Excel file
  Future<void> _parseExcelFile(List<int> bytes) async {
    try {
      items.clear();

      final excel = Excel.decodeBytes(bytes);

      // Ambil sheet pertama
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null) {
        throw Exception('Sheet tidak ditemukan');
      }

      // Skip header row (row 0), mulai dari row 1
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];

        // Skip empty rows
        if (row.every((cell) => cell == null || cell.value == null)) {
          continue;
        }

        // Parse each column dengan debug logging
        final namaBarang = _getCellValueAsString(row, 0);
        final stokAwal = _getCellValueAsDouble(row, 1);
        final stokAkhir = _getCellValueAsDouble(row, 2);
        final jumlahMasuk = _getCellValueAsDouble(row, 3);
        final jumlahKeluar = _getCellValueAsDouble(row, 4);
        final rataRataPemakaian = _getCellValueAsDouble(row, 5);
        final frekuensiRestock = _getCellValueAsDouble(row, 6);
        final dayToStockOut = _getCellValueAsDouble(row, 7);
        final fluktuasiPemakaian = _getCellValueAsDouble(row, 8);

        // Debug print untuk melihat nilai yang dibaca
        print('Row $i:');
        print('  Nama: $namaBarang');
        print('  Stok Awal: $stokAwal');
        print('  Jumlah Masuk: $jumlahMasuk');
        print('  Jumlah Keluar: $jumlahKeluar');

        // Validasi data
        if (namaBarang.isEmpty) {
          continue;
        }

        // Create ItemData
        final item = ItemData(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
          namaBarang: namaBarang,
          stokAwal: stokAwal,
          stokAkhir: stokAkhir,
          jumlahMasuk: jumlahMasuk,
          jumlahKeluar: jumlahKeluar,
          rataRataPemakaian: rataRataPemakaian,
          frekuensiRestock: frekuensiRestock,
          dayToStockOut: dayToStockOut,
          fluktuasiPemakaian: fluktuasiPemakaian,
        );

        items.add(item);
      }

      if (items.isEmpty) {
        throw Exception('Tidak ada data yang valid dalam file Excel');
      }
    } catch (e) {
      rethrow;
    }
  }

  String _getCellValueAsString(List<Data?> row, int index) {
    if (index >= row.length) return '';
    final cell = row[index];
    if (cell == null || cell.value == null) return '';

    final value = cell.value;

    // Handle CellValue types from excel package
    if (value is TextCellValue) {
      // TextCellValue.value returns TextSpan, need to get text
      return value.value.text ?? '';
    }
    if (value is IntCellValue) {
      return value.value.toString();
    }
    if (value is DoubleCellValue) {
      return value.value.toString();
    }
    if (value is FormulaCellValue) {
      return value.formula;
    }

    // Fallback to toString
    return value.toString();
  }

  double _getCellValueAsDouble(List<Data?> row, int index) {
    if (index >= row.length) {
      print('  Index $index out of range (row length: ${row.length})');
      return 0.0;
    }

    final cell = row[index];
    if (cell == null) {
      print('  Cell at index $index is null');
      return 0.0;
    }

    final value = cell.value;
    if (value == null) {
      print('  Cell value at index $index is null');
      return 0.0;
    }

    print('  Cell at index $index: type=${value.runtimeType}, value=$value');

    // Handle different cell value types from excel package v4
    if (value is IntCellValue) {
      print('  Parsed as IntCellValue: ${value.value}');
      return value.value.toDouble();
    }
    if (value is DoubleCellValue) {
      print('  Parsed as DoubleCellValue: ${value.value}');
      return value.value;
    }
    if (value is TextCellValue) {
      // TextCellValue.value returns TextSpan, need to get text
      final textValue = value.value.text ?? '';
      print('  Parsed as TextCellValue: $textValue');
      final parsed = double.tryParse(textValue) ?? 0.0;
      print('  Converted to double: $parsed');
      return parsed;
    }
    if (value is FormulaCellValue) {
      print('  Formula cell, trying to parse formula result');
      // Try to parse formula result if available
      return 0.0;
    }

    // Try to parse toString() as last resort
    try {
      final stringValue = value.toString();
      print('  Trying to parse toString(): $stringValue');
      return double.parse(stringValue);
    } catch (e) {
      print('  Failed to parse: $e');
      return 0.0;
    }
  }

  // Process K-Means and Save to Firebase
  Future<void> processAndSave() async {
    if (items.length < 3) {
      Get.snackbar(
        'Peringatan',
        'Minimal 3 item data diperlukan untuk analisis K-Means',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    isProcessing.value = true;

    try {
      // K-Means Clustering
      final kmeansResult = _performKMeansClustering();

      // Save to Firebase
      final resultId = await _saveToFirebase(kmeansResult);

      Get.snackbar(
        'Berhasil',
        'Perhitungan K-Means selesai dan data berhasil disimpan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      // Navigate to success page
      Get.toNamed('/success', arguments: {'resultId': resultId});
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Map<String, dynamic> _performKMeansClustering() {
    // Normalisasi data
    final normalizedData = _normalizeData();

    // Inisialisasi centroids (3 cluster)
    final centroids = _initializeCentroids(normalizedData, 3);

    int iteration = 0;
    const maxIterations = 100;
    const threshold = 0.001;
    bool converged = false;

    List<int> clusterAssignments = [];

    while (!converged && iteration < maxIterations) {
      // Assign items to nearest centroid
      clusterAssignments = _assignToClusters(normalizedData, centroids);

      // Calculate new centroids
      final newCentroids = _calculateNewCentroids(
        normalizedData,
        clusterAssignments,
        3,
      );

      // Check convergence
      converged = _checkConvergence(centroids, newCentroids, threshold);

      centroids.clear();
      centroids.addAll(newCentroids);

      iteration++;
    }

    // Determine cluster characteristics and sort
    final clusterAnalysis = _analyzeAndSortClusters(clusterAssignments, 3);

    // Prepare result
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalItems': items.length,
      'totalIterations': iteration,
      'iterations': iteration,
      'rawData': items.map((item) => item.toJson()).toList(),
      'itemResults': items.asMap().entries.map((entry) {
        int originalCluster = clusterAssignments[entry.key];
        Map<String, int> clusterMapping = Map<String, int>.from(
          clusterAnalysis['clusterMapping'],
        );
        int sortedCluster = clusterMapping[originalCluster.toString()]!;

        return {
          'itemId': entry.value.id,
          'namaBarang': entry.value.namaBarang,
          'cluster': sortedCluster, // 1-indexed, sorted by consumption
        };
      }).toList(),
      'recommendations': _generateRecommendations(clusterAssignments),
    };
  }

  List<List<double>> _normalizeData() {
    if (items.isEmpty) return [];

    // Find min and max for each feature
    final features = items
        .map(
          (item) => [
            item.jumlahMasuk,
            item.jumlahKeluar,
            item.rataRataPemakaian,
            item.frekuensiRestock,
            item.dayToStockOut,
            item.fluktuasiPemakaian,
          ],
        )
        .toList();

    final numFeatures = 6;
    final mins = List<double>.filled(numFeatures, double.infinity);
    final maxs = List<double>.filled(numFeatures, double.negativeInfinity);

    for (var feature in features) {
      for (int i = 0; i < numFeatures; i++) {
        if (feature[i] < mins[i]) mins[i] = feature[i];
        if (feature[i] > maxs[i]) maxs[i] = feature[i];
      }
    }

    // Normalize
    return features.map((feature) {
      return List<double>.generate(numFeatures, (i) {
        if (maxs[i] - mins[i] == 0) return 0.0;
        return (feature[i] - mins[i]) / (maxs[i] - mins[i]);
      });
    }).toList();
  }

  List<List<double>> _initializeCentroids(List<List<double>> data, int k) {
    final random = Random();
    final centroids = <List<double>>[];
    final indices = <int>{};

    while (indices.length < k && indices.length < data.length) {
      indices.add(random.nextInt(data.length));
    }

    for (var index in indices) {
      centroids.add(List<double>.from(data[index]));
    }

    return centroids;
  }

  List<int> _assignToClusters(
    List<List<double>> data,
    List<List<double>> centroids,
  ) {
    return data.map((point) {
      int nearestCluster = 0;
      double minDistance = double.infinity;

      for (int i = 0; i < centroids.length; i++) {
        final distance = _euclideanDistance(point, centroids[i]);
        if (distance < minDistance) {
          minDistance = distance;
          nearestCluster = i;
        }
      }

      return nearestCluster;
    }).toList();
  }

  double _euclideanDistance(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += pow(a[i] - b[i], 2);
    }
    return sqrt(sum);
  }

  List<List<double>> _calculateNewCentroids(
    List<List<double>> data,
    List<int> assignments,
    int k,
  ) {
    final centroids = <List<double>>[];
    final numFeatures = data[0].length;

    for (int cluster = 0; cluster < k; cluster++) {
      final clusterPoints = <List<double>>[];

      for (int i = 0; i < assignments.length; i++) {
        if (assignments[i] == cluster) {
          clusterPoints.add(data[i]);
        }
      }

      if (clusterPoints.isEmpty) {
        centroids.add(List<double>.filled(numFeatures, 0.0));
        continue;
      }

      final centroid = List<double>.generate(numFeatures, (featureIndex) {
        double sum = 0;
        for (var point in clusterPoints) {
          sum += point[featureIndex];
        }
        return sum / clusterPoints.length;
      });

      centroids.add(centroid);
    }

    return centroids;
  }

  bool _checkConvergence(
    List<List<double>> oldCentroids,
    List<List<double>> newCentroids,
    double threshold,
  ) {
    for (int i = 0; i < oldCentroids.length; i++) {
      final distance = _euclideanDistance(oldCentroids[i], newCentroids[i]);
      if (distance > threshold) {
        return false;
      }
    }
    return true;
  }

  List<Map<String, dynamic>> _generateRecommendations(List<int> assignments) {
    // Analyze clusters berdasarkan consumption
    final clusterAnalysis = _analyzeAndSortClusters(assignments, 3);
    Map<String, int> clusterMapping = Map<String, int>.from(
      clusterAnalysis['clusterMapping'],
    );

    List<Map<String, dynamic>> recommendations = [];

    for (int i = 0; i < items.length; i++) {
      int sortedCluster = clusterMapping[assignments[i].toString()]!;
      String recommendation;
      String priority;

      switch (sortedCluster) {
        case 1: // Barang Cepat Habis
          recommendation =
              'Tingkatkan frekuensi restock dan pertimbangkan untuk menambah stok safety. '
              'Perhatikan tren permintaan untuk antisipasi lonjakan.';
          priority = 'Tinggi';
          break;
        case 2: // Barang Kebutuhan Normal
          recommendation =
              'Pertahankan level stok saat ini dengan pemantauan berkala. '
              'Lakukan restock sesuai jadwal normal.';
          priority = 'Sedang';
          break;
        case 3: // Barang Jarang Terpakai
          recommendation =
              'Kurangi jumlah stok untuk menghindari dead stock. '
              'Pertimbangkan promosi atau bundling untuk meningkatkan perputaran.';
          priority = 'Rendah';
          break;
        default:
          recommendation = 'Lakukan analisis lebih lanjut.';
          priority = 'Sedang';
      }

      recommendations.add({
        'itemId': items[i].id,
        'namaBarang': items[i].namaBarang,
        'cluster': sortedCluster,
        'recommendation': recommendation,
        'priority': priority,
      });
    }

    return recommendations;
  }

  Map<String, dynamic> _analyzeAndSortClusters(List<int> assignments, int k) {
    // Calculate average consumption (jumlahKeluar) for each cluster
    List<double> avgConsumption = List.filled(k, 0);
    List<int> counts = List.filled(k, 0);

    for (int i = 0; i < assignments.length; i++) {
      int cluster = assignments[i];
      avgConsumption[cluster] += items[i].jumlahKeluar;
      counts[cluster]++;
    }

    for (int i = 0; i < k; i++) {
      if (counts[i] > 0) {
        avgConsumption[i] /= counts[i];
      }
    }

    // Sort clusters by average consumption (descending)
    List<int> sortedIndices = List.generate(k, (i) => i);
    sortedIndices.sort(
      (a, b) => avgConsumption[b].compareTo(avgConsumption[a]),
    );

    // Create mapping: original cluster -> sorted cluster (1-based)
    Map<String, int> clusterMapping = {};
    for (int i = 0; i < k; i++) {
      clusterMapping[sortedIndices[i].toString()] = i + 1;
    }

    // Cluster labels
    List<String> clusterLabels = [
      'Barang Cepat Habis',
      'Barang Kebutuhan Normal',
      'Barang Jarang Terpakai',
    ];

    return {
      'clusterMapping': clusterMapping,
      'avgConsumption': avgConsumption,
      'counts': counts,
      'clusterLabels': clusterLabels,
      'sortedIndices': sortedIndices,
    };
  }

  Future<String> _saveToFirebase(Map<String, dynamic> result) async {
    try {
      final docRef = await _firestore.collection('kmeans_results').add(result);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Reset
  void reset() {
    items.clear();
    uploadedFileName.value = '';
  }
}
