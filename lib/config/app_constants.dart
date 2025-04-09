class AppConstants {
  // معلومات التطبيق
  static const String appName = 'إدارة السيارات';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'تطبيق لإدارة مخزون السيارات';

  // رسائل الخطأ العامة
  static const String networkErrorMessage = 'فشل الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
  static const String serverErrorMessage = 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقًا.';
  static const String unknownErrorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  // رسائل المصادقة
  static const String loginSuccessMessage = 'تم تسجيل الدخول بنجاح';
  static const String logoutMessage = 'تم تسجيل الخروج بنجاح';
  static const String invalidCredentialsMessage = 'بيانات الدخول غير صحيحة';
  static const String accountBlockedMessage = 'هذا الحساب محظور';

  // رسائل إدارة السيارات
  static const String carAddedMessage = 'تمت إضافة السيارة بنجاح';
  static const String carUpdatedMessage = 'تم تحديث السيارة بنجاح';
  static const String carDeletedMessage = 'تم حذف السيارة بنجاح';
  static const String imageUploadedMessage = 'تم تحميل الصورة بنجاح';
  static const String imageDeletedMessage = 'تم حذف الصورة بنجاح';

  // رسائل النظام
  static const String confirmActionMessage = 'هل أنت متأكد من تنفيذ هذا الإجراء؟';
  static const String confirmDeleteMessage = 'هل أنت متأكد من حذف هذا العنصر؟';
  static const String confirmLogoutMessage = 'هل أنت متأكد من تسجيل الخروج؟';

  // خيارات فئات السيارات
  static const Map<String, String> carCategories = {
    'LUXURY': 'فاخرة',
    'ECONOMY': 'اقتصادية',
    'SUV': 'دفع رباعي',
    'SPORTS': 'رياضية',
    'SEDAN': 'سيدان',
    'OTHER': 'أخرى',
  };

  // أنواع السيارات
  static const Map<String, String> carTypes = {
    'NEW': 'جديدة',
    'USED': 'مستعملة',
  };

  // الألوان حسب النوع
  static const Map<String, Map<String, int>> carTypeColors = {
    'NEW': {'r': 76, 'g': 175, 'b': 80}, // أخضر
    'USED': {'r': 255, 'g': 152, 'b': 0}, // برتقالي
  };

  // إعدادات أخرى
  static const int maxImagesPerCar = 5;
  static const int minPasswordLength = 6;
  static const Duration sessionTimeout = Duration(days: 30);
  static const double defaultMapZoom = 14.0;
}