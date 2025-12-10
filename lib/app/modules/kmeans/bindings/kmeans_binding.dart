import 'package:get/get.dart';
import '../controllers/kmeans_controller.dart';

class KMeansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KMeansController>(() => KMeansController());
  }
}
