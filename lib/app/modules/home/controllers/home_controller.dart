import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_navbar.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final isLoading = false.obs;
  
  final ScrollController scrollController = ScrollController();
  
  final GlobalKey heroKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey guideKey = GlobalKey();

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
  
  // Get menu items berdasarkan role user
  List<NavMenuItem> getMenuItems() {
    if (_authService.isAdmin) {
      // Menu untuk admin
      return [
        NavMenuItem(label: 'Kelola User', onTap: navigateToUserManagement),
        NavMenuItem(label: 'Riwayat', onTap: navigateToHistory),
      ];
    } else {
      // Menu untuk staff (default)
      return [
        NavMenuItem(label: 'Beranda', onTap: scrollToHero),
        NavMenuItem(label: 'Tentang K-Means', onTap: scrollToAbout),
        NavMenuItem(label: 'Cara Penggunaan', onTap: scrollToGuide),
      ];
    }
  }
  
  void navigateToUserManagement() {
    Get.toNamed(Routes.userManagement);
  }
  
  void navigateToHistory() {
    Get.toNamed(Routes.history);
  }

  void navigateToKMeans() {
    Get.toNamed('/kmeans');
  }

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToHero() => scrollToSection(heroKey);
  void scrollToAbout() => scrollToSection(aboutKey);
  void scrollToGuide() => scrollToSection(guideKey);
  
  // Show logout confirmation dialog
  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 12),
            const Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              logout(); // Execute logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Ya, Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
  
  // Logout function
  Future<void> logout() async {
    isLoading.value = true;
    
    await _authService.logout();
    
    Get.snackbar(
      'Berhasil',
      'Anda telah keluar dari aplikasi',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
    
    // Navigate to login and clear all previous routes
    Get.offAllNamed(Routes.login);
    
    isLoading.value = false;
  }
}
