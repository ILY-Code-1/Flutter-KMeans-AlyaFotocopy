import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final isLoading = false.obs;
  final users = <Map<String, dynamic>>[].obs;
  
  // Controllers untuk form
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final roleController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  // Observable untuk form
  final selectedRole = 'staff'.obs;
  final isActive = true.obs;
  final isPasswordVisible = false.obs;
  
  // Mode edit atau tambah
  String? editingUserId;
  
  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }
  
  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    roleController.dispose();
    super.onClose();
  }
  
  // Fetch semua users dari Firebase
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('username')
          .get();
      
      users.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data user: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  // Show form dialog untuk tambah/edit user
  void showUserFormDialog({Map<String, dynamic>? user}) {
    // Reset form
    if (user == null) {
      // Mode tambah
      editingUserId = null;
      usernameController.clear();
      passwordController.clear();
      selectedRole.value = 'staff';
      isActive.value = true;
    } else {
      // Mode edit
      editingUserId = user['id'];
      usernameController.text = user['username'] ?? '';
      passwordController.text = user['password'] ?? '';
      selectedRole.value = user['role'] ?? 'staff';
      isActive.value = user['isActive'] ?? true;
    }
    
    isPasswordVisible.value = false;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  editingUserId == null ? 'Tambah User Baru' : 'Edit User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Username field
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    if (value.length < 3) {
                      return 'Username minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password field
                Obx(() => TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (editingUserId == null) {
                      // Validasi untuk mode tambah
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 4) {
                        return 'Password minimal 4 karakter';
                      }
                    } else {
                      // Validasi untuk mode edit (optional)
                      if (value != null && value.isNotEmpty && value.length < 4) {
                        return 'Password minimal 4 karakter';
                      }
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),
                
                // Role dropdown
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedRole.value,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole.value = value;
                    }
                  },
                )),
                const SizedBox(height: 16),
                
                // Status Active checkbox
                Obx(() => CheckboxListTile(
                  title: const Text('Akun Aktif'),
                  value: isActive.value,
                  onChanged: (value) {
                    isActive.value = value ?? true;
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => saveUser(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(editingUserId == null ? 'Tambah' : 'Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  // Save user (Create or Update)
  Future<void> saveUser() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      isLoading.value = true;
      
      final userData = {
        'username': usernameController.text.trim(),
        'role': selectedRole.value,
        'isActive': isActive.value,
      };
      
      // Jika ada password yang diisi, tambahkan ke userData
      if (passwordController.text.isNotEmpty) {
        userData['password'] = passwordController.text;
      }
      
      if (editingUserId == null) {
        // Create new user
        await _firestore.collection('users').add(userData);
        
        Get.back(); // Close dialog
        
        Get.snackbar(
          'Berhasil',
          'User berhasil ditambahkan',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // Update existing user
        await _firestore
            .collection('users')
            .doc(editingUserId)
            .update(userData);
        
        Get.back(); // Close dialog
        
        Get.snackbar(
          'Berhasil',
          'User berhasil diperbarui',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );
      }
      
      // Refresh list
      await fetchUsers();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan user: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete user
  void deleteUser(String userId, String username) {
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
          'Apakah Anda yakin ingin menghapus user "$username"?',
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
              await _deleteUserConfirmed(userId);
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
  
  Future<void> _deleteUserConfirmed(String userId) async {
    try {
      isLoading.value = true;
      
      await _firestore.collection('users').doc(userId).delete();
      
      Get.snackbar(
        'Berhasil',
        'User berhasil dihapus',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
      );
      
      // Refresh list
      await fetchUsers();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus user: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
