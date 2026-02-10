import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../services/auth_service.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_drawer.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlue,
      drawer: const AdminDrawer(currentRoute: '/admin-dashboard'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          'Dashboard Admin',
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshDashboard,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context),
              const SizedBox(height: 32),

              // Stats Cards
              Responsive.isMobile(context)
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(),

              const SizedBox(height: 32),

              // Quick Actions
              _buildQuickActions(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final authService = Get.find<AuthService>();
                    return Text(
                      'Admin ${authService.username}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Text(
                    'Kelola sistem K-Means Clustering',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo_alya.jpg',
                  width: 64,
                  height: 64,
                  fit: BoxFit
                      .cover, // Penting agar gambar memenuhi area lingkaran dengan rapi
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildStatCard(
          title: 'Total Perhitungan',
          value: controller.totalCalculations.value.toString(),
          icon: Icons.analytics_rounded,
          color: AppColors.primary,
          delay: 0,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Total User',
          value: controller.totalUsers.value.toString(),
          icon: Icons.people_rounded,
          color: AppColors.success,
          delay: 150,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Staff',
          value: controller.totalStaffUsers.value.toString(),
          icon: Icons.person_rounded,
          color: AppColors.warning,
          delay: 300,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Admin',
          value: controller.totalAdminUsers.value.toString(),
          icon: Icons.admin_panel_settings_rounded,
          color: AppColors.info,
          delay: 450,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Total Item',
          value: controller.totalItems.value.toString(),
          icon: Icons.inventory_2_rounded,
          color: AppColors.error,
          delay: 600,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Perhitungan',
                value: controller.totalCalculations.value.toString(),
                icon: Icons.analytics_rounded,
                color: AppColors.primary,
                delay: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total User',
                value: controller.totalUsers.value.toString(),
                icon: Icons.people_rounded,
                color: AppColors.success,
                delay: 150,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Staff',
                value: controller.totalStaffUsers.value.toString(),
                icon: Icons.person_rounded,
                color: AppColors.warning,
                delay: 300,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Admin',
                value: controller.totalAdminUsers.value.toString(),
                icon: Icons.admin_panel_settings_rounded,
                color: AppColors.info,
                delay: 450,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Item',
                value: controller.totalItems.value.toString(),
                icon: Icons.inventory_2_rounded,
                color: AppColors.error,
                delay: 600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Responsive.isMobile(context)
                ? Column(
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.people_rounded,
                        title: 'Kelola User',
                        subtitle: 'Tambah, edit, atau hapus user',
                        color: AppColors.primary,
                        onTap: controller.navigateToUserManagement,
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionButton(
                        icon: Icons.history_rounded,
                        title: 'Riwayat',
                        subtitle: 'Lihat semua perhitungan',
                        color: AppColors.success,
                        onTap: controller.navigateToHistory,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.people_rounded,
                          title: 'Kelola User',
                          subtitle: 'Tambah, edit, atau hapus user',
                          color: AppColors.primary,
                          onTap: controller.navigateToUserManagement,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.history_rounded,
                          title: 'Riwayat',
                          subtitle: 'Lihat semua perhitungan',
                          color: AppColors.success,
                          onTap: controller.navigateToHistory,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
