import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../data/models/car.dart';
import '../../../data/providers/car_provider.dart';
import '../../widgets/custom_error_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';

class CarDetailsScreen extends StatefulWidget {
  final int carId;

  const CarDetailsScreen({Key? key, required this.carId}) : super(key: key);

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  bool _isLoading = true;
  Car? _car;
  String? _errorMessage;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCarDetails();
  }

  Future<void> _loadCarDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final car = await Provider.of<CarProvider>(context, listen: false)
          .getCarById(widget.carId);

      setState(() {
        _car = car;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل تفاصيل السيارة: ${e.toString()}';
      });
    }
  }

  // فتح الواتساب
  Future<void> _openWhatsApp(String phoneNumber) async {
    // تنسيق رقم الهاتف (إزالة + إذا وجد)
    final number = phoneNumber.startsWith('+') ? phoneNumber.substring(1) : phoneNumber;

    // إنشاء رسالة
    final message = 'مرحباً، أنا مهتم بالسيارة ${_car?.make} ${_car?.model}';

    // إنشاء رابط الواتساب
    final url = 'https://wa.me/$number?text=${Uri.encodeComponent(message)}';

    // فتح الرابط
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح واتساب')),
      );
    }
  }

  // مشاركة السيارة
  Future<void> _shareCar() async {
    if (_car == null) return;

    final text = '''
    ${_car!.title}
    
    النوع: ${_car!.type == 'NEW' ? 'جديدة' : 'مستعملة'}
    الشركة: ${_car!.make}
    الموديل: ${_car!.model}
    السنة: ${_car!.year}
    ${_car!.mileage != null ? 'المسافة المقطوعة: ${_car!.mileage} كم' : ''}
    السعر: ${_car!.price} ريال
    
    للتواصل: ${_car!.contactNumber}
    ''';

    await Share.share(text, subject: _car!.title);
  }

  // حذف السيارة
  Future<void> _deleteCar() async {
    // تأكيد الحذف
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${_car?.make} ${_car?.model}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<CarProvider>(context, listen: false)
          .deleteCar(widget.carId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف السيارة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حذف السيارة: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل السيارة')),
        body: const CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل السيارة')),
        body: CustomErrorWidget(
          message: _errorMessage!,
          onRetry: _loadCarDetails,
        ),
      );
    }

    if (_car == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل السيارة')),
        body: const Center(
          child: Text('لا توجد بيانات للسيارة'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // شريط التطبيق مع صور السيارة
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editCar,
                    arguments: widget.carId,
                  ).then((_) {
                    _loadCarDetails();
                  });
                },
                tooltip: 'تعديل',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteCar,
                tooltip: 'حذف',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareCar,
                tooltip: 'مشاركة',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // معرض الصور
                  _car!.images.isEmpty
                      ? Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: _car!.images.length > 1,
                      autoPlay: _car!.images.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: _car!.images.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                            child: Image.network(
                              image.url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 50,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  // مؤشر الصور
                  if (_car!.images.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _car!.images.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key
                                  ? AppTheme.primaryColor
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // تراكب داكن لتحسين قراءة العنوان
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // محتوى التفاصيل
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان والسعر
                    Text(
                      _car!.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${_car!.price} ريال',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(
                            _car!.type == 'NEW' ? 'جديدة' : 'مستعملة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: _car!.type == 'NEW'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // المعلومات الرئيسية
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المعلومات الرئيسية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildInfoItem(
                                  Icons.business,
                                  'الشركة',
                                  _car!.make,
                                ),
                                _buildInfoItem(
                                  Icons.branding_watermark,
                                  'الموديل',
                                  _car!.model,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildInfoItem(
                                  Icons.calendar_today,
                                  'سنة الصنع',
                                  _car!.year.toString(),
                                ),
                                _buildInfoItem(
                                  Icons.category,
                                  'الفئة',
                                  _getCategoryName(_car!.category),
                                ),
                              ],
                            ),
                            if (_car!.mileage != null)
                              Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildInfoItem(
                                        Icons.speed,
                                        'المسافة المقطوعة',
                                        '${_car!.mileage} كم',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // الوصف
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الوصف',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _car!.description,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // المواصفات الفنية
                    if (_car!.specifications.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'المواصفات الفنية',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _car!.specifications.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final spec = _car!.specifications[index];
                                  return Row(
                                    children: [
                                      Text(
                                        spec.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          spec.value,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // معلومات الاتصال
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'معلومات الاتصال',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _car!.contactNumber,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            if (_car!.location != null)
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _car!.location!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    // مساحة للزر
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      // زر التواصل عبر الواتساب
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWhatsApp(_car!.contactNumber),
        icon: const Icon(Icons.message),
        label: const Text('تواصل عبر واتساب'),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'LUXURY':
        return 'فاخرة';
      case 'ECONOMY':
        return 'اقتصادية';
      case 'SUV':
        return 'دفع رباعي';
      case 'SPORTS':
        return 'رياضية';
      case 'SEDAN':
        return 'سيدان';
      case 'OTHER':
        return 'أخرى';
      default:
        return category;
    }
  }
}