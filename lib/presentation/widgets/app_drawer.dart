import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // رأس القائمة
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            accountName: Text(
              user?.name ?? 'المدير',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: AppTheme.primaryColor,
                size: 48,
              ),
            ),
          ),

          // اللوحة الرئيسية
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('اللوحة الرئيسية'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                    (route) => false,
              );
            },
          ),

          // إدارة السيارات
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'إدارة السيارات',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // إضافة سيارة
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('إضافة سيارة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.addCar);
            },
          ),

          // عرض السيارات
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('عرض السيارات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.carList);
            },
          ),

          // بحث
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('البحث'),
            onTap: () {
              Navigator.pop(context);
              // عرض شاشة البحث (يمكن إضافتها لاحقاً)
            },
          ),

          // الإعدادات والمزيد
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'الإعدادات والمزيد',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // الإعدادات
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              // عرض شاشة الإعدادات (يمكن إضافتها لاحقاً)
            },
          ),

          // المساعدة
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('المساعدة'),
            onTap: () {
              Navigator.pop(context);
              // عرض شاشة المساعدة (يمكن إضافتها لاحقاً)
            },
          ),

          // تسجيل الخروج
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              // تأكيد تسجيل الخروج
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                // تسجيل الخروج
                await Provider.of<AuthProvider>(context, listen: false).logout();

                // التوجيه إلى شاشة تسجيل الدخول
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                        (route) => false,
                  );
                }
              }
            },
          ),

          // عن التطبيق
          const Divider(),
          ListTile(
            title: const Text('عن التطبيق'),
            subtitle: const Text('الإصدار 1.0.0'),
            onTap: () {
              Navigator.pop(context);
              // عرض معلومات عن التطبيق
              showAboutDialog(
                context: context,
                applicationName: 'إدارة السيارات',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.directions_car,
                  color: AppTheme.primaryColor,
                  size: 48,
                ),
                applicationLegalese: '© 2025 جميع الحقوق محفوظة',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'تطبيق متكامل لإدارة مخزون السيارات للمعارض والوكالات.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}