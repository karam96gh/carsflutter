/**
 * دوال مساعدة للتحقق من صحة البيانات
 * تستخدم مع نماذج Flutter لتبسيط التحقق من المدخلات
 */
class Validators {
  // التحقق من وجود القيمة
  static String? Function(String?) required(String errorMessage) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  // التحقق من صحة البريد الإلكتروني
  static String? Function(String?) email([String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(value)) {
        return errorMessage ?? 'البريد الإلكتروني غير صالح';
      }

      return null;
    };
  }

  // التحقق من الحد الأدنى للطول
  static String? Function(String?) minLength(int length, [String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      if (value.length < length) {
        return errorMessage ?? 'يجب أن يكون الطول على الأقل $length حرف';
      }

      return null;
    };
  }

  // التحقق من الحد الأقصى للطول
  static String? Function(String?) maxLength(int length, [String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      if (value.length > length) {
        return errorMessage ?? 'يجب أن لا يتجاوز الطول $length حرف';
      }

      return null;
    };
  }

  // التحقق من مطابقة تعبير منتظم
  static String? Function(String?) pattern(RegExp regex, String errorMessage) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      if (!regex.hasMatch(value)) {
        return errorMessage;
      }

      return null;
    };
  }

  // التحقق من أن القيمة رقم
  static String? Function(String?) isNumber([String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      if (double.tryParse(value) == null) {
        return errorMessage ?? 'يرجى إدخال رقم صالح';
      }

      return null;
    };
  }

  // التحقق من أن القيمة عدد صحيح
  static String? Function(String?) isInteger([String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      if (int.tryParse(value) == null) {
        return errorMessage ?? 'يرجى إدخال عدد صحيح';
      }

      return null;
    };
  }

  // التحقق من تطابق كلمتي المرور
  static String? Function(String?) matchesPassword(String password, [String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      if (value != password) {
        return errorMessage ?? 'كلمات المرور غير متطابقة';
      }

      return null;
    };
  }

  // الجمع بين عدة تحققات
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }

      return null;
    };
  }

  // التحقق من رقم الهاتف
  static String? Function(String?) phone([String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      // يمكن تعديل هذا التعبير المنتظم حسب تنسيق رقم الهاتف المطلوب
      final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
      if (!phoneRegex.hasMatch(value)) {
        return errorMessage ?? 'رقم الهاتف غير صالح';
      }

      return null;
    };
  }

  // التحقق من النطاق
  static String? Function(String?) range(num min, num max, [String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      final numValue = num.tryParse(value);
      if (numValue == null) {
        return 'يرجى إدخال رقم صالح';
      }

      if (numValue < min || numValue > max) {
        return errorMessage ?? 'يجب أن تكون القيمة بين $min و $max';
      }

      return null;
    };
  }

  // التحقق من السنة
  static String? Function(String?) validYear([String? errorMessage]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return null; // اسمح بالقيمة الفارغة (استخدم required إذا كانت إلزامية)
      }

      final yearValue = int.tryParse(value);
      if (yearValue == null) {
        return 'يرجى إدخال سنة صالحة';
      }

      final currentYear = DateTime.now().year;
      if (yearValue < 1900 || yearValue > currentYear + 1) {
        return errorMessage ?? 'يجب أن تكون السنة بين 1900 و ${currentYear + 1}';
      }

      return null;
    };
  }
}