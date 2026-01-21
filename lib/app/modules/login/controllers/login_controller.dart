import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  // Auth Service
  final AuthService _authService = Get.find<AuthService>();
  
  // Text Editing Controllers for form inputs
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Form key untuk validasi
  final formKey = GlobalKey<FormState>();
  
  // Observable states
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Validasi username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    return null;
  }

  // Validasi password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 4) {
      return 'Password minimal 4 karakter';
    }
    return null;
  }

  // Sign in dengan Firebase
  Future<void> signIn() async {
    // Validasi form
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    // Hapus keyboard
    FocusScope.of(Get.context!).unfocus();
    
    isLoading.value = true;
    
    try {
      // Login via auth service
      final result = await _authService.login(
        usernameController.text.trim(),
        passwordController.text,
      );
      
      if (result['success'] == true) {
        // Login berhasil
        Get.snackbar(
          'Berhasil',
          result['message'],
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        
        // Navigasi berdasarkan role user
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Cek role user
        if (_authService.isAdmin) {
          // Jika admin, arahkan ke dashboard admin
          Get.offAllNamed(Routes.adminDashboard);
        } else {
          // Jika staff, arahkan ke home
          Get.offAllNamed(Routes.home);
        }
      } else {
        // Login gagal
        Get.snackbar(
          'Gagal',
          result['message'],
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
