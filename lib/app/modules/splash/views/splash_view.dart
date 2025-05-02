import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      assignId: true,
      builder: (logic) {
        return Scaffold(backgroundColor: Color(0xff0F1015), body: Container());
      },
    );
  }
}
