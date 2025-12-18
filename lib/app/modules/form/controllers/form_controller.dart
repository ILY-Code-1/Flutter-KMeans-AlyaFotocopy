import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class UserFormController extends GetxController {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? resultId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['resultId'] != null) {
      resultId = args['resultId'];
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    super.onClose();
  }

  String? validateNama(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      if (resultId == null) {
        throw Exception('Result ID tidak ditemukan');
      }

      // Fetch K-Means result from Firebase
      final doc = await _firestore.collection('kmeans_results').doc(resultId).get();

      if (!doc.exists) {
        throw Exception('Data hasil K-Means tidak ditemukan');
      }

      final kmeansData = doc.data()!;

      // Generate PDF
      final pdfBytes = await _generatePdf(
        nama: namaController.text,
        email: emailController.text,
        kmeansData: kmeansData,
      );

      // Download PDF
      await _downloadPdf(pdfBytes);

      // Send PDF via email using OMailer API
      await _sendPdfViaEmail(
        pdfBytes: pdfBytes,
        recipientEmail: emailController.text,
        recipientName: namaController.text,
      );

      Get.snackbar(
        'Berhasil',
        'Laporan PDF berhasil diunduh dan dikirim ke email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      Get.toNamed('/success');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Uint8List> _generatePdf({
    required String nama,
    required String email,
    required Map<String, dynamic> kmeansData,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateTime.parse(kmeansData['timestamp']);
    final formattedDate = _formatDateIndonesian(timestamp);

    // Extract data
    final totalItems = kmeansData['totalItems'] as int;
    final totalIterations = kmeansData['totalIterations'] as int;
    final itemResults = List<Map<String, dynamic>>.from(kmeansData['itemResults']);
    final recommendations = List<Map<String, dynamic>>.from(kmeansData['recommendations']);
    final rawData = List<Map<String, dynamic>>.from(kmeansData['rawData']);

    // Group items by cluster
    final cluster1Items = itemResults.where((item) => item['cluster'] == 1).toList();
    final cluster2Items = itemResults.where((item) => item['cluster'] == 2).toList();
    final cluster3Items = itemResults.where((item) => item['cluster'] == 3).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
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
                      pw.Text('Nama:'),
                      pw.Text(nama),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Email:'),
                      pw.Text(email),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tanggal Analisis:'),
                      pw.Text(formattedDate),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Barang:'),
                      pw.Text('$totalItems item'),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Iterasi:'),
                      pw.Text('$totalIterations iterasi'),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Section
            pw.Text('Ringkasan Hasil Clustering', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
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
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('C1')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Barang Cepat Habis')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${cluster1Items.length} item')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('C2')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Barang Kebutuhan Normal')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${cluster2Items.length} item')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('C3')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Barang Jarang Terpakai')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${cluster3Items.length} item')),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Data Table
            pw.Text('Data Barang dan Hasil Clustering', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildDataTable(rawData, itemResults),
            pw.SizedBox(height: 20),

            // Cluster Details
            pw.Text('Detail per Cluster', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // Cluster 1
            _buildClusterSection('Cluster 1 (C1): Barang Cepat Habis', cluster1Items, PdfColors.red100),
            pw.SizedBox(height: 10),

            // Cluster 2
            _buildClusterSection('Cluster 2 (C2): Barang Kebutuhan Normal', cluster2Items, PdfColors.yellow100),
            pw.SizedBox(height: 10),

            // Cluster 3
            _buildClusterSection('Cluster 3 (C3): Barang Jarang Terpakai', cluster3Items, PdfColors.green100),
            pw.SizedBox(height: 20),

            // Recommendations
            pw.Text('Rekomendasi', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildRecommendationsSection(recommendations),
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

    return pdf.save();
  }

  pw.Widget _buildDataTable(List<Map<String, dynamic>> rawData, List<Map<String, dynamic>> itemResults) {
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
            _tableHeader('No'),
            _tableHeader('Nama Barang'),
            _tableHeader('Jml Masuk'),
            _tableHeader('Jml Keluar'),
            _tableHeader('Rata2 Pakai'),
            _tableHeader('Frek Restock'),
            _tableHeader('Est. Habis'),
            _tableHeader('Fluktuasi'),
            _tableHeader('Cluster'),
          ],
        ),
        ...List.generate(rawData.length, (index) {
          final raw = rawData[index];
          final result = itemResults.firstWhere((r) => r['itemId'] == raw['id']);
          return pw.TableRow(
            children: [
              _tableCell('${index + 1}'),
              _tableCell(raw['namaBarang'].toString()),
              _tableCell(_formatNumber(raw['jumlahMasuk'])),
              _tableCell(_formatNumber(raw['jumlahKeluar'])),
              _tableCell(_formatDecimal(raw['rataRataPemakaian'])),
              _tableCell(_formatNumber(raw['frekuensiRestock'])),
              _tableCell(_formatDecimal(raw['dayToStockOut'])),
              _tableCell(_formatDecimal(raw['fluktuasiPemakaian'])),
              _tableCell('C${result['cluster']}'),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
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

  pw.Widget _buildClusterSection(String title, List<Map<String, dynamic>> items, PdfColor bgColor) {
    if (items.isEmpty) {
      return pw.Container(
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
            pw.Text('Tidak ada barang dalam cluster ini', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      );
    }

    return pw.Container(
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
          pw.Text('Barang: ${items.map((e) => e['namaBarang']).join(', ')}', style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildRecommendationsSection(List<Map<String, dynamic>> recommendations) {
    // Group by cluster
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (var rec in recommendations) {
      final cluster = rec['cluster'] as int;
      grouped.putIfAbsent(cluster, () => []).add(rec);
    }

    List<pw.Widget> sections = [];

    if (grouped.containsKey(1)) {
      sections.add(_buildRecommendationBox(
        'Cluster 1 - Barang Cepat Habis (Prioritas Tinggi)',
        grouped[1]!.first['recommendation'],
        grouped[1]!.map((e) => e['namaBarang'] as String).toList(),
        PdfColors.red100,
      ));
    }

    if (grouped.containsKey(2)) {
      sections.add(pw.SizedBox(height: 10));
      sections.add(_buildRecommendationBox(
        'Cluster 2 - Barang Kebutuhan Normal (Prioritas Sedang)',
        grouped[2]!.first['recommendation'],
        grouped[2]!.map((e) => e['namaBarang'] as String).toList(),
        PdfColors.yellow100,
      ));
    }

    if (grouped.containsKey(3)) {
      sections.add(pw.SizedBox(height: 10));
      sections.add(_buildRecommendationBox(
        'Cluster 3 - Barang Jarang Terpakai (Prioritas Rendah)',
        grouped[3]!.first['recommendation'],
        grouped[3]!.map((e) => e['namaBarang'] as String).toList(),
        PdfColors.green100,
      ));
    }

    return pw.Column(children: sections);
  }

  pw.Widget _buildRecommendationBox(String title, String recommendation, List<String> items, PdfColor bgColor) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(5),
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 5),
          pw.Text('Barang: ${items.join(', ')}', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 5),
          pw.Text('Rekomendasi:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          pw.Text(recommendation, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(Uint8List pdfBytes) async {
    final now = DateTime.now();
    final fileName = 'Laporan_KMeans_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.pdf';

    if (kIsWeb) {
      // For web, use printing package to trigger download
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } else {
      // For mobile/desktop
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Also trigger share/print dialog
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    }
  }

  String _formatDateIndonesian(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _sendPdfViaEmail({
    required Uint8List pdfBytes,
    required String recipientEmail,
    required String recipientName,
  }) async {
    const String apiUrl = 'https://yusnar.my.id/omailer/send';

    final now = DateTime.now();
    final fileName = 'Laporan_KMeans_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.pdf';

    final bodyHtml = '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width" />
  </head>
  <body style="font-family: Arial, sans-serif; margin:0; padding:0; color:#333;">
    <table role="presentation" style="width:100%; border-collapse:collapse;">
      <tr>
        <td align="center" style="padding:20px 10px; background:#f6f6f6;">
          <table role="presentation" style="max-width:600px; width:100%; background:#ffffff; border-radius:8px; overflow:hidden;">
            <tr>
              <td style="padding:20px; text-align:center; background:#0d6efd; color:#fff;">
                <h1 style="margin:0; font-size:22px;">Laporan Hasil Analisis K-Means Clustering</h1>
                <p style="margin:6px 0 0; font-size:14px; opacity:0.9;">Klasifikasi Persediaan Barang by Alya Fotocopy</p>
              </td>
            </tr>
            <tr>
              <td style="padding:20px;">
                <p>Halo <strong>$recipientName</strong>,</p>
                <p>
                  Terima kasih telah menggunakan layanan K-Means Clustering. Berikut terlampir laporan hasil analisis Anda.
                </p>
                <ul>
                  <li>Laporan berisi klasifikasi persediaan barang</li>
                  <li>Rekomendasi pengelolaan stok untuk setiap cluster</li>
                  <li>Detail perhitungan dan hasil clustering</li>
                </ul>
                <p>
                  Silakan buka file PDF yang terlampir untuk melihat laporan lengkap.
                </p>
                <p style="margin-top:24px;">Salam,<br/>Tim K-Means Clustering</p>
              </td>
            </tr>
            <tr>
              <td style="padding:12px; text-align:center; font-size:12px; color:#777; background:#fafafa;">
                Email ini dikirim secara otomatis. Jika Anda tidak melakukan permintaan ini, abaikan saja.
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
''';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['smtp_host'] = 'smtp.gmail.com';
      request.fields['smtp_port'] = '465';
      request.fields['auth_email'] = 'anggeliawijayanti90@gmail.com';
      request.fields['auth_password'] = 'khov wuvu gcah wagy';
      request.fields['sender_name'] = 'K-Means Clustering';
      request.fields['recipient'] = recipientEmail;
      request.fields['subject'] = 'Laporan Hasil Analisis K-Means Clustering';
      request.fields['body_html'] = bodyHtml;

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: fileName,
      ));

      final response = await request.send();

      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Gagal mengirim email: $responseBody');
      }
    } catch (e) {
      Get.snackbar(
        'Peringatan',
        'PDF berhasil diunduh, tetapi gagal mengirim email: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
