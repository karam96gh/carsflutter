/**
 * ثوابت نقاط نهاية API
 * تستخدم للاتساق في جميع أنحاء التطبيق
 */
class ApiEndpoints {
  static const String baseUrl = 'http://192.168.74.25:4000'; // عنوان الخادم المحلي للمحاكي

  // مسارات المصادقة
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String currentUser = '/api/auth/me';
  static const String updateProfile = '/api/auth/profile';
  static const String changePassword = '/api/auth/change-password';

  // مسارات السيارات
  static const String cars = '/api/cars';
  static const String searchCars = '/api/cars/search';
  static const String featuredCars = '/api/cars/featured';
  static const String mostViewedCars = '/api/cars/most-viewed';
  static const String carDetails = '/api/cars/'; // يتبعها معرف السيارة
  static const String similarCars = '/api/cars/'; // يتبعها معرف السيارة + /similar

  // مسارات المفضلة وإشعارات الأسعار
  static const String favorites = '/api/cars/user/favorites';
  static const String addToFavorites = '/api/cars/'; // يتبعها معرف السيارة + /favorite
  static const String priceAlerts = '/api/cars/user/price-alerts';
  static const String addPriceAlert = '/api/cars/'; // يتبعها معرف السيارة + /price-alert

  // مسارات الإدارة
  static const String adminCars = '/api/admin/cars';
  static const String adminCarDetails = '/api/admin/cars/'; // يتبعها معرف السيارة
  static const String adminCarImages = '/api/admin/cars/'; // يتبعها معرف السيارة + /images
  static const String adminUsers = '/api/admin/users';
  static const String adminUserDetails = '/api/admin/users/'; // يتبعها معرف المستخدم
  static const String adminStatistics = '/api/admin/statistics';

  // مسارات أخرى
  static const String statistics = '/api/statistics';
  static const String recordVisit = '/api/statistics/record-visit';
}