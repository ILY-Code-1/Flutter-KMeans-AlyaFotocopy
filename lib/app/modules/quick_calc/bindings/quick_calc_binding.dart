import 'package:get/get.dart';
import '../controllers/quick_calc_controller.dart';

class QuickCalcBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuickCalcController>(
      () => QuickCalcController(),
    );
  }
}
