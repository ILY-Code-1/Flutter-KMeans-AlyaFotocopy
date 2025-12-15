import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../controllers/form_controller.dart';

class FormView extends GetView<UserFormController> {
  const FormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(
        title: 'Data Pengguna',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Responsive.isMobile(context)
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _buildFormCard(context),
          ),
          Gap.wXl,
          Expanded(
            flex: 2,
            child: Center(
              child: _buildIllustration(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIllustration(context),
        Gap.hLg,
        _buildFormCard(context),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Pengguna',
                style: AppTextStyles.h4,
              ),
              Gap.hSm,
              Text(
                'Lengkapi data berikut untuk melanjutkan proses analisis',
                style: AppTextStyles.bodySmall,
              ),
              Gap.hLg,
              CustomInput(
                label: 'Nama Lengkap',
                hint: 'Alya', // SAMPE SINI YUSNAR!!!
                controller: controller.namaController,
                validator: controller.validateNama,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              Gap.hMd,
              CustomInput(
                label: 'Email',
                hint: 'contoh@email.com',
                controller: controller.emailController,
                validator: controller.validateEmail,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              Gap.hXl,
              SizedBox(
                width: double.infinity,
                child: Obx(() => PrimaryButton(
                      text: 'Submit',
                      icon: Icons.send,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.submitForm,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          width: Responsive.value(
            context,
            mobile: 240,
            tablet: 320,
            desktop: 380,
          ),
          height: Responsive.value(
            context,
            mobile: 160,
            tablet: 220,
            desktop: 260,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/illustration_form.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
