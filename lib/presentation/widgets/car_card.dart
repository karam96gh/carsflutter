import 'package:flutter/material.dart';
import '../../../data/models/car.dart';
import '../../../config/app_theme.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CarCard({
    Key? key,
    required this.car,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة السيارة
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 180,
                child: car.images.isNotEmpty
                    ? Image.network(
                  car.images.first.fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),

            // معلومات السيارة
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // اسم السيارة
                      Text(
                        '${car.make} ${car.model}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // نوع السيارة (جديد/مستعمل)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: car.type == 'NEW' ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          car.type == 'NEW' ? 'جديدة' : 'مستعملة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // عنوان السيارة
                  Text(
                    car.title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // معلومات إضافية
                  Row(
                    children: [
                      // سنة الصنع
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text('${car.year}'),
                          ],
                        ),
                      ),

                      // المسافة (للسيارات المستعملة)
                      if (car.mileage != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.speed,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text('${car.mileage} كم'),
                            ],
                          ),
                        ),

                      // السعر
                      Text(
                        '${car.price} ريال',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // شريط الإجراءات
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // زر التعديل
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: onEdit,
                          tooltip: 'تعديل',
                          color: Colors.blue,
                        ),
                        // زر الحذف
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: onDelete,
                          tooltip: 'حذف',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}