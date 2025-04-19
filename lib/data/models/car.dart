import 'car_image.dart';
import 'car_specification.dart';

class Car {
  final int id;
  final String title;
  final String description;
  final String type; // NEW or USED
  final String category; // LUXURY, ECONOMY, SUV, SPORTS, SEDAN, OTHER
  final String make;
  final String model;
  final int year;
  final int? mileage;
  final double price;
  final String contactNumber;
  final String? location;
  final bool isFeatured;
  final int views;
  final List<CarImage> images;
  final List<CarSpecification> specifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  // إضافة حقول جديدة
  final String? fuel; // نوع الوقود: بنزين أو ديزل
  final String? transmission; // نوع ناقل الحركة: أوتوماتيك أو يدوي
  final String? driveType; // نوع الدفع: أمامي أو خلفي أو رباعي
  final int? doors; // عدد الأبواب
  final int? passengers; // عدد الركاب
  final String? exteriorColor; // اللون الخارجي
  final String? interiorColor; // اللون الداخلي
  final String? engineSize; // سعة المحرك
  final Map<String, int>? dimensions; // الأبعاد: الطول والعرض والارتفاع
  final String? vin; // رقم هيكل السيارة
  final String? origin; // بلد المنشأ

  Car({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.make,
    required this.model,
    required this.year,
    this.mileage,
    required this.price,
    required this.contactNumber,
    this.location,
    this.isFeatured = false,
    this.views = 0,
    required this.images,
    required this.specifications,
    required this.createdAt,
    required this.updatedAt,
    // الحقول الجديدة
    this.fuel,
    this.transmission,
    this.driveType,
    this.doors,
    this.passengers,
    this.exteriorColor,
    this.interiorColor,
    this.engineSize,
    this.dimensions,
    this.vin,
    this.origin,
  });

  // تحويل البيانات من JSON
  factory Car.fromJson(Map<String, dynamic> json) {
    // معالجة الأبعاد إذا وجدت
    Map<String, int>? dimensions;
    if (json['dimensions'] != null) {
      dimensions = Map<String, int>.from(json['dimensions']);
    }

    return Car(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      category: json['category'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      mileage: json['mileage'],
      price: json['price'] is int ? json['price'].toDouble() : json['price'],
      contactNumber: json['contactNumber'],
      location: json['location'],
      isFeatured: json['isFeatured'] ?? false,
      views: json['views'] ?? 0,
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => CarImage.fromJson(image))
          .toList() ??
          [],
      specifications: (json['specifications'] as List<dynamic>?)
          ?.map((spec) => CarSpecification.fromJson(spec))
          .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      // الحقول الجديدة
      fuel: json['fuel'],
      transmission: json['transmission'],
      driveType: json['driveType'],
      doors: json['doors'],
      passengers: json['passengers'],
      exteriorColor: json['exteriorColor'],
      interiorColor: json['interiorColor'],
      engineSize: json['engineSize'],
      dimensions: dimensions,
      vin: json['vin'],
      origin: json['origin'],
    );
  }

  // تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'make': make,
      'model': model,
      'year': year,
      'mileage': mileage,
      'price': price,
      'contactNumber': contactNumber,
      'location': location,
      'isFeatured': isFeatured,
      'views': views,
      'images': images.map((image) => image.toJson()).toList(),
      'specifications': specifications.map((spec) => spec.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // الحقول الجديدة
      'fuel': fuel,
      'transmission': transmission,
      'driveType': driveType,
      'doors': doors,
      'passengers': passengers,
      'exteriorColor': exteriorColor,
      'interiorColor': interiorColor,
      'engineSize': engineSize,
      'dimensions': dimensions,
      'vin': vin,
      'origin': origin,
    };
  }

  // نسخة من السيارة مع تحديثات
  Car copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    String? category,
    String? make,
    String? model,
    int? year,
    int? mileage,
    double? price,
    String? contactNumber,
    String? location,
    bool? isFeatured,
    int? views,
    List<CarImage>? images,
    List<CarSpecification>? specifications,
    DateTime? createdAt,
    DateTime? updatedAt,
    // الحقول الجديدة
    String? fuel,
    String? transmission,
    String? driveType,
    int? doors,
    int? passengers,
    String? exteriorColor,
    String? interiorColor,
    String? engineSize,
    Map<String, int>? dimensions,
    String? vin,
    String? origin,
  }) {
    return Car(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      mileage: mileage ?? this.mileage,
      price: price ?? this.price,
      contactNumber: contactNumber ?? this.contactNumber,
      location: location ?? this.location,
      isFeatured: isFeatured ?? this.isFeatured,
      views: views ?? this.views,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // الحقول الجديدة
      fuel: fuel ?? this.fuel,
      transmission: transmission ?? this.transmission,
      driveType: driveType ?? this.driveType,
      doors: doors ?? this.doors,
      passengers: passengers ?? this.passengers,
      exteriorColor: exteriorColor ?? this.exteriorColor,
      interiorColor: interiorColor ?? this.interiorColor,
      engineSize: engineSize ?? this.engineSize,
      dimensions: dimensions ?? this.dimensions,
      vin: vin ?? this.vin,
      origin: origin ?? this.origin,
    );
  }
}