import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuideStep {
  final int number;
  final String title;
  final String description;
  final IconData icon;

  GuideStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class GuideController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  final List<Animation<double>> animations = [];

  final steps = <GuideStep>[
    GuideStep(
      number: 1,
      title: 'Mulai Analisis',
      description: 'Klik tombol "Mulai Analisis" di halaman utama untuk memulai proses input data clustering.',
      icon: Icons.play_circle_outline,
    ),
    GuideStep(
      number: 2,
      title: 'Edit Inputan',
      description: 'Masukkan data item seperti nama barang, stok, jumlah masuk/keluar, dan parameter lainnya. Anda dapat menambah, mengedit, atau menghapus data sesuai kebutuhan.',
      icon: Icons.edit_note,
    ),
    GuideStep(
      number: 3,
      title: 'Isi Nama & Email',
      description: 'Lengkapi informasi nama dan email Anda untuk menerima hasil analisis dan notifikasi terkait.',
      icon: Icons.person_add_outlined,
    ),
    GuideStep(
      number: 4,
      title: 'Hasil Analisis',
      description: 'Setelah data diproses, hasil clustering akan ditampilkan. Anda dapat melihat pengelompokan item berdasarkan pola pemakaian.',
      icon: Icons.analytics_outlined,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create staggered animations for each step
    for (int i = 0; i < steps.length; i++) {
      final start = i * 0.2;
      final end = start + 0.4;
      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
          ),
        ),
      );
    }

    animationController.forward();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void navigateToKMeans() {
    Get.toNamed('/kmeans');
  }
}
