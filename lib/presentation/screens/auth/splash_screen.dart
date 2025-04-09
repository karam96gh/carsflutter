import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_routes.dart';
import '../../../data/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      // إعطاء وقت لعرض الشاشة الترحيبية
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = await authProvider.isLoggedIn();

      if (!mounted) return;

      // طباعة للتصحيح
      debugPrint('حالة تسجيل الدخول: $isLoggedIn');

      if (isLoggedIn) {
        // إذا كان المستخدم مسجل الدخول، انتقل إلى الشاشة الرئيسية
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      } else {
        // إذا لم يكن المستخدم مسجل الدخول، انتقل إلى شاشة تسجيل الدخول
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('حدث خطأ أثناء التحقق من حالة تسجيل الدخول: ${e.toString()}');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار التطبيق
            Hero(
              tag: 'app_logo',
              child: Image.asset(
                'assets/images/car_logo.png',
                height: 120,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'إدارة السيارات',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}