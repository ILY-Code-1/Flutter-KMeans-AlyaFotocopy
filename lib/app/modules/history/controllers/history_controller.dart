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
          width: 700,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF7AB8F5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Hasil Analisis',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatTimestamp(result['timestamp']),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 32),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Total Items',
                              '${result['totalItems'] ?? 0}',
                              Icons.inventory_2_outlined,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              'Iterasi',
                              '${result['iterations'] ?? 0}',
                              Icons.refresh,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              'Clusters',
                              '${result['clusters']?.length ?? 0}',
                              Icons.group_work,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // User Info
                      if (result['userName'] != null || result['userEmail'] != null) ...[
                        const Text(
                          'Informasi Pengguna',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              if (result['userName'] != null)
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 20, color: Colors.grey.shade700),
                                    const SizedBox(width: 8),
                                    Text('Nama: ${result['userName']}'),
                                  ],
                                ),
                              if (result['userEmail'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.email, size: 20, color: Colors.grey.shade700),
                                    const SizedBox(width: 8),
                                    Text('Email: ${result['userEmail']}'),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Clusters Detail
                      if (result['clusters'] != null) ...[
                        const Text(
                          'Detail Cluster',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...((result['clusters'] as List).asMap().entries.map((entry) {
                          final index = entry.key;
                          final cluster = entry.value as Map<String, dynamic>;
                          final items = cluster['items'] as List? ?? [];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getClusterColor(index).withOpacity(0.1),
                                  _getClusterColor(index).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getClusterColor(index).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getClusterColor(index),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        cluster['label'] ?? 'Cluster ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${items.length} items',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (items.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  ...items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: _getClusterColor(index),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item['name'] ?? '-',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ],
                            ),
                          );
                        }).toList()),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup'),
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
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
  
  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
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
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Hasil Analisis K-Means Clustering',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Tanggal: ${formatTimestamp(result['timestamp'])}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Summary
              pw.Text(
                'Ringkasan',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  _buildPdfTableRow('Total Items', '${result['totalItems'] ?? 0}'),
                  _buildPdfTableRow('Iterasi', '${result['iterations'] ?? 0}'),
                  _buildPdfTableRow('Jumlah Cluster', '${result['clusters']?.length ?? 0}'),
                  if (result['userName'] != null)
                    _buildPdfTableRow('Nama', result['userName']),
                  if (result['userEmail'] != null)
                    _buildPdfTableRow('Email', result['userEmail']),
                ],
              ),
              pw.SizedBox(height: 24),
              
              // Clusters
              pw.Text(
                'Detail Cluster',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              
              ...((result['clusters'] as List? ?? []).asMap().entries.map((entry) {
                final index = entry.key;
                final cluster = entry.value as Map<String, dynamic>;
                final items = cluster['items'] as List? ?? [];
                
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            cluster['label'] ?? 'Cluster ${index + 1}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Text(
                            '(${items.length} items)',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...items.map((item) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 6,
                              height: 6,
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.blue,
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Text(
                              item['name'] ?? '-',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    pw.SizedBox(height: 16),
                  ],
                );
              }).toList()),
            ];
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
  
  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
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
