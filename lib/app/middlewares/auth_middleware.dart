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
    
    // Jika belum login, redirect ke login page
    if (!authService.isAuthenticated) {
      return const RouteSettings(name: Routes.login);
    }
    
    // Jika sudah login, lanjutkan ke route yang dituju
    return null;
  }
}
