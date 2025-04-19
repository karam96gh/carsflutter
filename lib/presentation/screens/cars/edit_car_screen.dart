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
  final Map<String, Map<String, dynamic>> carData = {
    'Toyota': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/toyota.png',
      'models': [
        'Camry', 'Corolla', 'RAV4', 'Land Cruiser', 'Yaris',
        'Prius', 'Hilux', 'Tacoma', '4Runner', 'Highlander',
        'Avalon', 'Tundra', 'Sequoia', 'Celica', 'Supra',
        'MR2', 'C-HR', 'Venza', 'Sienna', 'Corona'
      ],
    },
    'BMW': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/bmw.png',
      'models': [
        'X5', 'X3', '3 Series', '5 Series', '7 Series',
        'X1', 'X7', 'M3', 'M5', 'Z4',
        'i8', 'i3', '2 Series', '4 Series', '6 Series',
        '8 Series', 'X6', 'M4', 'M2', '2002'
      ],
    },
    'Mercedes-Benz': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/mercedes-benz.png',
      'models': [
        'E200', 'C-Class', 'S-Class', 'GLA', 'GLE',
        'A-Class', 'B-Class', 'CLS', 'GLC', 'GLS',
        'SL', 'SLK', 'AMG GT', 'CLK', 'EQC',
        '190E', '300SL', '600', 'Maybach', 'Sprinter'
      ],
    },
    'Chevrolet': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/chevrolet.png',
      'models': [
        'Camaro', 'Corvette', 'Impala', 'Malibu', 'Silverado',
        'Tahoe', 'Suburban', 'Equinox', 'Traverse', 'Cruze',
        'Spark', 'Aveo', 'Volt', 'Bolt', 'Blazer',
        'Nova', 'Caprice', 'Bel Air', 'Monte Carlo', 'Chevelle'
      ],
    },
    'Hyundai': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/hyundai.png',
      'models': [
        'Tucson', 'Sonata', 'Elantra', 'Santa Fe', 'Accent',
        'Kona', 'Palisade', 'Veloster', 'Genesis Coupe', 'i10',
        'i20', 'i30', 'Azera', 'Equus', 'XG350',
        'Staria', 'Venue', 'IONIQ', 'Nexo', 'Pony'
      ],
    },
    'Kia': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/kia.png',
      'models': [
        'Sportage', 'Cerato', 'Sorento', 'Picanto', 'Rio',
        'Optima', 'Carnival', 'Stinger', 'Telluride', 'Seltos',
        'EV6', 'Niro', 'Soul', 'Forte', 'Cadenza',
        'K5', 'K900', 'Borrego', 'Magentis', 'Pride'
      ],
    },
    'Audi': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/audi.png',
      'models': [
        'A4', 'A6', 'Q5', 'Q7', 'A8',
        'A3', 'A5', 'Q3', 'Q8', 'TT',
        'R8', 'e-tron', 'RS6', 'S4', '100',
        '200', 'Quattro', 'V8', 'RS3', 'RS7'
      ],
    },
    'KGM (Ssangyong)': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/ssangyong.png',
      'models': [
        'Rexton', 'Tivoli', 'Korando', 'Musso', 'Actyon',
        'Chairman', 'Stavic', 'Rodius', 'Korando Sports', 'XLV',
        'Kyron', 'Rexton Sports', 'Turismo', 'XAV', 'Damas'
      ],
    },
    'Genesis': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/genesis.png',
      'models': [
        'G70', 'G80', 'G90', 'GV70', 'GV80',
        'GV60', 'EQ900', 'Mint', 'Essentia', 'X',
        'New York', 'GV90', 'G80 Electrified', 'GV70 Electrified', 'X Speedium Coupe'
      ],
    },
    'Renault': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/renault.png',
      'models': [
        'Clio', 'Megane', 'Captur', 'Kadjar', 'Duster',
        'Talisman', 'Koleos', 'Zoe', 'Twingo', 'Laguna',
        'Safrane', 'Avantime', 'Vel Satis', 'Fluence', 'Wind',
        '4CV', '5', '8', '9', '11'
      ],
    },
    'Jeep': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/jeep.png',
      'models': [
        'Wrangler', 'Grand Cherokee', 'Cherokee', 'Compass', 'Renegade',
        'Gladiator', 'Liberty', 'Patriot', 'Commander', 'Wagoneer',
        'CJ', 'Willys', 'FC', 'DJ', 'Forward Control',
        'J-Series', 'Honcho', 'Cherokee XJ', 'Grand Wagoneer', 'Scrambler'
      ],
    },
    'Porsche': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/porsche.png',
      'models': [
        '911', 'Cayenne', 'Panamera', 'Macan', 'Taycan',
        'Boxster', 'Cayman', '918 Spyder', '356', '928',
        '944', '968', '959', 'Carrera GT', 'Mission E',
        '550 Spyder', '904', '906', '908', '917'
      ],
    },
    'Volkswagen': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/volkswagen.png',
      'models': [
        'Golf', 'Passat', 'Tiguan', 'Jetta', 'Polo',
        'Arteon', 'Atlas', 'Beetle', 'ID.4', 'Touareg',
        'Scirocco', 'Type 2', 'Karmann Ghia', 'Corrado', 'Lupo',
        'Phideon', 'Santana', 'Vento', 'Fox', 'Derby'
      ],
    },
    'Land Rover': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/land rover.png',
      'models': [
        'Range Rover', 'Discovery', 'Defender', 'Range Rover Sport', 'Range Rover Evoque',
        'Range Rover Velar', 'Freelander', 'Discovery Sport', 'Series I', 'Series II',
        'Series III', 'Range Rover Classic', 'Range Rover P38', 'Range Rover L322', 'DC100',
        'LR2', 'LR3', 'LR4', 'Range Rover SVAutobiography', 'Range Rover PHEV'
      ],
    },
    'Mini': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/mini.png',
      'models': [
        'Cooper', 'Countryman', 'Clubman', 'Paceman', 'Convertible',
        'Coupe', 'Roadster', 'John Cooper Works', 'GP', 'Electric',
        'Mini E', 'Mini 1000', 'Mini 1275GT', 'Mini Van', 'Mini Pickup',
        'Mini Moke', 'Mini Traveller', 'Mini Cooper S', 'Mini One', 'Mini Seven'
      ],
    },
    'Honda': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/honda.png',
      'models': [
        'Civic', 'Accord', 'CR-V', 'Pilot', 'Odyssey',
        'Fit', 'HR-V', 'Ridgeline', 'Passport', 'Insight',
        'S2000', 'NSX', 'Prelude', 'Integra', 'Legend',
        'Jazz', 'City', 'N-One', 'N-Box', 'Acty'
      ],
    },
    'Lexus': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/lexus.png',
      'models': [
        'ES', 'RX', 'NX', 'LS', 'GX',
        'LX', 'UX', 'LC', 'RC', 'IS',
        'CT', 'HS', 'LFA', 'SC', 'GS',
        'ES Hybrid', 'RX Hybrid', 'NX Hybrid', 'LS Hybrid', 'UX Hybrid'
      ],
    },
    'Ford': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/ford.png',
      'models': [
        'F-150', 'Mustang', 'Explorer', 'Focus', 'Escape',
        'Ranger', 'Edge', 'Fiesta', 'Bronco', 'Expedition',
        'Taurus', 'Model T', 'Thunderbird', 'GT', 'Fusion',
        'Galaxie', 'Fairlane', 'Pinto', 'Festiva', 'Probe'
      ],
    },
    'Nissan': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/nissan.png',
      'models': [
        'Altima', 'Maxima', 'Rogue', 'Sentra', 'Pathfinder',
        'Murano', 'Frontier', 'Titan', '370Z', 'GT-R',
        'Leaf', 'Versa', 'Juke', 'X-Trail', 'Sunny',
        'Patrol', 'Silvia', 'Skyline', 'Pulsar', 'Micra'
      ],
    },
    'Volvo': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/volvo.png',
      'models': [
        'XC90', 'XC60', 'XC40', 'S90', 'S60',
        'V90', 'V60', 'V40', '240', '740',
        '850', 'C30', 'P1800', 'Amazon', 'PV544',
        'S40', 'S70', 'V70', 'XC70', 'Polestar'
      ],
    },
    'Peugeot': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/peugeot.png',
      'models': [
        '208', '308', '508', '2008', '3008',
        '5008', '108', '407', '607', 'RCZ',
        'Partner', 'Expert', 'Boxer', '504', '505',
        '604', '205', '206', '207', '106'
      ],
    },
    'Tesla': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/tesla.png',
      'models': [
        'Model S', 'Model 3', 'Model X', 'Model Y', 'Cybertruck',
        'Roadster', 'Semi', 'Model S Plaid', 'Model X Plaid', 'Model 3 Performance',
        'Model Y Performance', 'Roadster 2020', 'Model 2', 'Model Q', 'Model R',
        'Model A', 'Model B', 'Model C', 'Model D', 'Model E'
      ],
    },
    'Maserati': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/maserati.png',
      'models': [
        'Ghibli', 'Quattroporte', 'Levante', 'GranTurismo', 'MC20',
        'GranCabrio', '3200 GT', 'Coupe', 'Spyder', 'Bora',
        'Merak', 'Khamsin', 'Indy', 'Sebring', 'Mexico',
        'Shamal', 'Barchetta', 'A6', '8C', 'Tipo 61'
      ],
    },
    'Suzuki': {
      'logo': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/suzuki.png',
      'models': [
        'Swift', 'Vitara', 'Jimny', 'Baleno', 'Celerio',
        'Ignis', 'SX4', 'Alto', 'Wagon R', 'Kizashi',
        'Samurai', 'Sidekick', 'Esteem', 'Grand Vitara', 'XL7',
        'Cappuccino', 'Carry', 'Liana', 'Splash', 'X-90'
      ],
    },
  };

  // حقول المعلومات الأساسية
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _locationController = TextEditingController();

  // حقول المعلومات الإضافية
  final _engineSizeController = TextEditingController();
  final _doorsController = TextEditingController();
  final _passengersController = TextEditingController();
  final _exteriorColorController = TextEditingController();
  final _vinController = TextEditingController();
  final _originController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _lengthController = TextEditingController();

  // قوائم الاختيار
  String _type = 'NEW'; // NEW or USED
  String _category = 'SUV'; // LUXURY, ECONOMY, SUV, SPORTS, SEDAN, OTHER
  String _fuel = 'بنزين';
  String _transmission = 'أوتوماتيك';
  String _driveType = 'دفع أمامي';
  String? _selectedBrand;
  String? _selectedModel;
  bool _isLoading = false;
  bool _isInitialized = false;
  List<XFile> _selectedImages = [];
  List<CarImage> _existingImages = [];
  List<Map<String, String>> _specifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCarData();

    });
  }

  @override
  void dispose() {
    // التخلص من المتحكمات الأساسية
    _titleController.dispose();
    _descriptionController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _contactNumberController.dispose();
    _locationController.dispose();

    // التخلص من المتحكمات الإضافية
    _engineSizeController.dispose();
    _doorsController.dispose();
    _passengersController.dispose();
    _exteriorColorController.dispose();
    _vinController.dispose();
    _originController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _lengthController.dispose();

    super.dispose();
  }

  // تحميل بيانات السيارة للتعديل
  Future<void> _loadCarData() async {
    setState(() => _isLoading = true);

    try {
      final car = await Provider.of<CarProvider>(context, listen: false)
          .getCarById(widget.carId);

      // معلومات أساسية
      _titleController.text = car.title;
      _descriptionController.text = car.description;
      _makeController.text = car.make;
      _modelController.text = car.model;
      _yearController.text = car.year.toString();
      _mileageController.text = car.mileage?.toString() ?? '';
      _priceController.text = car.price.toString();
      _contactNumberController.text = car.contactNumber;
      _locationController.text = car.location ?? '';


      // معلومات إضافية
      _engineSizeController.text = car.engineSize ?? '';
      _doorsController.text = car.doors?.toString() ?? '';
      _passengersController.text = car.passengers?.toString() ?? '';
      _exteriorColorController.text = car.exteriorColor ?? '';
      _vinController.text = car.vin ?? '';
      _originController.text = car.origin ?? '';

      // الأبعاد
      if (car.dimensions != null) {
        _widthController.text = car.dimensions!['width']?.toString() ?? '';
        _heightController.text = car.dimensions!['height']?.toString() ?? '';
        _lengthController.text = car.dimensions!['length']?.toString() ?? '';
      }

      setState(() {

        _type = car.type;
        _category = car.category;
        _fuel = car.fuel ?? 'بنزين';
        _transmission = car.transmission ?? 'أوتوماتيك';
        _driveType = car.driveType ?? 'دفع أمامي';
        _existingImages = car.images;
        _specifications = car.specifications
            .map((spec) => {'key': spec.key, 'value': spec.value})
            .toList();
        _isInitialized = true;
        _isLoading = false;
      });
      _selectedBrand=car.make;
      _selectedModel=car.model;
      // طباعة URLs الصور للتشخيص
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
      // إعداد الأبعاد
      Map<String, double> dimensions = {};
      if (_widthController.text.isNotEmpty) {
        dimensions['width'] = double.parse(_widthController.text);
      }
      if (_heightController.text.isNotEmpty) {
        dimensions['height'] = double.parse(_heightController.text);
      }
      if (_lengthController.text.isNotEmpty) {
        dimensions['length'] = double.parse(_lengthController.text);
      }

      // إعداد بيانات السيارة
      final carData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _type,
        'category': _category,
        'make': _selectedBrand,
        'model': _selectedModel,
        'year': int.parse(_yearController.text),
        'mileage': _mileageController.text.isEmpty ? null : int.parse(_mileageController.text),
        'price': double.parse(_priceController.text),
        'contactNumber': _contactNumberController.text,
        'location': _locationController.text.isEmpty ? null : _locationController.text,
        'specifications': _specifications, // تأكد من تضمين المواصفات هنا

        // البيانات الإضافية
        'fuel': _fuel,
        'transmission': _transmission,
        'driveType': _driveType,
        'doors': _doorsController.text.isEmpty ? null : int.parse(_doorsController.text),
        'passengers': _passengersController.text.isEmpty ? null : int.parse(_passengersController.text),
        'exteriorColor': _exteriorColorController.text.isEmpty ? null : _exteriorColorController.text,
        'engineSize': _engineSizeController.text.isEmpty ? null : _engineSizeController.text,
        'vin': _vinController.text.isEmpty ? null : _vinController.text,
        'origin': _originController.text.isEmpty ? null : _originController.text,
        'dimensions': dimensions.isEmpty ? null : dimensions,
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
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // معلومات الاتصال
              _buildContactInfoSection(),
              const SizedBox(height: 24),

              // التفاصيل الفنية
              _buildTechnicalDetailsSection(),
              const SizedBox(height: 24),

              // معلومات إضافية
              _buildAdditionalInfoSection(),
              const SizedBox(height: 24),

              // الأبعاد
              _buildDimensionsSection(),
              const SizedBox(height: 24),

              // الوصف
              _buildDescriptionSection(),
              const SizedBox(height: 24),

              // المواصفات الفنية
              _buildSpecificationsSection(),
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
                });
              },
            )
          ],
        ),
      ),
    );
  }

  // قسم المعلومات الأساسية
  Widget _buildBasicInfoSection() {
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
              hintText: 'مثال: هيونداي توسان 2018 بحالة ممتازة',
              prefixIcon: Icons.title,
              validator: Validators.required('يرجى إدخال عنوان السيارة'),
            ),
            const SizedBox(height: 16),

            // // الشركة المصنعة
            // CustomTextField(
            //   controller: _makeController,
            //   labelText: 'الشركة المصنعة',
            //   hintText: 'مثال: هيونداي، تويوتا، مرسيدس',
            //   prefixIcon: Icons.business,
            //   validator: Validators.required('يرجى إدخال الشركة المصنعة'),
            // ),
            // const SizedBox(height: 16),
            //
            // // الموديل
            // CustomTextField(
            //   controller: _modelController,
            //   labelText: 'الموديل',
            //   hintText: 'مثال: توسان، كامري، E200',
            //   prefixIcon: Icons.branding_watermark,
            //   validator: Validators.required('يرجى إدخال الموديل'),
            // ),
            // const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedBrand,

              hint: Text('اختر الشركة المصنعة'),
              onChanged: (String? newBrand) {
                setState(() {
                  _selectedBrand = newBrand;
                  _selectedModel = null; // Reset selected model when brand changes
                });
              },
              items: carData.keys.map((String brand) {
                return DropdownMenuItem<String>(
                  value: brand,
                  child: Text(brand),
                );
              }).toList(),
            ),
            if (_selectedBrand != null)
              Column(
                children: [
                  DropdownButton<String>(
                    value: _selectedModel,
                    hint: Text('اختر الموديل'),
                    onChanged: (String? newModel) {
                      setState(() {
                        _selectedModel = newModel;
                      });
                    },
                    items: carData[_selectedBrand!]?['models']
                        .map<DropdownMenuItem<String>>((String model) {
                      return DropdownMenuItem<String>(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                  ),
                ],
              ),
            // فئة السيارة
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'فئة السيارة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'LUXURY',
                  child: Text('فاخرة'),
                ),
                DropdownMenuItem(
                  value: 'ECONOMY',
                  child: Text('اقتصادية'),
                ),
                DropdownMenuItem(
                  value: 'SUV',
                  child: Text('دفع رباعي (SUV)'),
                ),
                DropdownMenuItem(
                  value: 'SPORTS',
                  child: Text('رياضية'),
                ),
                DropdownMenuItem(
                  value: 'SEDAN',
                  child: Text('سيدان'),
                ),
                DropdownMenuItem(
                  value: 'OTHER',
                  child: Text('أخرى'),
                ),
              ],
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
              hintText: 'مثال: 2018',
              prefixIcon: Icons.calendar_today,
              keyboardType: TextInputType.number,
              validator: Validators.combine([
                Validators.required('يرجى إدخال سنة الصنع'),
                Validators.isInteger('يرجى إدخال سنة صالحة'),
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
    );
  }

  // قسم معلومات الاتصال
  Widget _buildContactInfoSection() {
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
    );
  }

  // قسم التفاصيل الفنية
  Widget _buildTechnicalDetailsSection() {
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
              'التفاصيل الفنية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // نوع الوقود
            DropdownButtonFormField<String>(
              value: _fuel,
              decoration: const InputDecoration(
                labelText: 'نوع الوقود',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'بنزين',
                  child: Text('بنزين'),
                ),
                DropdownMenuItem(
                  value: 'ديزل',
                  child: Text('ديزل'),
                ),
                DropdownMenuItem(
                  value: 'كهرباء',
                  child: Text('كهرباء'),
                ),
                DropdownMenuItem(
                  value: 'هجين',
                  child: Text('هجين'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _fuel = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // سعة المحرك
            CustomTextField(
              controller: _engineSizeController,
              labelText: 'سعة المحرك',
              hintText: 'مثال: 1685cc',
              prefixIcon: Icons.engineering,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // ناقل الحركة
            DropdownButtonFormField<String>(
              value: _transmission,
              decoration: const InputDecoration(
                labelText: 'ناقل الحركة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'أوتوماتيك',
                  child: Text('أوتوماتيك'),
                ),
                DropdownMenuItem(
                  value: 'يدوي',
                  child: Text('يدوي'),
                ),
                DropdownMenuItem(
                  value: 'نصف أوتوماتيك',
                  child: Text('نصف أوتوماتيك'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _transmission = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // نوع الدفع
            DropdownButtonFormField<String>(
              value: _driveType,
              decoration: const InputDecoration(
                labelText: 'نوع الدفع',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.drive_eta),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'دفع أمامي',
                  child: Text('دفع أمامي'),
                ),
                DropdownMenuItem(
                  value: 'دفع خلفي',
                  child: Text('دفع خلفي'),
                ),
                DropdownMenuItem(
                  value: 'دفع رباعي',
                  child: Text('دفع رباعي'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _driveType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // قسم معلومات إضافية
  Widget _buildAdditionalInfoSection() {
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
              'معلومات إضافية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // عدد الأبواب
            CustomTextField(
              controller: _doorsController,
              labelText: 'عدد الأبواب',
              hintText: 'مثال: 5',
              prefixIcon: Icons.sensor_door,
              keyboardType: TextInputType.number,
              validator: Validators.isInteger('يرجى إدخال قيمة صحيحة'),
            ),
            const SizedBox(height: 16),

            // عدد الركاب
            CustomTextField(
              controller: _passengersController,
              labelText: 'عدد الركاب',
              hintText: 'مثال: 5',
              prefixIcon: Icons.people,
              keyboardType: TextInputType.number,
              validator: Validators.isInteger('يرجى إدخال قيمة صحيحة'),
            ),
            const SizedBox(height: 16),

            // اللون الخارجي
            CustomTextField(
              controller: _exteriorColorController,
              labelText: 'اللون الخارجي',
              hintText: 'مثال: أبيض، أسود، فضي',
              prefixIcon: Icons.format_color_fill,
            ),
            const SizedBox(height: 16),

            // رقم هيكل السيارة (VIN)
            CustomTextField(
              controller: _vinController,
              labelText: 'رقم هيكل السيارة (VIN)',
              prefixIcon: Icons.pin,
            ),
            const SizedBox(height: 16),

            // بلد المنشأ
            CustomTextField(
              controller: _originController,
              labelText: 'بلد المنشأ',
              hintText: 'مثال: كوريا الجنوبية، اليابان، ألمانيا',
              prefixIcon: Icons.flag,
            ),
          ],
        ),
      ),
    );
  }

  // قسم الأبعاد
  Widget _buildDimensionsSection() {
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
              'أبعاد السيارة (بالملم)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // الطول
            CustomTextField(
              controller: _lengthController,
              labelText: 'الطول (ملم)',
              hintText: 'مثال: 4475',
              prefixIcon: Icons.height,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // العرض
            CustomTextField(
              controller: _widthController,
              labelText: 'العرض (ملم)',
              hintText: 'مثال: 1850',
              prefixIcon: Icons.width_normal,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // الارتفاع
            CustomTextField(
              controller: _heightController,
              labelText: 'الارتفاع (ملم)',
              hintText: 'مثال: 1650',
              prefixIcon: Icons.height,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  // قسم الوصف
  Widget _buildDescriptionSection() {
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
    );
  }

  // قسم المواصفات الفنية
  Widget _buildSpecificationsSection() {
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
    );
  }
}