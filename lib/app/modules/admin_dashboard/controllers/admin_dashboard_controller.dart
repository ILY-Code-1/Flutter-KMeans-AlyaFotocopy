import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt totalUsers = 0.obs;
  final RxInt totalCalculations = 0.obs;
  final RxInt totalStaffUsers = 0.obs;
  final RxInt totalAdminUsers = 0.obs;
  final RxInt totalItems = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Fetch total users
      final usersSnapshot = await _firestore.collection('users').get();
      totalUsers.value = usersSnapshot.docs.length;

      // Count staff and admin users
      int staffCount = 0;
      int adminCount = 0;

      for (var doc in usersSnapshot.docs) {
        final role = doc.data()['role'] ?? 'staff';
        if (role == 'admin') {
          adminCount++;
        } else {
          staffCount++;
        }
      }

      totalStaffUsers.value = staffCount;
      totalAdminUsers.value = adminCount;

      // Fetch total calculations
      final calculationsSnapshot = await _firestore
          .collection('kmeans_results')
          .get();
      totalCalculations.value = calculationsSnapshot.docs.length;

      // Fetch total items
      final itemsSnapshot = await _firestore.collection('items').get();
      totalItems.value = itemsSnapshot.docs.length;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal memuat data dashboard: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }

  void navigateToUserManagement() {
    Get.toNamed('/user-management');
  }

  void navigateToHistory() {
    Get.toNamed('/history');
  }
}
