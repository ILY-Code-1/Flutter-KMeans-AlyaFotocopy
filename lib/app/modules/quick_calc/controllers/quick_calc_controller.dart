import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaBarang': namaBarang,
      'stokAwal': stokAwal,
      'stokAkhir': stokAkhir,
      'jumlahMasuk': jumlahMasuk,
      'jumlahKeluar': jumlahKeluar,
      'rataRataPemakaian': rataRataPemakaian,
      'frekuensiRestock': frekuensiRestock,
      'dayToStockOut': dayToStockOut,
      'fluktuasiPemakaian': fluktuasiPemakaian,
    };
  }

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      id: json['id'] as String,
      namaBarang: json['namaBarang'] as String,
      stokAwal: (json['stokAwal'] as num).toDouble(),
      stokAkhir: (json['stokAkhir'] as num).toDouble(),
      jumlahMasuk: (json['barangMasuk'] as num).toDouble(),
      jumlahKeluar: (json['barangKeluar'] as num).toDouble(),
      rataRataPemakaian: (json['rataRataPemakaian'] as num).toDouble(),
      frekuensiRestock: (json['frekuensiPembaruan'] as num).toDouble(),
      dayToStockOut: (json['hariPerkiraanHabis'] as num).toDouble(),
      fluktuasiPemakaian: (json['fluktuasiPemakaian'] as num).toDouble(),
    );
  }

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

class QuickCalcController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final items = <ItemData>[].obs;
  final isLoading = false.obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  // Fetch items dari Firebase collection "items"
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
        return ItemData.fromJson(data);
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

  // Perform K-Means Clustering
  Future<void> performKMeansClustering() async {
    if (items.length < 3) {
      Get.snackbar(
        'Peringatan',
        'Tambahkan minimal 3 item data terlebih dahulu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    isProcessing.value = true;

    try {
      // K-Means Clustering
      final kmeansResult = _performKMeansClusteringAlgorithm();

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

  Map<String, dynamic> _performKMeansClusteringAlgorithm() {
    const int k = 3;
    const int maxIterations = 100;

    // Extract features for clustering (6 features)
    List<List<double>> dataPoints = items
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

    // Normalize data
    final normalizedData = _normalizeData(dataPoints);

    // Initialize centroids using K-Means++ method
    List<List<double>> centroids = _initializeCentroidsKMeansPlusPlus(
      normalizedData,
      k,
    );

    List<int> assignments = List.filled(items.length, 0);
    List<List<double>> previousCentroids = [];

    // Store iteration history for report
    List<Map<String, dynamic>> iterationHistory = [];

    for (int iteration = 0; iteration < maxIterations; iteration++) {
      // Store distance calculations for this iteration
      List<Map<String, dynamic>> distanceCalculations = [];

      // Assign points to nearest centroid
      for (int i = 0; i < normalizedData.length; i++) {
        double minDistance = double.infinity;
        int nearestCentroid = 0;
        List<double> distances = [];

        for (int j = 0; j < k; j++) {
          double distance = _euclideanDistance(normalizedData[i], centroids[j]);
          distances.add(distance);
          if (distance < minDistance) {
            minDistance = distance;
            nearestCentroid = j;
          }
        }

        assignments[i] = nearestCentroid;
        distanceCalculations.add({
          'itemName': items[i].namaBarang,
          'itemIndex': i,
          'distances': distances,
          'assignedCluster': nearestCentroid + 1,
        });
      }

      // Store previous centroids for convergence check
      previousCentroids = centroids.map((c) => List<double>.from(c)).toList();

      // Update centroids
      centroids = _updateCentroids(normalizedData, assignments, k);

      // Record iteration (convert nested arrays to maps for Firebase compatibility)
      iterationHistory.add({
        'iteration': iteration + 1,
        'centroids': _convertCentroidsToMap(centroids),
        'assignments': List<int>.from(assignments),
        'distanceCalculations': distanceCalculations
            .map(
              (dc) => {
                ...dc,
                'distances': _convertListToMap(dc['distances'] as List<double>),
              },
            )
            .toList(),
      });

      // Check convergence
      if (_hasConverged(previousCentroids, centroids)) {
        break;
      }
    }

    // Determine cluster characteristics and sort
    final clusterAnalysis = _analyzeAndSortClusters(assignments, k);

    // Generate recommendations
    final recommendations = _generateRecommendations(
      assignments,
      clusterAnalysis,
    );

    // Build detailed result
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalItems': items.length,
      'k': k,
      'totalIterations': iterationHistory.length,
      'iterationHistory': iterationHistory,
      'finalCentroids': _convertCentroidsToMap(centroids),
      'clusterAnalysis': clusterAnalysis,
      'itemResults': _buildItemResults(assignments, clusterAnalysis),
      'recommendations': recommendations,
      'rawData': items
          .map(
            (item) => {
              'id': item.id,
              'namaBarang': item.namaBarang,
              'stokAwal': item.stokAwal,
              'stokAkhir': item.stokAkhir,
              'jumlahMasuk': item.jumlahMasuk,
              'jumlahKeluar': item.jumlahKeluar,
              'rataRataPemakaian': item.rataRataPemakaian,
              'frekuensiRestock': item.frekuensiRestock,
              'dayToStockOut': item.dayToStockOut,
              'fluktuasiPemakaian': item.fluktuasiPemakaian,
            },
          )
          .toList(),
    };
  }

  // Helper methods to convert nested arrays to maps for Firebase compatibility
  Map<String, Map<String, double>> _convertCentroidsToMap(
    List<List<double>> centroids,
  ) {
    Map<String, Map<String, double>> result = {};
    for (int i = 0; i < centroids.length; i++) {
      result['c$i'] = _convertListToMap(centroids[i]);
    }
    return result;
  }

  Map<String, double> _convertListToMap(List<double> list) {
    Map<String, double> result = {};
    for (int i = 0; i < list.length; i++) {
      result['v$i'] = list[i];
    }
    return result;
  }

  List<List<double>> _normalizeData(List<List<double>> data) {
    if (data.isEmpty) return data;

    int numFeatures = data[0].length;
    List<double> minValues = List.filled(numFeatures, double.infinity);
    List<double> maxValues = List.filled(numFeatures, double.negativeInfinity);

    // Find min and max for each feature
    for (var point in data) {
      for (int i = 0; i < numFeatures; i++) {
        if (point[i] < minValues[i]) minValues[i] = point[i];
        if (point[i] > maxValues[i]) maxValues[i] = point[i];
      }
    }

    // Normalize
    return data.map((point) {
      return List.generate(numFeatures, (i) {
        double range = maxValues[i] - minValues[i];
        if (range == 0) return 0.0;
        return (point[i] - minValues[i]) / range;
      });
    }).toList();
  }

  List<List<double>> _initializeCentroidsKMeansPlusPlus(
    List<List<double>> data,
    int k,
  ) {
    final random = Random();
    List<List<double>> centroids = [];

    // Choose first centroid randomly
    centroids.add(List<double>.from(data[random.nextInt(data.length)]));

    // Choose remaining centroids
    for (int i = 1; i < k; i++) {
      List<double> distances = [];
      double totalDistance = 0;

      for (var point in data) {
        double minDist = double.infinity;
        for (var centroid in centroids) {
          double dist = _euclideanDistance(point, centroid);
          if (dist < minDist) minDist = dist;
        }
        distances.add(minDist * minDist);
        totalDistance += minDist * minDist;
      }

      // Choose next centroid with probability proportional to distance squared
      double threshold = random.nextDouble() * totalDistance;
      double cumulative = 0;
      for (int j = 0; j < data.length; j++) {
        cumulative += distances[j];
        if (cumulative >= threshold) {
          centroids.add(List<double>.from(data[j]));
          break;
        }
      }
    }

    return centroids;
  }

  double _euclideanDistance(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += pow(a[i] - b[i], 2);
    }
    return sqrt(sum);
  }

  List<List<double>> _updateCentroids(
    List<List<double>> data,
    List<int> assignments,
    int k,
  ) {
    int numFeatures = data[0].length;
    List<List<double>> newCentroids = List.generate(
      k,
      (_) => List.filled(numFeatures, 0.0),
    );
    List<int> counts = List.filled(k, 0);

    for (int i = 0; i < data.length; i++) {
      int cluster = assignments[i];
      counts[cluster]++;
      for (int j = 0; j < numFeatures; j++) {
        newCentroids[cluster][j] += data[i][j];
      }
    }

    for (int i = 0; i < k; i++) {
      if (counts[i] > 0) {
        for (int j = 0; j < numFeatures; j++) {
          newCentroids[i][j] /= counts[i];
        }
      }
    }

    return newCentroids;
  }

  bool _hasConverged(
    List<List<double>> oldCentroids,
    List<List<double>> newCentroids,
  ) {
    const double threshold = 0.0001;
    for (int i = 0; i < oldCentroids.length; i++) {
      if (_euclideanDistance(oldCentroids[i], newCentroids[i]) > threshold) {
        return false;
      }
    }
    return true;
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
    // Use String keys for Firebase compatibility
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

  List<Map<String, dynamic>> _buildItemResults(
    List<int> assignments,
    Map<String, dynamic> clusterAnalysis,
  ) {
    Map<String, int> clusterMapping = Map<String, int>.from(
      clusterAnalysis['clusterMapping'],
    );
    List<String> clusterLabels = List<String>.from(
      clusterAnalysis['clusterLabels'],
    );

    return List.generate(items.length, (i) {
      int originalCluster = assignments[i];
      int sortedCluster = clusterMapping[originalCluster.toString()]!;

      return {
        'itemId': items[i].id,
        'namaBarang': items[i].namaBarang,
        'originalCluster': originalCluster,
        'cluster': sortedCluster,
        'clusterLabel': clusterLabels[sortedCluster - 1],
        'jumlahMasuk': items[i].jumlahMasuk,
        'jumlahKeluar': items[i].jumlahKeluar,
        'rataRataPemakaian': items[i].rataRataPemakaian,
        'frekuensiRestock': items[i].frekuensiRestock,
        'dayToStockOut': items[i].dayToStockOut,
        'fluktuasiPemakaian': items[i].fluktuasiPemakaian,
        'stokAwal': items[i].stokAwal,
        'stokAkhir': items[i].stokAkhir,
      };
    });
  }

  List<Map<String, dynamic>> _generateRecommendations(
    List<int> assignments,
    Map<String, dynamic> clusterAnalysis,
  ) {
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

  Future<String> _saveToFirebase(Map<String, dynamic> result) async {
    final docRef = await _firestore.collection('kmeans_results').add(result);
    return docRef.id;
  }
}
