import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/car.dart';
import '../../../data/models/car_image.dart';
import '../../../data/providers/car_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/image_picker_widget.dart';
import '../../../core/utils/validators.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_constants.dart';

class EditCarScreen extends StatefulWidget {
  final int carId;

  const EditCarScreen({Key? key, required this.carId}) : super(key: key);

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _locationController = TextEditingController();

  String _type = 'NEW'; // NEW or USED
  String _category = 'SEDAN'; // LUXURY, ECONOMY, SUV, SPORTS, SEDAN, OTHER

  bool _isLoading = false;
  bool _isInitialized = false;
  List<XFile> _selectedImages = [];
  List<CarImage> _existingImages = [];
  List<Map<String, String>> _specifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCarData();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _contactNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // تحميل بيانات السيارة للتعديل
  Future<void> _loadCarData() async {
    setState(() => _isLoading = true);

    try {
      final car = await Provider.of<CarProvider>(context, listen: false)
          .getCarById(widget.carId);

      _titleController.text = car.title;
      _descriptionController.text = car.description;
      _makeController.text = car.make;
      _modelController.text = car.model;
      _yearController.text = car.year.toString();
      _mileageController.text = car.mileage?.toString() ?? '';
      _priceController.text = car.price.toString();
      _contactNumberController.text = car.contactNumber;
      _locationController.text = car.location ?? '';

      setState(() {
        _type = car.type;
        _category = car.category;
        _existingImages = car.images;
        _specifications = car.specifications
            .map((spec) => {'key': spec.key, 'value': spec.value})
            .toList();
        _isInitialized = true;
        _isLoading = false;
      });

      // تصحيح: طباعة URLs الصور للتشخيص
      for (var img in _existingImages) {
        debugPrint('صورة موجودة: ${img.url}, الURL الكامل: ${img.fullUrl}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل بيانات السيارة: ${e.toString()}')),
        );
        Navigator.pop(context);
      }
    }
  }

  // حذف صورة من السيارة
  Future<void> _deleteImage(int imageId) async {
    setState(() => _isLoading = true);

    try {
      await Provider.of<CarProvider>(context, listen: false)
          .deleteCarImage(imageId);

      setState(() {
        _existingImages.removeWhere((img) => img.id == imageId);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الصورة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الصورة: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // إضافة مواصفة جديدة
  void _addSpecification() {
    showDialog(
      context: context,
      builder: (context) {
        final keyController = TextEditingController();
        final valueController = TextEditingController();

        return AlertDialog(
          title: const Text('إضافة مواصفة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'اسم المواصفة',
                  hintText: 'مثال: المحرك، ناقل الحركة، إلخ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'القيمة',
                  hintText: 'مثال: 2.0 لتر، أوتوماتيك، إلخ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  setState(() {
                    _specifications.add({
                      'key': keyController.text,
                      'value': valueController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  // حذف مواصفة
  void _removeSpecification(int index) {
    setState(() {
      _specifications.removeAt(index);
    });
  }

  // حفظ بيانات السيارة
  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // إعداد بيانات السيارة
      final carData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _type,
        'category': _category,
        'make': _makeController.text,
        'model': _modelController.text,
        'year': int.parse(_yearController.text),
        'mileage': _mileageController.text.isEmpty ? null : int.parse(_mileageController.text),
        'price': double.parse(_priceController.text),
        'contactNumber': _contactNumberController.text,
        'location': _locationController.text.isEmpty ? null : _locationController.text,
        'specifications': _specifications, // تأكد من تضمين المواصفات هنا
      };

      // تعديل السيارة
      await Provider.of<CarProvider>(context, listen: false)
          .updateCar(widget.carId, carData);

      // تحميل الصور الجديدة إذا كانت هناك
      if (_selectedImages.isNotEmpty) {
        await Provider.of<CarProvider>(context, listen: false)
            .uploadCarImages(widget.carId, _selectedImages);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث السيارة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تعديل السيارة'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل السيارة'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صور السيارة
              _buildImageSection(),
              const SizedBox(height: 24),

              // المعلومات الأساسية
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
                        'المعلومات الأساسية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // نوع السيارة
                      const Text('نوع السيارة'),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'NEW',
                            label: Text('جديدة'),
                            icon: Icon(Icons.fiber_new),
                          ),
                          ButtonSegment(
                            value: 'USED',
                            label: Text('مستعملة'),
                            icon: Icon(Icons.history),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _type = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // عنوان السيارة
                      CustomTextField(
                        controller: _titleController,
                        labelText: 'عنوان السيارة',
                        hintText: 'مثال: مرسيدس E200 موديل 2023 بحالة ممتازة',
                        prefixIcon: Icons.title,
                        validator: Validators.required('يرجى إدخال عنوان السيارة'),
                      ),
                      const SizedBox(height: 16),

                      // الشركة المصنعة
                      CustomTextField(
                        controller: _makeController,
                        labelText: 'الشركة المصنعة',
                        hintText: 'مثال: تويوتا، مرسيدس، هوندا',
                        prefixIcon: Icons.business,
                        validator: Validators.required('يرجى إدخال الشركة المصنعة'),
                      ),
                      const SizedBox(height: 16),

                      // الموديل
                      CustomTextField(
                        controller: _modelController,
                        labelText: 'الموديل',
                        hintText: 'مثال: كامري، E200، سيفيك',
                        prefixIcon: Icons.branding_watermark,
                        validator: Validators.required('يرجى إدخال الموديل'),
                      ),
                      const SizedBox(height: 16),

                      // فئة السيارة
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'فئة السيارة',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: AppConstants.carCategories.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _category = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // سنة الصنع
                      CustomTextField(
                        controller: _yearController,
                        labelText: 'سنة الصنع',
                        hintText: 'مثال: 2023',
                        prefixIcon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: Validators.combine([
                          Validators.required('يرجى إدخال سنة الصنع'),
                          Validators.isInteger('يرجى إدخال سنة صالحة'),
                          Validators.validYear('يرجى إدخال سنة صالحة')
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // المسافة المقطوعة (للسيارات المستعملة)
                      if (_type == 'USED')
                        Column(
                          children: [
                            CustomTextField(
                              controller: _mileageController,
                              labelText: 'المسافة المقطوعة (كم)',
                              hintText: 'مثال: 50000',
                              prefixIcon: Icons.speed,
                              keyboardType: TextInputType.number,
                              validator: Validators.isInteger('يرجى إدخال قيمة صحيحة'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // السعر
                      CustomTextField(
                        controller: _priceController,
                        labelText: 'السعر',
                        hintText: 'مثال: 150000',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: Validators.combine([
                          Validators.required('يرجى إدخال السعر'),
                          Validators.isNumber('يرجى إدخال قيمة صحيحة'),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

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

                      // رقم التواصل (واتساب)
                      CustomTextField(
                        controller: _contactNumberController,
                        labelText: 'رقم التواصل (واتساب)',
                        hintText: 'مثال: +966xxxxxxxxx',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: Validators.required('يرجى إدخال رقم التواصل'),
                      ),
                      const SizedBox(height: 16),

                      // الموقع
                      CustomTextField(
                        controller: _locationController,
                        labelText: 'الموقع',
                        hintText: 'مثال: الرياض، جدة، الدمام',
                        prefixIcon: Icons.location_on,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
                        'وصف السيارة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'أدخل وصفًا تفصيليًا للسيارة...',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.required('يرجى إدخال وصف السيارة'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // المواصفات الفنية
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المواصفات الفنية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: _addSpecification,
                            tooltip: 'إضافة مواصفة',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_specifications.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'لا توجد مواصفات حتى الآن. انقر على زر الإضافة لإضافة مواصفات فنية للسيارة.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _specifications.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final spec = _specifications[index];
                            return ListTile(
                              title: Text(spec['key']!),
                              subtitle: Text(spec['value']!),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeSpecification(index),
                                tooltip: 'حذف',
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // زر الحفظ
              CustomButton(
                text: 'حفظ التعديلات',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _saveCar,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // قسم الصور
  Widget _buildImageSection() {
    return Card(
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
              'صور السيارة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك إضافة حتى 5 صور للسيارة',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // عرض الصور الموجودة
            if (_existingImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImages.length,
                  itemBuilder: (context, index) {
                    final image = _existingImages[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              image.fullUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('خطأ في تحميل الصورة: $error');
                                return Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _deleteImage(image.id),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          if (image.isMain)
                            Positioned(
                              bottom: 5,
                              left: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'رئيسية',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // عرض الصور الجديدة
            if (_selectedImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'الصور الجديدة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // زر إضافة صور
            ImagePickerWidget(
              onImagesSelected: (images) {
                setState(() {
                  // التحقق من عدم تجاوز 5 صور
                  final totalImages = _selectedImages.length + _existingImages.length;
                  final remainingSlots = 5 - totalImages;

                  if (remainingSlots <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا يمكن إضافة المزيد من الصور. الحد الأقصى هو 5 صور')),
                    );
                    return;
                  }

                  if (images.length > remainingSlots) {
                    // هنا نحول من File إلى XFile
                    final xFiles = images.take(remainingSlots).map((file) =>
                        XFile(file.path, name: file.path.split('/').last)
                    ).toList();

                    _selectedImages.addAll(xFiles);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم إضافة $remainingSlots صور فقط. الحد الأقصى هو 5 صور')),
                    );
                  } else {
                    // هنا نحول من File إلى XFile
                    final xFiles = images.map((file) =>
                        XFile(file.path, name: file.path.split('/').last)
                    ).toList();

                    _selectedImages.addAll(xFiles);
                  }

                  // طباعة للتصحيح
                  debugPrint('تم اختيار ${_selectedImages.length} صور جديدة');
                  for (var img in _selectedImages) {
                    debugPrint('مسار الصورة: ${img.path}');
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }
}