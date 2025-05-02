import 'package:get/get.dart';

import '../modules/connect/bindings/connect_binding.dart';
import '../modules/connect/views/connect_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: _Paths.CONNECT, page: () => const ConnectView(), binding: ConnectBinding()),
    GetPage(name: _Paths.SPLASH, page: () => const SplashView(), binding: SplashBinding()),
  ];
}
