import 'package:get/get.dart';

import '../../connect/views/connect_view.dart';

class SplashController extends GetxController {
  //TODO: Implement SplashController

  final count = 0.obs;
  @override
  void onInit() {
    Future.delayed(Duration(seconds: 3), () {
      Get.offAll(() => ConnectView());
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
