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
  });

  // تحويل البيانات من JSON
  factory Car.fromJson(Map<String, dynamic> json) {
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
      price: json['price'].toDouble(),
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
    );
  }
}