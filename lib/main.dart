import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'core/api/api_client.dart';
import 'core/api/api_endpoints.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/car_provider.dart';
import 'services/storage_service.dart';

void main() async {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // إنشاء مثيلات الخدمات
  final apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);
  final storageService = StorageService();

  // تحميل التوكن إذا كان موجودًا
  final token = await storageService.getToken();
  if (token != null) {
    apiClient.setToken(token);
  }

  runApp(
    MultiProvider(
      providers: [
        // مزود المصادقة
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiClient: apiClient,
            storageService: storageService,
          )..init(),
        ),
        // مزود السيارات
        ChangeNotifierProvider(
          create: (_) => CarProvider(
            apiClient: apiClient,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // السمة والمظهر
          theme: AppTheme.getTheme(context),

          // دعم اللغة العربية
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [
            Locale('ar', 'SA'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // مسارات التطبيق
          initialRoute: AppRoutes.login,
          routes: AppRoutes.getRoutes(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}