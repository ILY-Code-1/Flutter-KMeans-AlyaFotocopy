import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../services/auth_service.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_alya.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit
                            .cover, // Penting agar gambar memenuhi area lingkaran dengan rapi
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authService.username,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Administrator',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerMenuItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isActive: currentRoute == '/admin-dashboard',
                    onTap: () {
                      Get.back();
                      if (currentRoute != '/admin-dashboard') {
                        Get.offNamed('/admin-dashboard');
                      }
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.people_rounded,
                    title: 'Kelola User',
                    isActive: currentRoute == '/user-management',
                    onTap: () {
                      Get.back();
                      if (currentRoute != '/user-management') {
                        Get.toNamed('/user-management');
                      }
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.inventory_2_rounded,
                    title: 'Kelola Item',
                    isActive: currentRoute == '/item-management',
                    onTap: () {
                      Get.back();
                      if (currentRoute != '/item-management') {
                        Get.toNamed('/item-management');
                      }
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Riwayat',
                    isActive: currentRoute == '/history',
                    onTap: () {
                      Get.back();
                      if (currentRoute != '/history') {
                        Get.toNamed('/history');
                      }
                    },
                  ),
                ],
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: AppColors.textSecondary.withOpacity(0.2),
                thickness: 1,
              ),
            ),

            // Logout
            _DrawerMenuItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              isActive: false,
              isLogout: true,
              onTap: () {
                Get.back();
                _showLogoutDialog(context, authService);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
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
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await authService.logout();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
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
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isLogout;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.isActive,
    this.isLogout = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLogout
        ? AppColors.error
        : isActive
        ? AppColors.primary
        : AppColors.textSecondary;

    final backgroundColor = isActive
        ? AppColors.primary.withOpacity(0.1)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 24),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
