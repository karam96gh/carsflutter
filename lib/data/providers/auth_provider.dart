import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../../core/api/api_client.dart';
import '../../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storageService;

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;
  Future<bool> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // تحميل التوكن
      final savedToken = await _storageService.getToken();

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;

        // تحديث عميل API بالتوكن
        _apiClient.setToken(savedToken);

        // تحميل بيانات المستخدم
        final userData = await _storageService.getUserData();

        if (userData != null) {
          _currentUser = User.fromJson(userData);
        } else {
          // تحميل بيانات المستخدم من الخادم
          try {
            await _fetchCurrentUser();
          } catch (e) {
            // في حالة فشل استرجاع بيانات المستخدم، نقوم بتسجيل الخروج
            debugPrint('فشل تحميل بيانات المستخدم: ${e.toString()}');
            await logout();
            _isLoading = false;
            notifyListeners();
            return false;
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('فشل تحميل البيانات المحفوظة: ${e.toString()}');
      await logout(); // تسجيل الخروج في حالة وجود مشكلة
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // طريقة جديدة للتحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    if (_token != null && _currentUser != null) {
      return true;
    }

    // إذا لم تكن البيانات محملة بعد، قم بتحميلها
    if (!_isInitialized) {
      final initialized = await init();
      return initialized && _token != null && _currentUser != null;
    }

    return false;
  }

  // إضافة متغير لتتبع حالة التهيئة
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthProvider({
    required ApiClient apiClient,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService {
  }

  // الحصول على المستخدم الحالي
  User? get currentUser => _currentUser;

  // الحصول على التوكن
  String? get token => _token;

  // الحصول على حالة التحميل
  bool get isLoading => _isLoading;

  // الحصول على رسالة الخطأ
  String? get error => _error;

  // التحقق ما إذا كان المستخدم مسجل الدخول

  // تحميل البيانات المحفوظة
  Future<void> _loadSavedData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // تحميل التوكن
      final savedToken = await _storageService.getToken();

      if (savedToken != null) {
        _token = savedToken;

        // تحميل بيانات المستخدم
        final userData = await _storageService.getUserData();

        if (userData != null) {
          _currentUser = User.fromJson(userData);
        } else {
          // تحميل بيانات المستخدم من الخادم
          await _fetchCurrentUser();
        }
      }
    } catch (e) {
      debugPrint('فشل تحميل البيانات المحفوظة: ${e.toString()}');
      _error = 'فشل تحميل البيانات';
      await logout(); // تسجيل الخروج في حالة وجود مشكلة
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تسجيل الدخول
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response['data'];

      // حفظ بيانات التوكن والمستخدم
      _token = data['token'];
      _currentUser = User.fromJson(data['user']);

      // طباعة للتأكد من البيانات
      debugPrint('تم تسجيل الدخول بنجاح، التوكن: $_token');

      // حفظ البيانات محليًا
      await _storageService.saveToken(_token!);
      await _storageService.saveUserData(_currentUser!.toJson());

      // تحديث عميل API بالتوكن الجديد
      _apiClient.setToken(_token!);

      // تحديث حالة التهيئة
    } catch (e) {
      _error = 'فشل تسجيل الدخول: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // تسجيل الخروج
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // حذف البيانات المحلية
      await _storageService.deleteToken();
      await _storageService.deleteUserData();

      // إعادة تعيين البيانات
      _token = null;
      _currentUser = null;

      // إعادة تعيين عميل API
      _apiClient.clearToken();
    } catch (e) {
      _error = 'فشل تسجيل الخروج: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // جلب بيانات المستخدم الحالي
  Future<void> _fetchCurrentUser() async {
    try {
      final response = await _apiClient.get('/api/auth/me');

      final userData = response['data']['user'];
      _currentUser = User.fromJson(userData);

      // حفظ بيانات المستخدم محليًا
      await _storageService.saveUserData(_currentUser!.toJson());
    } catch (e) {
      _error = 'فشل جلب بيانات المستخدم: ${e.toString()}';
      rethrow;
    }
  }

  // تحديث بيانات المستخدم
  Future<void> updateProfile(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.put(
        '/api/auth/profile',
        data: userData,
      );

      final updatedUser = User.fromJson(response['data']['user']);
      _currentUser = updatedUser;

      // تحديث البيانات المحلية
      await _storageService.saveUserData(_currentUser!.toJson());
    } catch (e) {
      _error = 'فشل تحديث الملف الشخصي: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تغيير كلمة المرور
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.post(
        '/api/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      _error = 'فشل تغيير كلمة المرور: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}