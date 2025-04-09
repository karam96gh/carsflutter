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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // محاولة العثور على السيارة في القائمة المحلية
      final cachedCar = _cars.firstWhere(
            (car) => car.id == id,
        orElse: () => throw Exception('لم يتم العثور على السيارة محلياً'),
      );

      // تحديث بيانات السيارة من الخادم
      final response = await _apiClient.get('/api/cars/$id');

      final carData = response['data'];
      final car = Car.fromJson(carData);

      // تحديث السيارة في القائمة المحلية إذا كانت موجودة
      final index = _cars.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cars[index] = car;
      }

      return car;
    } catch (e) {
      // في حالة عدم وجود السيارة محلياً، جلب البيانات من الخادم
      try {
        final response = await _apiClient.get('/api/cars/$id');

        final carData = response['data'];
        return Car.fromJson(carData);
      } catch (e) {
        _error = 'فشل الحصول على بيانات السيارة: ${e.toString()}';
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة سيارة جديدة
  Future<int> addCar(Map<String, dynamic> carData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/api/admin/cars',
        data: carData,
      );

      final newCar = Car.fromJson(response['data']);

      // إضافة السيارة الجديدة إلى القائمة المحلية
      _cars.add(newCar);

      return newCar.id;
    } catch (e) {
      _error = 'فشل إضافة السيارة: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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

  // تحميل صور السيارة
  Future<void> uploadCarImages(int carId, List<XFile> images) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final image in images) {
        // إنشاء FormData
        final formData = {
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.name,
          ),
        };

        await _apiClient.upload(
          '/api/admin/cars/$carId/images',
          data: formData,
        );
      }

      // تحديث بيانات السيارة بعد تحميل الصور
      await getCarById(carId);
    } catch (e) {
      _error = 'فشل تحميل الصور: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // حذف صورة السيارة
  Future<void> deleteCarImage(int imageId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.delete('/api/admin/cars/images/$imageId');

      // تحديث السيارات المتأثرة
      await loadCars();
    } catch (e) {
      _error = 'فشل حذف الصورة: ${e.toString()}';
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

// فئة مساعدة للملفات المتعددة
class MultipartFile {
  final String path;
  final String filename;

  MultipartFile({
    required this.path,
    required this.filename,
  });

  static Future<MultipartFile> fromFile(String path, {required String filename}) async {
    return MultipartFile(
      path: path,
      filename: filename,
    );
  }
}