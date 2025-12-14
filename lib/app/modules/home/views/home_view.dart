import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(
        menuItems: [
          NavMenuItem(label: 'Beranda', onTap: controller.scrollToHero),
          NavMenuItem(label: 'Tentang K-Means', onTap: controller.scrollToAbout),
          NavMenuItem(label: 'Cara Penggunaan', onTap: controller.scrollToGuide),
        ],
      ),
      body: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          children: [
            // Section 1: Hero
            Container(
              key: controller.heroKey,
              child: ResponsiveContainer(
                child: Responsive.isMobile(context)
                    ? _buildHeroMobileLayout(context)
                    : _buildHeroDesktopLayout(context),
              ),
            ),
            
            // Section 2: Apa itu K-Means
            Container(
              key: controller.aboutKey,
              color: AppColors.softBlue,
              child: ResponsiveContainer(
                child: _buildAboutSection(context),
              ),
            ),
            
            // Section 3: Cara Penggunaan
            Container(
              key: controller.guideKey,
              child: ResponsiveContainer(
                child: _buildGuideSection(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildHeroContent(context)),
          Gap.wXl,
          Expanded(child: _buildHeroImage(context)),
        ],
      ),
    );
  }

  Widget _buildHeroMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          _buildHeroContent(context),
          Gap.hXl,
          _buildHeroImage(context),
        ],
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
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
      child: Column(
        crossAxisAlignment: Responsive.isMobile(context)
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            'Analisis K-Means\nClustering',
            style: Responsive.value(
              context,
              mobile: AppTextStyles.h2.copyWith(fontSize: 32),
              tablet: AppTextStyles.h2,
              desktop: AppTextStyles.h1,
            ),
            textAlign:
                Responsive.isMobile(context) ? TextAlign.center : TextAlign.left,
          ),
          Gap.hMd,
          Text(
            'Optimalkan manajemen stok fotocopy Anda dengan analisis clustering berbasis data. Identifikasi pola pemakaian dan tingkatkan efisiensi operasional.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign:
                Responsive.isMobile(context) ? TextAlign.center : TextAlign.left,
          ),
          Gap.hXl,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: Responsive.isMobile(context)
                ? WrapAlignment.center
                : WrapAlignment.start,
            children: [
              PrimaryButton(
                text: 'Mulai Analisis',
                icon: Icons.play_arrow,
                onPressed: controller.navigateToKMeans,
              ),
              PrimaryButton(
                text: 'Cara Penggunaan',
                isOutlined: true,
                icon: Icons.help_outline,
                onPressed: controller.scrollToGuide,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(50 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Center(
        child: Image.asset(
          'assets/images/hero_kmeans.png',
          width: Responsive.value(
            context,
            mobile: 280,
            tablet: 300,
            desktop: 340,
          ),
          height: Responsive.value(
            context,
            mobile: 200,
            tablet: 220,
            desktop: 240,
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: TweenAnimationBuilder<double>(
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
        child: Responsive.isMobile(context)
            ? _buildAboutMobileLayout(context)
            : _buildAboutDesktopLayout(context),
      ),
    );
  }

  Widget _buildAboutDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            width: 280,
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/illustration_kmeans.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Gap.wXl,
        Expanded(
          flex: 2,
          child: _buildAboutContent(context),
        ),
      ],
    );
  }

  Widget _buildAboutMobileLayout(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/illustration_kmeans.png',
            fit: BoxFit.contain,
          ),
        ),
        Gap.hLg,
        _buildAboutContent(context),
      ],
    );
  }

  Widget _buildAboutContent(BuildContext context) {
    return Column(
      crossAxisAlignment: Responsive.isMobile(context)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Apa itu K-Means?',
          style: Responsive.value(
            context,
            mobile: AppTextStyles.h3,
            desktop: AppTextStyles.h2,
          ),
          textAlign: Responsive.isMobile(context) ? TextAlign.center : TextAlign.left,
        ),
        Gap.hMd,
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'K-Means adalah algoritma unsupervised learning yang digunakan untuk mengelompokkan data ke dalam beberapa cluster berdasarkan pola dan kemiripan nilai.\n\nSetiap data akan dikelompokkan ke cluster yang memiliki jarak terdekat dengan titik pusat (centroid) dari cluster tersebut.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.8,
            ),
            textAlign: Responsive.isMobile(context) ? TextAlign.center : TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
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
            child: Column(
              children: [
                Text(
                  'Cara Penggunaan',
                  style: Responsive.value(
                    context,
                    mobile: AppTextStyles.h3,
                    desktop: AppTextStyles.h2,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap.hMd,
                Text(
                  'Ikuti langkah-langkah berikut untuk melakukan analisis K-Means Clustering',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Gap.hXl,
          _buildGuideSteps(context),
          Gap.hXl,
          PrimaryButton(
            text: 'Mulai Sekarang',
            icon: Icons.arrow_forward,
            onPressed: controller.navigateToKMeans,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSteps(BuildContext context) {
    final steps = [
      _GuideStepData(
        number: 1,
        title: 'Mulai Analisis',
        description: 'Klik tombol "Mulai Analisis" untuk memulai proses input data clustering.',
        icon: Icons.play_circle_outline,
        color: AppColors.softBlue,
      ),
      _GuideStepData(
        number: 2,
        title: 'Edit Inputan',
        description: 'Masukkan data item seperti nama barang, stok, dan parameter lainnya.',
        icon: Icons.edit_note,
        color: AppColors.softGreen,
      ),
      _GuideStepData(
        number: 3,
        title: 'Isi Nama & Email',
        description: 'Lengkapi informasi nama dan email untuk menerima hasil analisis via email.',
        icon: Icons.person_add_outlined,
        color: AppColors.softPurple,
      ),
      _GuideStepData(
        number: 4,
        title: 'Hasil Analisis',
        description: 'Lihat hasil clustering dan pengelompokan item berdasarkan pola pemakaian.',
        icon: Icons.analytics_outlined,
        color: AppColors.softOrange,
      ),
    ];

    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: steps.asMap().entries.map((entry) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (entry.key * 150)),
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildStepCard(entry.value),
            ),
          );
        }).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AppSpacing.lg) / 2;

        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: steps.asMap().entries.map((entry) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (entry.key * 150)),
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
              child: SizedBox(
                width: itemWidth,
                child: _buildStepCard(entry.value),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStepCard(_GuideStepData step) {
    return StepCard(
      stepNumber: step.number,
      title: step.title,
      description: step.description,
      icon: step.icon,
      backgroundColor: step.color,
    );
  }
}

class _GuideStepData {
  final int number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _GuideStepData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
