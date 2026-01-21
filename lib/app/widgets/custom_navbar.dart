import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/themes.dart';
import '../core/responsive/responsive.dart';

class NavMenuItem {
  final String label;
  final VoidCallback onTap;

  NavMenuItem({required this.label, required this.onTap});
}

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<NavMenuItem>? menuItems;

  const CustomNavbar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.menuItems,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Container(
      height: preferredSize.height,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context,
          mobile: AppSpacing.md,
          tablet: AppSpacing.lg,
          desktop: AppSpacing.xl,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ResponsiveContainer(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed ?? () => Get.back(),
              ),
            // Logo placeholder - 40x40
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Image(
                image: AssetImage('assets/images/logo.png'),
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (!isMobile || title != null)
              Text(
                title ?? 'K-Means Alya Fotocopy',
                style: AppTextStyles.h5.copyWith(fontSize: isMobile ? 16 : 20),
              ),
            const Spacer(),
            if (menuItems != null && !isMobile) ...[
              if (isTablet)
                _buildMobileMenu(context)
              else
                ..._buildMenuItems(context),
            ],
            if (menuItems != null && isMobile) _buildMobileMenu(context),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return menuItems!.map((item) {
      return _NavMenuButton(label: item.label, onTap: item.onTap);
    }).toList();
  }

  Widget _buildMobileMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.menu, color: AppColors.textPrimary),
      onSelected: (index) {
        menuItems![index].onTap();
      },
      itemBuilder: (context) {
        return menuItems!.asMap().entries.map((entry) {
          return PopupMenuItem<int>(
            value: entry.key,
            child: Text(entry.value.label, style: AppTextStyles.bodyMedium),
          );
        }).toList();
      },
    );
  }
}

class _NavMenuButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavMenuButton({required this.label, required this.onTap});

  @override
  State<_NavMenuButton> createState() => _NavMenuButtonState();
}

class _NavMenuButtonState extends State<_NavMenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: _isHovered ? AppColors.primary : AppColors.textPrimary,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
