import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/kmeans/bindings/kmeans_binding.dart';
import '../modules/kmeans/views/kmeans_view.dart';
import '../modules/form/bindings/form_binding.dart';
import '../modules/form/views/form_view.dart';
import '../modules/success/views/success_view.dart';
import '../modules/guide/bindings/guide_binding.dart';
import '../modules/guide/views/guide_view.dart';
import '../modules/user_management/bindings/user_management_binding.dart';
import '../modules/user_management/views/user_management_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../middlewares/auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.kmeans,
      page: () => const KMeansView(),
      binding: KMeansBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.form,
      page: () => const FormView(),
      binding: FormBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.success,
      page: () => const SuccessView(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 400),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.guide,
      page: () => const GuideView(),
      binding: GuideBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.userManagement,
      page: () => const UserManagementView(),
      binding: UserManagementBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.history,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
