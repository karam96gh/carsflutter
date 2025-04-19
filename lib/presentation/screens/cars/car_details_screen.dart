import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../data/models/car.dart';
import '../../../data/providers/car_provider.dart';
import '../../widgets/custom_error_widget.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCarDetails();
    });
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

  Future<void> _openWhatsApp(String phoneNumber) async {
    final number = phoneNumber.startsWith('+') ? phoneNumber.substring(1) : phoneNumber;
    final message = 'مرحباً، أنا مهتم بالسيارة ${_car?.make} ${_car?.model}';
    final url = 'https://wa.me/$number?text=${Uri.encodeComponent(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح واتساب')),
      );
    }
  }

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

  Future<void> _deleteCar() async {
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

  Widget _buildCarouselWithIndicator() {
    return Stack(
      children: [
        // Car images carousel
        _car!.images.isEmpty
            ? Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.directions_car, size: 100, color: Colors.grey),
          ),
        )
            : CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            enableInfiniteScroll: _car!.images.length > 1,
            autoPlay: _car!.images.length > 1,
            onPageChanged: (index, _) => setState(() => _currentImageIndex = index),
          ),
          items: _car!.images.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[200],
                  child: Image.network(
                    image.fullUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.error, size: 50, color: Colors.red),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),

        // Image indicators
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
                        : Colors.white.withOpacity(0.7),
                  ),
                );
              }).toList(),
            ),
          ),

        // Gradient overlay for better title readability
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
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    final categoryMap = {
      'LUXURY': 'فاخرة',
      'ECONOMY': 'اقتصادية',
      'SUV': 'دفع رباعي',
      'SPORTS': 'رياضية',
      'SEDAN': 'سيدان',
      'OTHER': 'أخرى',
    };
    return categoryMap[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل السيارة')),
        body: const Center(child: CircularProgressIndicator()),
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
        body: const Center(child: Text('لا توجد بيانات للسيارة')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with car images
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
                  ).then((_) => _loadCarDetails());
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
              background: _buildCarouselWithIndicator(),
            ),
          ),

          // Car details content
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title and price
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
                      backgroundColor: _car!.type == 'NEW' ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main info section
                _buildInfoSection(
                  'المعلومات الرئيسية',
                  [
                    Row(
                      children: [
                        _buildInfoItem(Icons.business, 'الشركة', _car!.make),
                        _buildInfoItem(Icons.branding_watermark, 'الموديل', _car!.model),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoItem(Icons.calendar_today, 'سنة الصنع', _car!.year.toString()),
                        _buildInfoItem(Icons.category, 'الفئة', _getCategoryName(_car!.category)),
                      ],
                    ),
                    if (_car!.mileage != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildInfoItem(Icons.speed, 'المسافة المقطوعة', '${_car!.mileage} كم'),
                          if (_car!.origin != null)
                            _buildInfoItem(Icons.flag, 'بلد المنشأ', _car!.origin!),
                        ],
                      ),
                    ],
                  ],
                ),

                // Technical details
                if (_car!.fuel != null || _car!.engineSize != null || _car!.transmission != null || _car!.driveType != null)
                  _buildInfoSection(
                    'التفاصيل الفنية',
                    [
                      if (_car!.fuel != null || _car!.engineSize != null)
                        Row(
                          children: [
                            if (_car!.fuel != null)
                              _buildInfoItem(Icons.local_gas_station, 'نوع الوقود', _car!.fuel!),
                            if (_car!.engineSize != null)
                              _buildInfoItem(Icons.engineering, 'سعة المحرك', _car!.engineSize!),
                          ],
                        ),
                      if ((_car!.transmission != null || _car!.driveType != null) &&
                          (_car!.fuel != null || _car!.engineSize != null))
                        const SizedBox(height: 16),
                      if (_car!.transmission != null || _car!.driveType != null)
                        Row(
                          children: [
                            if (_car!.transmission != null)
                              _buildInfoItem(Icons.settings, 'ناقل الحركة', _car!.transmission!),
                            if (_car!.driveType != null)
                              _buildInfoItem(Icons.drive_eta, 'نوع الدفع', _car!.driveType!),
                          ],
                        ),
                      if (_car!.doors != null || _car!.passengers != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_car!.doors != null)
                              _buildInfoItem(Icons.sensor_door, 'عدد الأبواب', _car!.doors.toString()),
                            if (_car!.passengers != null)
                              _buildInfoItem(Icons.people, 'عدد الركاب', _car!.passengers.toString()),
                          ],
                        ),
                      ],
                    ],
                  ),

                // Dimensions
                if (_car!.dimensions != null && _car!.dimensions!.isNotEmpty)
                  _buildInfoSection(
                    'أبعاد السيارة',
                    [
                      Row(
                        children: [
                          if (_car!.dimensions!.containsKey('length'))
                            _buildInfoItem(Icons.straighten, 'الطول', '${_car!.dimensions!['length']} ملم'),
                          if (_car!.dimensions!.containsKey('width'))
                            _buildInfoItem(Icons.width_normal, 'العرض', '${_car!.dimensions!['width']} ملم'),
                        ],
                      ),
                      if (_car!.dimensions!.containsKey('height')) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoItem(Icons.height, 'الارتفاع', '${_car!.dimensions!['height']} ملم'),
                          ],
                        ),
                      ],
                    ],
                  ),

                // Description
                _buildInfoSection(
                  'الوصف',
                  [
                    Text(
                      _car!.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                // Specifications
                if (_car!.specifications.isNotEmpty)
                  _buildInfoSection(
                    'المواصفات الفنية',
                    [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _car!.specifications.length,
                        separatorBuilder: (_, __) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final spec = _car!.specifications[index];
                          return Row(
                            children: [
                              Text(
                                spec.key,
                                style: const TextStyle(fontWeight: FontWeight.bold),
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

                // Contact info
                _buildInfoSection(
                  'معلومات الاتصال',
                  [
                    _buildContactItem(Icons.phone, _car!.contactNumber),
                    if (_car!.location != null)
                      _buildContactItem(Icons.location_on, _car!.location!),
                    if (_car!.vin != null)
                      _buildContactItem(Icons.pin, "رقم الهيكل: ${_car!.vin!}"),
                  ],
                ),

                // Space for FAB
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWhatsApp(_car!.contactNumber),
        icon: const Icon(Icons.message),
        label: const Text('تواصل عبر واتساب'),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}