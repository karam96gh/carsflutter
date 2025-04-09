import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/cars/car_list_screen.dart';
import '../presentation/screens/cars/car_details_screen.dart';
import '../presentation/screens/cars/add_car_screen.dart';
import '../presentation/screens/cars/edit_car_screen.dart';

class AppRoutes {
  // أسماء المسارات
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String carList = '/cars';
  static const String carDetails = '/cars/details';
  static const String addCar = '/cars/add';
  static const String editCar = '/cars/edit';
  static const String carImages = '/cars/images';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // خريطة المسارات
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      dashboard: (context) => const DashboardScreen(),
      carList: (context) => const CarListScreen(),
      addCar: (context) => const AddEditCarScreen(),
      settings: (context) => const Scaffold(body: Center(child: Text('شاشة الإعدادات'))),
      profile: (context) => const Scaffold(body: Center(child: Text('الملف الشخصي'))),
    };
  }

  // معالج المسارات غير المعروفة
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // استخراج المعلمات
    final args = settings.arguments;

    switch (settings.name) {
      case carDetails:
      // التحقق من وجود معرف السيارة
        if (args is int) {
          return MaterialPageRoute(
            builder: (context) => CarDetailsScreen(carId: args),
          );
        }
        // في حالة عدم وجود معرف
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('معرف السيارة غير صالح'),
            ),
          ),
        );

      case editCar:
      // التحقق من وجود معرف السيارة
        if (args is int) {
          return MaterialPageRoute(
            builder: (context) => AddEditCarScreen(carId: args),
          );
        }
        // في حالة عدم وجود معرف
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('معرف السيارة غير صالح'),
            ),
          ),
        );

      case carImages:
      // التحقق من وجود معرف السيارة
        if (args is int) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('إدارة صور السيارة')),
              body: const Center(child: Text('إدارة صور السيارة ستتوفر قريباً')),
            ),
          );
        }
        // في حالة عدم وجود معرف
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('معرف السيارة غير صالح'),
            ),
          ),
        );

      default:
      // في حالة عدم وجود مسار معرف
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('خطأ')),
            body: Center(
              child: Text('المسار ${settings.name} غير موجود'),
            ),
          ),
        );
    }
  }
}