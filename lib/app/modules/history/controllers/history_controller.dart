import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final isLoading = false.obs;
  final results = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchResults();
  }
  
  // Fetch semua hasil analisis K-Means dari Firebase
  Future<void> fetchResults() async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await _firestore
          .collection('kmeans_results')
          .orderBy('timestamp', descending: true)
          .get();
      
      results.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data riwayat: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Format timestamp ke string yang readable
  String formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return '-';
      
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return '-';
      }
      
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }
  
  // Show detail dialog
  void showDetailDialog(Map<String, dynamic> result) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 800,
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Close button at top right
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    tooltip: 'Tutup',
                  ),
                ),
              ),
              
              // Content - PDF-like layout
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header - Like PDF
                        const Center(
                          child: Text(
                            'LAPORAN HASIL ANALISIS K-MEANS CLUSTERING',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Center(
                          child: Text(
                            'Klasifikasi Persediaan Barang by Alya Fotocopy',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF424242),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Info Section - Like PDF
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informasi Laporan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              _buildInfoRow('Tanggal Analisis:', formatTimestamp(result['timestamp'])),
                              const SizedBox(height: 5),
                              _buildInfoRow('Total Barang:', '${result['totalItems'] ?? 0} item'),
                              const SizedBox(height: 5),
                              _buildInfoRow('Total Iterasi:', '${result['iterations'] ?? 0} iterasi'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Summary Section - Like PDF
                        const Text(
                          'Ringkasan Hasil Clustering',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Summary Table - Like PDF
                        _buildClusterSummaryTable(result),
                        const SizedBox(height: 20),
                        
                        // Data Table - Like PDF
                        if (result['rawData'] != null && result['itemResults'] != null) ...[
                          const Text(
                            'Data Barang dan Hasil Clustering',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildDataTable(result),
                          const SizedBox(height: 20),
                        ],
                        
                        // Clusters Detail - Like PDF
                        const Text(
                          'Detail per Cluster',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        ...((result['itemResults'] as List? ?? []).fold<Map<int, List<Map<String, dynamic>>>>(
                          {},
                          (map, item) {
                            final cluster = item['cluster'] as int;
                            if (!map.containsKey(cluster)) {
                              map[cluster] = [];
                            }
                            map[cluster]!.add(item as Map<String, dynamic>);
                            return map;
                          },
                        ).entries.map((entry) {
                          final clusterNum = entry.key;
                          final items = entry.value;
                          
                          String title;
                          Color bgColor;
                          
                          switch (clusterNum) {
                            case 1:
                              title = 'Cluster 1 (C1): Barang Cepat Habis';
                              bgColor = const Color(0xFFFFCDD2); // red100
                              break;
                            case 2:
                              title = 'Cluster 2 (C2): Barang Kebutuhan Normal';
                              bgColor = const Color(0xFFFFF9C4); // yellow100
                              break;
                            case 3:
                              title = 'Cluster 3 (C3): Barang Jarang Terpakai';
                              bgColor = const Color(0xFFC8E6C9); // green100
                              break;
                            default:
                              title = 'Cluster $clusterNum';
                              bgColor = Colors.grey.shade200;
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Barang: ${items.map((e) => e['namaBarang']).join(', ')}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList()),
                        
                        // Recommendations - Like PDF
                        if (result['recommendations'] != null) ...[
                          const Text(
                            'Rekomendasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildRecommendationsSection(result),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      label: const Text('Tutup'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        downloadPDF(result);
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
  
  // Build info row for detail view
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  // Build cluster summary table
  Widget _buildClusterSummaryTable(Map<String, dynamic> result) {
    final itemResults = result['itemResults'] as List? ?? [];
    final cluster1Count = itemResults.where((item) => item['cluster'] == 1).length;
    final cluster2Count = itemResults.where((item) => item['cluster'] == 2).length;
    final cluster3Count = itemResults.where((item) => item['cluster'] == 3).length;
    
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            _buildTableHeader('Cluster'),
            _buildTableHeader('Kategori'),
            _buildTableHeader('Jumlah Barang'),
          ],
        ),
        _buildSummaryRow('C1', 'Barang Cepat Habis', '$cluster1Count item'),
        _buildSummaryRow('C2', 'Barang Kebutuhan Normal', '$cluster2Count item'),
        _buildSummaryRow('C3', 'Barang Jarang Terpakai', '$cluster3Count item'),
      ],
    );
  }
  
  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
  
  TableRow _buildSummaryRow(String cluster, String category, String count) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Text(cluster, style: const TextStyle(fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Text(category, style: const TextStyle(fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Text(count, style: const TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
  
  // Build data table
  Widget _buildDataTable(Map<String, dynamic> result) {
    final rawData = result['rawData'] as List? ?? [];
    final itemResults = result['itemResults'] as List? ?? [];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade400),
        columnWidths: const {
          0: FixedColumnWidth(40),
          1: FixedColumnWidth(150),
          2: FixedColumnWidth(80),
          3: FixedColumnWidth(80),
          4: FixedColumnWidth(80),
          5: FixedColumnWidth(80),
          6: FixedColumnWidth(80),
          7: FixedColumnWidth(80),
          8: FixedColumnWidth(60),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: [
              _buildDataTableHeader('No'),
              _buildDataTableHeader('Nama Barang'),
              _buildDataTableHeader('Jml Masuk'),
              _buildDataTableHeader('Jml Keluar'),
              _buildDataTableHeader('Rata2 Pakai'),
              _buildDataTableHeader('Frek Restock'),
              _buildDataTableHeader('Est. Habis'),
              _buildDataTableHeader('Fluktuasi'),
              _buildDataTableHeader('Cluster'),
            ],
          ),
          ...List.generate(rawData.length, (index) {
            final raw = rawData[index] as Map<String, dynamic>;
            final itemResult = itemResults.firstWhere(
              (r) => r['itemId'] == raw['id'],
              orElse: () => {'cluster': 0},
            );
            
            return TableRow(
              children: [
                _buildDataTableCell('${index + 1}'),
                _buildDataTableCell(raw['namaBarang']?.toString() ?? '-'),
                _buildDataTableCell(_formatNumber(raw['jumlahMasuk'])),
                _buildDataTableCell(_formatNumber(raw['jumlahKeluar'])),
                _buildDataTableCell(_formatDecimal(raw['rataRataPemakaian'])),
                _buildDataTableCell(_formatNumber(raw['frekuensiRestock'])),
                _buildDataTableCell(_formatDecimal(raw['dayToStockOut'])),
                _buildDataTableCell(_formatDecimal(raw['fluktuasiPemakaian'])),
                _buildDataTableCell('C${itemResult['cluster']}'),
              ],
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildDataTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildDataTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 8),
      ),
    );
  }
  
  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    return (value as num).toInt().toString();
  }
  
  String _formatDecimal(dynamic value) {
    if (value == null) return '0.00';
    return (value as num).toStringAsFixed(2);
  }
  
  // Build recommendations section
  Widget _buildRecommendationsSection(Map<String, dynamic> result) {
    final recommendations = result['recommendations'] as List? ?? [];
    
    if (recommendations.isEmpty) {
      return const Text(
        'Tidak ada rekomendasi',
        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recommendations.asMap().entries.map((entry) {
        final index = entry.key;
        final rec = entry.value as Map<String, dynamic>;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  rec['recommendation']?.toString() ?? '-',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Color _getClusterColor(int index) {
    final colors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFFF44336), // Red
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
    ];
    return colors[index % colors.length];
  }
  
  // Download PDF
  Future<void> downloadPDF(Map<String, dynamic> result) async {
    try {
      isLoading.value = true;
      
      final pdf = pw.Document();
      final rawData = result['rawData'] as List? ?? [];
      final itemResults = result['itemResults'] as List? ?? [];
      final recommendations = result['recommendations'] as List? ?? [];
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header - Centered
              pw.Center(
                child: pw.Text(
                  'LAPORAN HASIL ANALISIS K-MEANS CLUSTERING',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Klasifikasi Persediaan Barang by Alya Fotocopy',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Info Section
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Informasi Laporan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Tanggal Analisis:'),
                        pw.Text(formatTimestamp(result['timestamp'])),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Barang:'),
                        pw.Text('${result['totalItems'] ?? 0} item'),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Iterasi:'),
                        pw.Text('${result['iterations'] ?? 0} iterasi'),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Summary Section
              pw.Text('Ringkasan Hasil Clustering', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildPdfClusterSummaryTable(itemResults),
              pw.SizedBox(height: 20),
              
              // Data Table
              if (rawData.isNotEmpty && itemResults.isNotEmpty) ...[
                pw.Text('Data Barang dan Hasil Clustering', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildPdfDataTable(rawData, itemResults),
                pw.SizedBox(height: 20),
              ],
              
              // Cluster Details
              pw.Text('Detail per Cluster', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              
              ...itemResults.fold<Map<int, List<Map<String, dynamic>>>>(
                {},
                (map, item) {
                  final cluster = item['cluster'] as int;
                  if (!map.containsKey(cluster)) {
                    map[cluster] = [];
                  }
                  map[cluster]!.add(item as Map<String, dynamic>);
                  return map;
                },
              ).entries.map((entry) {
                final clusterNum = entry.key;
                final items = entry.value;
                
                String title;
                PdfColor bgColor;
                
                switch (clusterNum) {
                  case 1:
                    title = 'Cluster 1 (C1): Barang Cepat Habis';
                    bgColor = PdfColors.red100;
                    break;
                  case 2:
                    title = 'Cluster 2 (C2): Barang Kebutuhan Normal';
                    bgColor = PdfColors.yellow100;
                    break;
                  case 3:
                    title = 'Cluster 3 (C3): Barang Jarang Terpakai';
                    bgColor = PdfColors.green100;
                    break;
                  default:
                    title = 'Cluster $clusterNum';
                    bgColor = PdfColors.grey200;
                }
                
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: bgColor,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Barang: ${items.map((e) => e['namaBarang']).join(', ')}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
              
              // Recommendations
              if (recommendations.isNotEmpty) ...[
                pw.Text('Rekomendasi', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...recommendations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rec = entry.value as Map<String, dynamic>;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 5),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${index + 1}. ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Expanded(
                          child: pw.Text(rec['recommendation']?.toString() ?? '-', style: const pw.TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            );
          },
        ),
      );
      
      // Print/Save PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      
      Get.snackbar(
        'Berhasil',
        'PDF berhasil diunduh',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengunduh PDF: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Build cluster summary table for PDF
  pw.Widget _buildPdfClusterSummaryTable(List itemResults) {
    final cluster1Count = itemResults.where((item) => item['cluster'] == 1).length;
    final cluster2Count = itemResults.where((item) => item['cluster'] == 2).length;
    final cluster3Count = itemResults.where((item) => item['cluster'] == 3).length;
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Cluster', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Kategori', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Jumlah Barang', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        _buildPdfSummaryRow('C1', 'Barang Cepat Habis', '$cluster1Count item'),
        _buildPdfSummaryRow('C2', 'Barang Kebutuhan Normal', '$cluster2Count item'),
        _buildPdfSummaryRow('C3', 'Barang Jarang Terpakai', '$cluster3Count item'),
      ],
    );
  }
  
  pw.TableRow _buildPdfSummaryRow(String cluster, String category, String count) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(cluster)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(category)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(count)),
      ],
    );
  }
  
  // Build data table for PDF
  pw.Widget _buildPdfDataTable(List rawData, List itemResults) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(1),
        7: const pw.FlexColumnWidth(1),
        8: const pw.FlexColumnWidth(0.8),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildPdfTableHeader('No'),
            _buildPdfTableHeader('Nama Barang'),
            _buildPdfTableHeader('Jml Masuk'),
            _buildPdfTableHeader('Jml Keluar'),
            _buildPdfTableHeader('Rata2 Pakai'),
            _buildPdfTableHeader('Frek Restock'),
            _buildPdfTableHeader('Est. Habis'),
            _buildPdfTableHeader('Fluktuasi'),
            _buildPdfTableHeader('Cluster'),
          ],
        ),
        ...List.generate(rawData.length, (index) {
          final raw = rawData[index] as Map<String, dynamic>;
          final result = itemResults.firstWhere(
            (r) => r['itemId'] == raw['id'],
            orElse: () => {'cluster': 0},
          );
          return pw.TableRow(
            children: [
              _buildPdfTableCell('${index + 1}'),
              _buildPdfTableCell(raw['namaBarang']?.toString() ?? '-'),
              _buildPdfTableCell(_formatNumber(raw['jumlahMasuk'])),
              _buildPdfTableCell(_formatNumber(raw['jumlahKeluar'])),
              _buildPdfTableCell(_formatDecimal(raw['rataRataPemakaian'])),
              _buildPdfTableCell(_formatNumber(raw['frekuensiRestock'])),
              _buildPdfTableCell(_formatDecimal(raw['dayToStockOut'])),
              _buildPdfTableCell(_formatDecimal(raw['fluktuasiPemakaian'])),
              _buildPdfTableCell('C${result['cluster']}'),
            ],
          );
        }),
      ],
    );
  }
  
  pw.Widget _buildPdfTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
    );
  }
  
  pw.Widget _buildPdfTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
    );
  }

  
  // Delete result
  void deleteResult(String resultId, String timestamp) {
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
          'Apakah Anda yakin ingin menghapus riwayat analisis "${formatTimestamp(timestamp)}"?\n\nData yang dihapus tidak dapat dikembalikan.',
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
              await _deleteResultConfirmed(resultId);
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
  
  Future<void> _deleteResultConfirmed(String resultId) async {
    try {
      isLoading.value = true;
      
      await _firestore.collection('kmeans_results').doc(resultId).delete();
      
      Get.snackbar(
        'Berhasil',
        'Riwayat berhasil dihapus',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );
      
      // Refresh list
      await fetchResults();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus riwayat: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
