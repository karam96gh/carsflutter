class CarImage {
  final int id;
  final String url;
  final bool isMain;
  final bool is360View;
  final DateTime createdAt;
  final DateTime updatedAt;

  CarImage({
    required this.id,
    required this.url,
    this.isMain = false,
    this.is360View = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // تحويل البيانات من JSON
  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      id: json['id'],
      url: json['url'],
      isMain: json['isMain'] ?? false,
      is360View: json['is360View'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'isMain': isMain,
      'is360View': is360View,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // نسخة من الصورة مع تحديثات
  CarImage copyWith({
    int? id,
    String? url,
    bool? isMain,
    bool? is360View,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarImage(
      id: id ?? this.id,
      url: url ?? this.url,
      isMain: isMain ?? this.isMain,
      is360View: is360View ?? this.is360View,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}