import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserFormController extends GetxController {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

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

  void submitForm() {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    // generate pdf
    // send via email

    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      Get.toNamed('/success');
    });
  }
}
