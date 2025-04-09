class CarSpecification {
  final int id;
  final String key;
  final String value;

  CarSpecification({
    required this.id,
    required this.key,
    required this.value,
  });

  // تحويل البيانات من JSON
  factory CarSpecification.fromJson(Map<String, dynamic> json) {
    return CarSpecification(
      id: json['id'],
      key: json['key'],
      value: json['value'],
    );
  }

  // تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
    };
  }

  // نسخة من المواصفة مع تحديثات
  CarSpecification copyWith({
    int? id,
    String? key,
    String? value,
  }) {
    return CarSpecification(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}