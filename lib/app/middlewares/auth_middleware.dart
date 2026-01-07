import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_pages.dart';

/// Middleware untuk proteksi route yang membutuhkan autentikasi
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // Jika belum login atau session expired, redirect ke login page
    if (!authService.isAuthenticated) {
      // Tampilkan notifikasi jika sebelumnya ada user yang login (session expired)
      if (authService.currentUsername.value.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            'Session Expired',
            'Session Anda telah berakhir. Silakan login kembali.',
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade900,
            duration: const Duration(seconds: 3),
          );
        });
      }
      
      return const RouteSettings(name: Routes.login);
    }
    
    // Jika sudah login, lanjutkan ke route yang dituju
    return null;
  }
}
