// تعديل ملف lib/data/providers/car_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/car.dart';
import '../../core/api/api_client.dart';

class CarProvider with ChangeNotifier {
  final ApiClient _apiClient;

  List<Car> _cars = [];
  bool _isLoading = false;
  String? _error;

  CarProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  // الحصول على قائمة السيارات
  List<Car> get cars => [..._cars];

  // الحصول على حالة التحميل
  bool get isLoading => _isLoading;

  // الحصول على رسالة الخطأ
  String? get error => _error;

  // تحميل قائمة السيارات
  Future<void> loadCars() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/cars');

      final carsData = response['data'] as List<dynamic>;
      _cars = carsData.map((car) => Car.fromJson(car)).toList();
    } catch (e) {
      _error = 'فشل تحميل السيارات: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // الحصول على سيارة بواسطة المعرف
  Future<Car> getCarById(int id) async {
    // تعيين الحالة قبل بدء العملية
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // تنفيذ طلب API للحصول على بيانات السيارة
      final response = await _apiClient.get('/api/cars/$id');
      final carData = response['data'];
      final car = Car.fromJson(carData);

      // تحديث السيارة في القائمة المحلية إذا كانت موجودة - بدون notifyListeners هنا
      final index = _cars.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cars[index] = car;
      }

      // تحديث الحالة بعد نجاح العملية
      _isLoading = false;
      notifyListeners(); // نداء واحد فقط في نهاية الدالة

      return car;
    } catch (e) {
      // تحديث الحالة في حالة الخطأ
      _error = 'فشل الحصول على بيانات السيارة: ${e.toString()}';
      _isLoading = false;
      notifyListeners();

      rethrow;
    }
  }

  // إضافة سيارة جديدة
  Future<int> addCar(Map<String, dynamic> carData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // إنشاء سيارة بدون صور أولاً
      final response = await _apiClient.post(
        '/api/admin/cars',
        data: carData,
      );

      final newCar = Car.fromJson(response['data']);
      _cars.add(newCar);

      return newCar.id; // إرجاع معرف السيارة الجديدة
    } catch (e) {
      _error = 'فشل إضافة السيارة: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحميل صور السيارة
  Future<void> uploadCarImages(int carId, List<XFile> images) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('بدء تحميل ${images.length} صورة للسيارة رقم $carId');

      for (int i = 0; i < images.length; i++) {
        final xFile = images[i];
        debugPrint('جاري معالجة الصورة ${i+1}/${images.length}: ${xFile.path}');

        // التحقق من وجود الملف
        final file = File(xFile.path);
        if (!await file.exists()) {
          debugPrint('الملف غير موجود: ${xFile.path}');
          continue;
        }

        // طباعة حجم الملف
        final fileSize = await file.length();
        debugPrint('حجم الملف: $fileSize بايت');

        // إعداد الحقول النصية
        final fields = {
          'isMain': i == 0 ? 'true' : 'false',
          'is360View': 'false',
        };

        // محاولة رفع الصورة باستخدام المسار المباشر
        await _apiClient.upload(
          '/api/admin/cars/$carId/images',
          filePath: xFile.path,
          fields: fields,
        );

        debugPrint('تم تحميل الصورة ${i+1} بنجاح');
      }

      // تحديث بيانات السيارة بعد تحميل الصور - بدون تحديث واجهة المستخدم أثناء الـBuild
      await _refreshCarData(carId);
    } catch (e) {
      _error = 'فشل تحميل الصور: ${e.toString()}';
      debugPrint('خطأ في تحميل الصور: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث بيانات السيارة فقط دون إشعارات
  Future<Car> _refreshCarData(int id) async {
    try {
      final response = await _apiClient.get('/api/cars/$id');
      final carData = response['data'];
      final car = Car.fromJson(carData);

      // تحديث السيارة في القائمة المحلية
      final index = _cars.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cars[index] = car;
      }

      return car;
    } catch (e) {
      debugPrint('فشل تحديث بيانات السيارة: ${e.toString()}');
      rethrow;
    }
  }

  // تحديث سيارة
  Future<void> updateCar(int id, Map<String, dynamic> carData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.put(
        '/api/admin/cars/$id',
        data: carData,
      );

      final updatedCar = Car.fromJson(response['data']);

      // تحديث السيارة في القائمة المحلية
      final index = _cars.indexWhere((car) => car.id == id);
      if (index != -1) {
        _cars[index] = updatedCar;
      }
    } catch (e) {
      _error = 'فشل تحديث السيارة: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // حذف سيارة
  Future<void> deleteCar(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.delete('/api/admin/cars/$id');

      // حذف السيارة من القائمة المحلية
      _cars.removeWhere((car) => car.id == id);
    } catch (e) {
      _error = 'فشل حذف السيارة: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // حذف صورة من السيارة
  Future<void> deleteCarImage(int imageId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // طباعة للتصحيح
      debugPrint('جاري حذف الصورة رقم $imageId');

      // إرسال طلب حذف الصورة
      await _apiClient.delete('/api/admin/cars/images/$imageId');

      debugPrint('تم حذف الصورة بنجاح');

      // تحديث القائمة بعد الحذف
      for (var car in _cars) {
        car.images.removeWhere((img) => img.id == imageId);
      }
    } catch (e) {
      _error = 'فشل حذف الصورة: ${e.toString()}';
      debugPrint('خطأ في حذف الصورة: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // البحث عن السيارات
  Future<List<Car>> searchCars(Map<String, dynamic> criteria) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // بناء معلمات البحث
      final queryParams = <String, dynamic>{};

      if (criteria.containsKey('searchText')) {
        queryParams['searchText'] = criteria['searchText'];
      }

      if (criteria.containsKey('type')) {
        queryParams['type'] = criteria['type'];
      }

      if (criteria.containsKey('category')) {
        queryParams['category'] = criteria['category'];
      }

      if (criteria.containsKey('make')) {
        queryParams['make'] = criteria['make'];
      }

      if (criteria.containsKey('model')) {
        queryParams['model'] = criteria['model'];
      }

      if (criteria.containsKey('yearMin')) {
        queryParams['yearMin'] = criteria['yearMin'];
      }

      if (criteria.containsKey('yearMax')) {
        queryParams['yearMax'] = criteria['yearMax'];
      }

      if (criteria.containsKey('priceMin')) {
        queryParams['priceMin'] = criteria['priceMin'];
      }

      if (criteria.containsKey('priceMax')) {
        queryParams['priceMax'] = criteria['priceMax'];
      }

      if (criteria.containsKey('orderBy')) {
        queryParams['orderBy'] = criteria['orderBy'];
      }

      final response = await _apiClient.get(
        '/api/cars/search',
        queryParameters: queryParams,
      );

      final carsData = response['data'] as List<dynamic>;
      return carsData.map((car) => Car.fromJson(car)).toList();
    } catch (e) {
      _error = 'فشل البحث عن السيارات: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // الحصول على السيارات المميزة
  Future<List<Car>> getFeaturedCars({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/cars/featured',
        queryParameters: {'limit': limit},
      );

      final carsData = response['data'] as List<dynamic>;
      return carsData.map((car) => Car.fromJson(car)).toList();
    } catch (e) {
      _error = 'فشل الحصول على السيارات المميزة: ${e.toString()}';
      rethrow;
    }
  }

  // الحصول على السيارات الأكثر مشاهدة
  Future<List<Car>> getMostViewedCars({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/cars/most-viewed',
        queryParameters: {'limit': limit},
      );

      final carsData = response['data'] as List<dynamic>;
      return carsData.map((car) => Car.fromJson(car)).toList();
    } catch (e) {
      _error = 'فشل الحصول على السيارات الأكثر مشاهدة: ${e.toString()}';
      rethrow;
    }
  }

  // الحصول على سيارات مشابهة
  Future<List<Car>> getSimilarCars(int carId, {int limit = 6}) async {
    try {
      final response = await _apiClient.get(
        '/api/cars/$carId/similar',
        queryParameters: {'limit': limit},
      );

      final carsData = response['data'] as List<dynamic>;
      return carsData.map((car) => Car.fromJson(car)).toList();
    } catch (e) {
      _error = 'فشل الحصول على السيارات المشابهة: ${e.toString()}';
      rethrow;
    }
  }
}