import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../errors/exceptions.dart';
import 'api_endpoints.dart';

class ApiClient {
  final String baseUrl;
  String? _token;

  ApiClient({required this.baseUrl});

  // تعيين التوكن
  void setToken(String token) {
    _token = token;
  }

  // حذف التوكن
  void clearToken() {
    _token = null;
  }

  // الحصول على رؤوس الطلب
  Map<String, String> _getHeaders({bool multipart = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': multipart ? 'multipart/form-data' : 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // معالجة الاستجابة
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    debugPrint('Response Code: $statusCode');
    debugPrint('Response Body: $responseBody');

    try {
      final data = json.decode(responseBody);

      if (statusCode >= 200 && statusCode < 300) {
        return data;
      } else if (statusCode == 401) {
        throw UnauthorizedException(data['message'] ?? 'غير مصرح');
      } else if (statusCode == 403) {
        throw ForbiddenException(data['message'] ?? 'غير مسموح');
      } else if (statusCode == 404) {
        throw NotFoundException(data['message'] ?? 'غير موجود');
      } else if (statusCode >= 400 && statusCode < 500) {
        throw BadRequestException(data['message'] ?? 'طلب غير صالح');
      } else if (statusCode >= 500) {
        throw ServerException(data['message'] ?? 'خطأ في الخادم');
      } else {
        throw ApiException(
          'خطأ غير معروف',
          statusCode,
          data['message'] ?? 'حدث خطأ',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        'خطأ في استجابة الخادم',
        statusCode,
        'فشل تحليل استجابة الخادم',
      );
    }
  }

  // طلب GET
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
              (key, value) => MapEntry(key, value.toString()),
        ),
      );

      debugPrint('GET Request: $uri');

      final response = await http.get(
        uri,
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET Error: ${e.toString()}');
      rethrow;
    }
  }

  // طلب POST
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      debugPrint('POST Request: $uri');
      debugPrint('POST Data: $data');

      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST Error: ${e.toString()}');
      rethrow;
    }
  }

  // طلب PUT
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      debugPrint('PUT Request: $uri');
      debugPrint('PUT Data: $data');

      final response = await http.put(
        uri,
        headers: _getHeaders(),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT Error: ${e.toString()}');
      rethrow;
    }
  }

  // طلب DELETE
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      debugPrint('DELETE Request: $uri');

      final response = await http.delete(
        uri,
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE Error: ${e.toString()}');
      rethrow;
    }
  }

  // طلب تحميل ملف
  Future<dynamic> upload(String endpoint, {required Map<String, dynamic> data}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      debugPrint('UPLOAD Request: $uri');
      debugPrint('UPLOAD Data: $data');

      final request = http.MultipartRequest('POST', uri);

      // إضافة الرؤوس مع التأكد من نوع المحتوى المناسب
      final headers = _getHeaders(multipart: true);
      debugPrint('UPLOAD Headers: $headers');
      request.headers.addAll(headers);

      // إضافة البيانات النصية
      data.forEach((key, value) {
        if (value is! MultipartFile) {
          request.fields[key] = value.toString();
          debugPrint('Field $key: ${value.toString()}');
        }
      });

      // إضافة الملفات
      for (final entry in data.entries) {
        if (entry.value is MultipartFile) {
          final file = entry.value as MultipartFile;
          debugPrint('File ${entry.key}: ${file.path} (${file.filename})');

          final httpFile = await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            filename: file.filename,
          );
          request.files.add(httpFile);
          debugPrint('File added to request: ${httpFile.filename} (${httpFile.length} bytes)');
        }
      }

      debugPrint('Sending multipart request...');
      final streamedResponse = await request.send();
      debugPrint('Response status code: ${streamedResponse.statusCode}');

      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('UPLOAD Error: ${e.toString()}');
      rethrow;
    }
  }
  Future<dynamic> uploadWithData(String endpoint, {required Map<String, dynamic> data}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('طلب إرسال بيانات مع صور: $uri');

      final request = http.MultipartRequest('POST', uri);

      // إضافة الرؤوس
      final headers = _getHeaders(multipart: true);
      headers.remove('Content-Type'); // دع http يضبط Content-Type تلقائيًا
      request.headers.addAll(headers);

      // طباعة البيانات للتصحيح
      debugPrint('البيانات التي سيتم إرسالها: $data');

      // إضافة البيانات النصية أولاً
      data.forEach((key, value) {
        if (value is! MultipartFile) {
          request.fields[key] = value.toString();
          debugPrint('إضافة حقل نصي: $key = $value');
        }
      });

      // ثم إضافة الملفات
      for (final entry in data.entries) {
        if (entry.value is MultipartFile) {
          final file = entry.value as MultipartFile;

          try {
            final httpFile = await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.filename,
            );
            request.files.add(httpFile);
            debugPrint('تمت إضافة ملف: ${entry.key} = ${file.filename} (${httpFile.length} بايت)');
          } catch (e) {
            debugPrint('خطأ في إضافة الملف: $e');
            rethrow;
          }
        }
      }

      // طباعة حقول الطلب النهائية
      debugPrint('الحقول النصية في الطلب: ${request.fields}');
      debugPrint('عدد الملفات في الطلب: ${request.files.length}');

      // إرسال الطلب
      debugPrint('جاري إرسال الطلب...');
      final streamedResponse = await request.send();
      debugPrint('تم استلام استجابة - رمز الحالة: ${streamedResponse.statusCode}');

      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('محتوى الاستجابة: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('خطأ التحميل: ${e.toString()}');
      rethrow;
    }
  }}

// فئة مساعدة للملفات المتعددة (مكررة هنا للاتساق)
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