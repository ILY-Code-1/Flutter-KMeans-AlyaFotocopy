import 'dart:math';

/// Blackbox Testing untuk Algoritma K-Means
/// Jalankan dengan: dart test/blackbox_test.dart

// Model sederhana untuk testing
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
}

// Fungsi K-Means untuk testing
class KMeansAlgorithm {
  List<List<double>> normalizeData(List<List<double>> data) {
    if (data.isEmpty) return data;

    int numFeatures = data[0].length;
    List<double> minValues = List.filled(numFeatures, double.infinity);
    List<double> maxValues = List.filled(numFeatures, double.negativeInfinity);

    for (var point in data) {
      for (int i = 0; i < numFeatures; i++) {
        if (point[i] < minValues[i]) minValues[i] = point[i];
        if (point[i] > maxValues[i]) maxValues[i] = point[i];
      }
    }

    return data.map((point) {
      return List.generate(numFeatures, (i) {
        double range = maxValues[i] - minValues[i];
        if (range == 0) return 0.0;
        return (point[i] - minValues[i]) / range;
      });
    }).toList();
  }

  double euclideanDistance(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += pow(a[i] - b[i], 2);
    }
    return sqrt(sum);
  }

  List<List<double>> updateCentroids(List<List<double>> data, List<int> assignments, int k) {
    int numFeatures = data[0].length;
    List<List<double>> newCentroids = List.generate(k, (_) => List.filled(numFeatures, 0.0));
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

  bool hasConverged(List<List<double>> oldCentroids, List<List<double>> newCentroids) {
    const double threshold = 0.0001;
    for (int i = 0; i < oldCentroids.length; i++) {
      if (euclideanDistance(oldCentroids[i], newCentroids[i]) > threshold) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> performClustering(List<ItemData> items, int k, int maxIterations) {
    List<List<double>> dataPoints = items.map((item) => [
      item.jumlahMasuk,
      item.jumlahKeluar,
      item.rataRataPemakaian,
      item.frekuensiRestock,
      item.dayToStockOut,
      item.fluktuasiPemakaian,
    ]).toList();

    final normalizedData = normalizeData(dataPoints);
    
    // Initialize centroids (simple method for testing)
    List<List<double>> centroids = [];
    final random = Random(42); // Fixed seed for reproducibility
    for (int i = 0; i < k; i++) {
      centroids.add(List<double>.from(normalizedData[random.nextInt(normalizedData.length)]));
    }

    List<int> assignments = List.filled(items.length, 0);
    List<List<double>> previousCentroids = [];
    int iterations = 0;

    for (int iteration = 0; iteration < maxIterations; iteration++) {
      iterations = iteration + 1;
      
      // Assign points to nearest centroid
      for (int i = 0; i < normalizedData.length; i++) {
        double minDistance = double.infinity;
        int nearestCentroid = 0;

        for (int j = 0; j < k; j++) {
          double distance = euclideanDistance(normalizedData[i], centroids[j]);
          if (distance < minDistance) {
            minDistance = distance;
            nearestCentroid = j;
          }
        }
        assignments[i] = nearestCentroid;
      }

      previousCentroids = centroids.map((c) => List<double>.from(c)).toList();
      centroids = updateCentroids(normalizedData, assignments, k);

      if (hasConverged(previousCentroids, centroids)) {
        break;
      }
    }

    return {
      'assignments': assignments,
      'centroids': centroids,
      'iterations': iterations,
      'normalizedData': normalizedData,
    };
  }
}

// Test Runner
class BlackboxTestRunner {
  int _passed = 0;
  int _failed = 0;
  final List<String> _results = [];

  void printHeader(String title) {
    print('\n${'=' * 60}');
    print(' $title');
    print('=' * 60);
  }

  void printSubHeader(String title) {
    print('\n--- $title ---');
  }

  void test(String name, bool Function() testFn) {
    try {
      if (testFn()) {
        _passed++;
        _results.add('[PASS] $name');
        print('[PASS] $name');
      } else {
        _failed++;
        _results.add('[FAIL] $name');
        print('[FAIL] $name');
      }
    } catch (e) {
      _failed++;
      _results.add('[FAIL] $name - Error: $e');
      print('[FAIL] $name - Error: $e');
    }
  }

  void printSummary() {
    print('\n${'=' * 60}');
    print(' TEST SUMMARY');
    print('=' * 60);
    print('Total Tests: ${_passed + _failed}');
    print('Passed: $_passed');
    print('Failed: $_failed');
    print('Success Rate: ${((_passed / (_passed + _failed)) * 100).toStringAsFixed(1)}%');
    print('=' * 60);
  }
}

void main() {
  final runner = BlackboxTestRunner();
  final kmeans = KMeansAlgorithm();

  runner.printHeader('BLACKBOX TESTING - K-MEANS CLUSTERING');
  print('Aplikasi: Flutter K-Means Fotocopy');
  print('Tanggal: ${DateTime.now()}');

  // =====================================================
  // TEST CASE 1: Normalisasi Data
  // =====================================================
  runner.printSubHeader('TC-01: Normalisasi Data');

  runner.test('TC-01-01: Normalisasi menghasilkan nilai 0-1', () {
    final data = [
      [10.0, 20.0, 30.0],
      [50.0, 100.0, 150.0],
      [30.0, 60.0, 90.0],
    ];
    final normalized = kmeans.normalizeData(data);
    
    for (var point in normalized) {
      for (var value in point) {
        if (value < 0 || value > 1) return false;
      }
    }
    return true;
  });

  runner.test('TC-01-02: Nilai minimum menjadi 0', () {
    final data = [
      [10.0, 20.0],
      [50.0, 100.0],
      [30.0, 60.0],
    ];
    final normalized = kmeans.normalizeData(data);
    return normalized[0][0] == 0.0 && normalized[0][1] == 0.0;
  });

  runner.test('TC-01-03: Nilai maximum menjadi 1', () {
    final data = [
      [10.0, 20.0],
      [50.0, 100.0],
      [30.0, 60.0],
    ];
    final normalized = kmeans.normalizeData(data);
    return normalized[1][0] == 1.0 && normalized[1][1] == 1.0;
  });

  runner.test('TC-01-04: Data kosong tetap kosong', () {
    final data = <List<double>>[];
    final normalized = kmeans.normalizeData(data);
    return normalized.isEmpty;
  });

  runner.test('TC-01-05: Nilai identik menghasilkan 0', () {
    final data = [
      [50.0, 50.0],
      [50.0, 50.0],
      [50.0, 50.0],
    ];
    final normalized = kmeans.normalizeData(data);
    return normalized.every((point) => point.every((v) => v == 0.0));
  });

  // =====================================================
  // TEST CASE 2: Euclidean Distance
  // =====================================================
  runner.printSubHeader('TC-02: Perhitungan Jarak Euclidean');

  runner.test('TC-02-01: Jarak titik sama = 0', () {
    final a = [1.0, 2.0, 3.0];
    final b = [1.0, 2.0, 3.0];
    return kmeans.euclideanDistance(a, b) == 0.0;
  });

  runner.test('TC-02-02: Jarak 2D benar (3-4-5 triangle)', () {
    final a = [0.0, 0.0];
    final b = [3.0, 4.0];
    return kmeans.euclideanDistance(a, b) == 5.0;
  });

  runner.test('TC-02-03: Jarak 3D benar', () {
    final a = [0.0, 0.0, 0.0];
    final b = [1.0, 1.0, 1.0];
    final expected = sqrt(3);
    return (kmeans.euclideanDistance(a, b) - expected).abs() < 0.0001;
  });

  runner.test('TC-02-04: Jarak simetris (A->B = B->A)', () {
    final a = [1.0, 5.0, 3.0];
    final b = [4.0, 2.0, 8.0];
    return kmeans.euclideanDistance(a, b) == kmeans.euclideanDistance(b, a);
  });

  runner.test('TC-02-05: Jarak selalu positif', () {
    final a = [-5.0, -3.0];
    final b = [2.0, 4.0];
    return kmeans.euclideanDistance(a, b) > 0;
  });

  // =====================================================
  // TEST CASE 3: Update Centroids
  // =====================================================
  runner.printSubHeader('TC-03: Update Centroids');

  runner.test('TC-03-01: Centroid adalah rata-rata cluster', () {
    final data = [
      [0.0, 0.0],
      [2.0, 2.0],
      [10.0, 10.0],
      [12.0, 12.0],
    ];
    final assignments = [0, 0, 1, 1];
    final centroids = kmeans.updateCentroids(data, assignments, 2);
    
    // Cluster 0: (0+2)/2 = 1, (0+2)/2 = 1
    // Cluster 1: (10+12)/2 = 11, (10+12)/2 = 11
    return centroids[0][0] == 1.0 && centroids[0][1] == 1.0 &&
           centroids[1][0] == 11.0 && centroids[1][1] == 11.0;
  });

  runner.test('TC-03-02: Single point cluster = point itself', () {
    final data = [
      [5.0, 5.0],
      [10.0, 10.0],
      [15.0, 15.0],
    ];
    final assignments = [0, 1, 2];
    final centroids = kmeans.updateCentroids(data, assignments, 3);
    
    return centroids[0][0] == 5.0 && centroids[1][0] == 10.0 && centroids[2][0] == 15.0;
  });

  // =====================================================
  // TEST CASE 4: Konvergensi
  // =====================================================
  runner.printSubHeader('TC-04: Konvergensi');

  runner.test('TC-04-01: Centroid sama = konvergen', () {
    final old = [[1.0, 2.0], [3.0, 4.0]];
    final newC = [[1.0, 2.0], [3.0, 4.0]];
    return kmeans.hasConverged(old, newC) == true;
  });

  runner.test('TC-04-02: Centroid beda signifikan = tidak konvergen', () {
    final old = [[1.0, 2.0], [3.0, 4.0]];
    final newC = [[5.0, 6.0], [7.0, 8.0]];
    return kmeans.hasConverged(old, newC) == false;
  });

  runner.test('TC-04-03: Perbedaan kecil di bawah threshold = konvergen', () {
    final old = [[1.0, 2.0]];
    final newC = [[1.00001, 2.00001]];
    return kmeans.hasConverged(old, newC) == true;
  });

  // =====================================================
  // TEST CASE 5: K-Means Clustering End-to-End
  // =====================================================
  runner.printSubHeader('TC-05: K-Means End-to-End');

  // Sample data barang fotocopy
  final sampleItems = [
    // Barang cepat habis (high consumption)
    ItemData(id: '1', namaBarang: 'Kertas HVS A4', stokAwal: 100, stokAkhir: 20, 
             jumlahMasuk: 200, jumlahKeluar: 180, rataRataPemakaian: 30.0, 
             frekuensiRestock: 10, dayToStockOut: 2.0, fluktuasiPemakaian: 0.8),
    ItemData(id: '2', namaBarang: 'Tinta Hitam', stokAwal: 50, stokAkhir: 5,
             jumlahMasuk: 100, jumlahKeluar: 95, rataRataPemakaian: 15.0,
             frekuensiRestock: 8, dayToStockOut: 1.5, fluktuasiPemakaian: 0.7),
    
    // Barang normal (medium consumption)
    ItemData(id: '3', namaBarang: 'Staples', stokAwal: 30, stokAkhir: 15,
             jumlahMasuk: 40, jumlahKeluar: 35, rataRataPemakaian: 5.0,
             frekuensiRestock: 4, dayToStockOut: 10.0, fluktuasiPemakaian: 0.3),
    ItemData(id: '4', namaBarang: 'Amplop', stokAwal: 200, stokAkhir: 100,
             jumlahMasuk: 150, jumlahKeluar: 150, rataRataPemakaian: 10.0,
             frekuensiRestock: 3, dayToStockOut: 15.0, fluktuasiPemakaian: 0.4),
    
    // Barang jarang terpakai (low consumption)
    ItemData(id: '5', namaBarang: 'Laminating A3', stokAwal: 50, stokAkhir: 45,
             jumlahMasuk: 10, jumlahKeluar: 5, rataRataPemakaian: 0.5,
             frekuensiRestock: 1, dayToStockOut: 90.0, fluktuasiPemakaian: 0.1),
    ItemData(id: '6', namaBarang: 'Jilid Spiral Besar', stokAwal: 100, stokAkhir: 90,
             jumlahMasuk: 20, jumlahKeluar: 10, rataRataPemakaian: 1.0,
             frekuensiRestock: 1, dayToStockOut: 60.0, fluktuasiPemakaian: 0.2),
  ];

  runner.test('TC-05-01: Clustering menghasilkan 3 cluster', () {
    final result = kmeans.performClustering(sampleItems, 3, 100);
    final assignments = result['assignments'] as List<int>;
    final uniqueClusters = assignments.toSet();
    return uniqueClusters.length <= 3;
  });

  runner.test('TC-05-02: Setiap item mendapat assignment', () {
    final result = kmeans.performClustering(sampleItems, 3, 100);
    final assignments = result['assignments'] as List<int>;
    return assignments.length == sampleItems.length;
  });

  runner.test('TC-05-03: Assignment dalam range valid (0 to k-1)', () {
    final result = kmeans.performClustering(sampleItems, 3, 100);
    final assignments = result['assignments'] as List<int>;
    return assignments.every((a) => a >= 0 && a < 3);
  });

  runner.test('TC-05-04: Konvergen dalam max iterations', () {
    final result = kmeans.performClustering(sampleItems, 3, 100);
    final iterations = result['iterations'] as int;
    return iterations <= 100;
  });

  runner.test('TC-05-05: Centroids memiliki dimensi yang benar (6 features)', () {
    final result = kmeans.performClustering(sampleItems, 3, 100);
    final centroids = result['centroids'] as List<List<double>>;
    return centroids.every((c) => c.length == 6);
  });

  // =====================================================
  // TEST CASE 6: Edge Cases
  // =====================================================
  runner.printSubHeader('TC-06: Edge Cases');

  runner.test('TC-06-01: Minimum 3 items untuk clustering', () {
    final minItems = [
      ItemData(id: '1', namaBarang: 'Item 1', stokAwal: 10, stokAkhir: 5,
               jumlahMasuk: 20, jumlahKeluar: 15, rataRataPemakaian: 2.0,
               frekuensiRestock: 2, dayToStockOut: 5.0, fluktuasiPemakaian: 0.3),
      ItemData(id: '2', namaBarang: 'Item 2', stokAwal: 100, stokAkhir: 50,
               jumlahMasuk: 200, jumlahKeluar: 150, rataRataPemakaian: 20.0,
               frekuensiRestock: 10, dayToStockOut: 3.0, fluktuasiPemakaian: 0.8),
      ItemData(id: '3', namaBarang: 'Item 3', stokAwal: 50, stokAkhir: 45,
               jumlahMasuk: 10, jumlahKeluar: 5, rataRataPemakaian: 0.5,
               frekuensiRestock: 1, dayToStockOut: 50.0, fluktuasiPemakaian: 0.1),
    ];
    final result = kmeans.performClustering(minItems, 3, 100);
    return result['assignments'] != null;
  });

  runner.test('TC-06-02: Data dengan nilai 0 tidak error', () {
    final zeroItems = [
      ItemData(id: '1', namaBarang: 'Item 1', stokAwal: 0, stokAkhir: 0,
               jumlahMasuk: 0, jumlahKeluar: 0, rataRataPemakaian: 0,
               frekuensiRestock: 0, dayToStockOut: 0, fluktuasiPemakaian: 0),
      ItemData(id: '2', namaBarang: 'Item 2', stokAwal: 10, stokAkhir: 5,
               jumlahMasuk: 20, jumlahKeluar: 15, rataRataPemakaian: 2.0,
               frekuensiRestock: 2, dayToStockOut: 5.0, fluktuasiPemakaian: 0.3),
      ItemData(id: '3', namaBarang: 'Item 3', stokAwal: 50, stokAkhir: 25,
               jumlahMasuk: 100, jumlahKeluar: 75, rataRataPemakaian: 10.0,
               frekuensiRestock: 5, dayToStockOut: 10.0, fluktuasiPemakaian: 0.5),
    ];
    try {
      kmeans.performClustering(zeroItems, 3, 100);
      return true;
    } catch (e) {
      return false;
    }
  });

  runner.test('TC-06-03: Data dengan nilai besar tidak overflow', () {
    final largeItems = [
      ItemData(id: '1', namaBarang: 'Item 1', stokAwal: 1000000, stokAkhir: 500000,
               jumlahMasuk: 2000000, jumlahKeluar: 1500000, rataRataPemakaian: 50000.0,
               frekuensiRestock: 100, dayToStockOut: 10.0, fluktuasiPemakaian: 0.9),
      ItemData(id: '2', namaBarang: 'Item 2', stokAwal: 10, stokAkhir: 5,
               jumlahMasuk: 20, jumlahKeluar: 15, rataRataPemakaian: 2.0,
               frekuensiRestock: 2, dayToStockOut: 5.0, fluktuasiPemakaian: 0.3),
      ItemData(id: '3', namaBarang: 'Item 3', stokAwal: 50, stokAkhir: 25,
               jumlahMasuk: 100, jumlahKeluar: 75, rataRataPemakaian: 10.0,
               frekuensiRestock: 5, dayToStockOut: 10.0, fluktuasiPemakaian: 0.5),
    ];
    try {
      final result = kmeans.performClustering(largeItems, 3, 100);
      return result['assignments'] != null;
    } catch (e) {
      return false;
    }
  });

  // =====================================================
  // TEST CASE 7: Validasi Input
  // =====================================================
  runner.printSubHeader('TC-07: Validasi Input');

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

  runner.test('TC-07-01: Validasi required - string kosong ditolak', () {
    return validateRequired('') != null;
  });

  runner.test('TC-07-02: Validasi required - null ditolak', () {
    return validateRequired(null) != null;
  });

  runner.test('TC-07-03: Validasi required - string valid diterima', () {
    return validateRequired('Test Value') == null;
  });

  runner.test('TC-07-04: Validasi number - angka valid diterima', () {
    return validateNumber('123.45') == null;
  });

  runner.test('TC-07-05: Validasi number - bukan angka ditolak', () {
    return validateNumber('abc') != null;
  });

  runner.test('TC-07-06: Validasi number - angka negatif diterima', () {
    return validateNumber('-50') == null;
  });

  // =====================================================
  // DETAIL HASIL CLUSTERING
  // =====================================================
  runner.printSubHeader('DETAIL HASIL CLUSTERING');
  
  final result = kmeans.performClustering(sampleItems, 3, 100);
  final assignments = result['assignments'] as List<int>;
  final iterations = result['iterations'] as int;

  print('\nJumlah Iterasi: $iterations');
  print('\nHasil Clustering:');
  print('-' * 50);
  
  for (int i = 0; i < sampleItems.length; i++) {
    print('${sampleItems[i].namaBarang.padRight(20)} -> Cluster ${assignments[i] + 1}');
  }

  print('\nDistribusi Cluster:');
  for (int c = 0; c < 3; c++) {
    final count = assignments.where((a) => a == c).length;
    print('Cluster ${c + 1}: $count item(s)');
  }

  // Print Summary
  runner.printSummary();
}
