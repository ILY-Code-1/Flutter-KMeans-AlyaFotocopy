import 'package:get/get.dart';
import '../controllers/item_management_controller.dart';

class ItemManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemManagementController>(
      () => ItemManagementController(),
    );
  }
}
