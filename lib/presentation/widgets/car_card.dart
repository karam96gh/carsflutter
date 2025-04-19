import 'package:flutter/material.dart';
import '../../../data/models/car.dart';
import '../../../config/app_theme.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color? newCarColor;
  final Color? usedCarColor;

  const CarCard({
    Key? key,
    required this.car,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.newCarColor,
    this.usedCarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الألوان الأساسية
    final primaryColor = AppTheme.primaryColor;
    final carTypeColor = car.type == 'NEW'
        ? (newCarColor ?? Colors.teal)
        : (usedCarColor ?? Colors.amber.shade700);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 4,
      shadowColor: carTypeColor.withOpacity(0.2),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: carTypeColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // خانة النوع (جديد/مستعمل) مع الصورة
            Stack(
              children: [
                // صورة السيارة
                Hero(
                  tag: 'car_image_${car.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            carTypeColor.withOpacity(0.2),
                            Colors.grey.shade100,
                          ],
                        ),
                      ),
                      child: car.images.isNotEmpty
                          ? Image.network(
                        car.images.first.fullUrl,
                        fit: BoxFit.contain,
                        width: 10000,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(carTypeColor);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildImageLoading(carTypeColor);
                        },
                      )
                          : _buildPlaceholderImage(carTypeColor),
                    ),
                  ),
                ),

                // شارة النوع
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: carTypeColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: carTypeColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          car.type == 'NEW' ? Icons.fiber_new : Icons.history,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          car.type == 'NEW' ? 'جديدة' : 'مستعملة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // شارة السعر
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${car.price} ريال',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // معلومات السيارة
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم السيارة
                  Text(
                    '${car.make} ${car.model}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // عنوان السيارة
                  Text(
                    car.title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // معلومات إضافية
                  Row(
                    children: [
                      _buildInfoItem(
                        icon: Icons.calendar_today,
                        label: '${car.year}',
                        color: Colors.blue.shade700,
                      ),
                      if (car.mileage != null) ...[
                        const SizedBox(width: 16),
                        _buildInfoItem(
                          icon: Icons.speed,
                          label: '${car.mileage} كم',
                          color: Colors.purple.shade700,
                        ),
                      ],
                    ],
                  ),

                  // خط فاصل
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: Colors.grey.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),

                  // شريط الإجراءات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // زر التفاصيل
                      _buildActionButton(
                        label: 'التفاصيل',
                        icon: Icons.info_outline,
                        color: Colors.blue,
                        onPressed: onTap,
                      ),
                      // زر التعديل
                      _buildActionButton(
                        label: 'تعديل',
                        icon: Icons.edit_outlined,
                        color: Colors.green,
                        onPressed: onEdit,
                      ),
                      // زر الحذف
                      _buildActionButton(
                        label: 'حذف',
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة إنشاء عنصر معلومات
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // دالة إنشاء زر إجراء
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة إنشاء صورة بديلة
  Widget _buildPlaceholderImage(Color color) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 64,
              color: color.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد صورة',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة إنشاء مؤشر تحميل الصورة
  Widget _buildImageLoading(Color color) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 3,
        ),
      ),
    );
  }
}