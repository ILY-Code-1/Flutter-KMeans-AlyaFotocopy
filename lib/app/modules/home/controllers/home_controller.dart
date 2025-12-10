import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  
  final ScrollController scrollController = ScrollController();
  
  final GlobalKey heroKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey guideKey = GlobalKey();

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void navigateToKMeans() {
    Get.toNamed('/kmeans');
  }

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToHero() => scrollToSection(heroKey);
  void scrollToAbout() => scrollToSection(aboutKey);
  void scrollToGuide() => scrollToSection(guideKey);
}
