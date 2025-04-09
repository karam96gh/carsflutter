/**
 * فئات الاستثناءات المخصصة للتطبيق
 * تستخدم لمعالجة أخطاء الشبكة وواجهة برمجة التطبيقات بطريقة منظمة
 */

// استثناء API الأساسي
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? details;

  ApiException(this.message, this.statusCode, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'ApiException: $message (Code: $statusCode, Details: $details)';
    }
    return 'ApiException: $message (Code: $statusCode)';
  }
}

// استثناء غير مصرح
class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'غير مصرح'])
      : super(message, 401);
}

// استثناء غير مسموح
class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'غير مسموح'])
      : super(message, 403);
}

// استثناء غير موجود
class NotFoundException extends ApiException {
  NotFoundException([String message = 'غير موجود'])
      : super(message, 404);
}

// استثناء طلب غير صالح
class BadRequestException extends ApiException {
  BadRequestException([String message = 'طلب غير صالح'])
      : super(message, 400);
}

// استثناء خطأ في الخادم
class ServerException extends ApiException {
  ServerException([String message = 'خطأ في الخادم'])
      : super(message, 500);
}

// استثناء اتصال الشبكة
class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'فشل الاتصال بالشبكة']);

  @override
  String toString() => 'NetworkException: $message';
}

// استثناء التخزين المحلي
class StorageException implements Exception {
  final String message;

  StorageException([this.message = 'خطأ في التخزين المحلي']);

  @override
  String toString() => 'StorageException: $message';
}

// استثناء التحقق من صحة البيانات
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException(this.message, [this.errors]);

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message, Errors: $errors';
    }
    return 'ValidationException: $message';
  }
}