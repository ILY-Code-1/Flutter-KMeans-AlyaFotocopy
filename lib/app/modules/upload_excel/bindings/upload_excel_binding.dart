import 'package:get/get.dart';
import '../controllers/upload_excel_controller.dart';

class UploadExcelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadExcelController>(
      () => UploadExcelController(),
    );
  }
}
