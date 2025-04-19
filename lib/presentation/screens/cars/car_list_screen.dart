import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/car.dart';
import '../../../data/providers/car_provider.dart';
import '../../widgets/car_card.dart';
import '../../widgets/custom_error_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({Key? key}) : super(key: key);

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;
  List<Car> _filteredCars = [];
  String _searchQuery = '';

  // قائمة الألوان المستخدمة في الواجهة
  final Color _primaryColor = AppTheme.primaryColor;
  final Color _secondaryColor = Colors.indigo;
  final Color _accentColor = Colors.tealAccent;
  final Color _newCarColor = Colors.teal;
  final Color _usedCarColor = Colors.amber.shade700;
  final Color _backgroundColor = Colors.grey.shade50;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCars();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _filterCars();
      });
    }
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<CarProvider>(context, listen: false).loadCars();
      setState(() {
        _isLoading = false;
        _filterCars();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل بيانات السيارات. ${e.toString()}';
      });
    }
  }

  void _filterCars() {
    final cars = Provider.of<CarProvider>(context, listen: false).cars;

    setState(() {
      switch (_tabController.index) {
        case 0: // الكل
          _filteredCars = cars.where((car) =>
          car.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              car.make.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              car.model.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
          break;
        case 1: // جديد
          _filteredCars = cars.where((car) =>
          car.type == 'NEW' && (
              car.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  car.make.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  car.model.toLowerCase().contains(_searchQuery.toLowerCase())
          )
          ).toList();
          break;
        case 2: // مستعمل
          _filteredCars = cars.where((car) =>
          car.type == 'USED' && (
              car.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  car.make.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  car.model.toLowerCase().contains(_searchQuery.toLowerCase())
          )
          ).toList();
          break;
      }
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filterCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _backgroundColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'السيارات',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, size: 26),
              onPressed: () {
                // عرض شريط البحث
                showSearch(
                  context: context,
                  delegate: CarSearchDelegate(
                    Provider.of<CarProvider>(context, listen: false).cars,
                    newCarColor: _newCarColor,
                    usedCarColor: _usedCarColor,
                  ),
                ).then((value) {
                  if (value != null && value.isNotEmpty) {
                    _handleSearch(value);
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 26),
              onPressed: _loadCars,
              tooltip: 'تحديث',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                color: _primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: _accentColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'الكل'),
                  Tab(text: 'جديد'),
                  Tab(text: 'مستعمل'),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? Center(
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              strokeWidth: 3,
            ),
          ),
        )
            : _errorMessage != null
            ? CustomErrorWidget(
          message: _errorMessage!,
          onRetry: _loadCars,
        )
            : _buildCarList(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.addCar).then((_) {
              _loadCars(); // تحديث القائمة بعد الإضافة
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('إضافة سيارة'),
          backgroundColor: _secondaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          tooltip: 'إضافة سيارة جديدة',
        ),
      ),
    );
  }

  Widget _buildCarList() {
    if (_filteredCars.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_car_outlined,
                  size: 72,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'لا توجد سيارات في هذه الفئة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'يمكنك إضافة سيارات جديدة للقائمة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addCar);
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  'إضافة سيارة',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCars,
      color: _primaryColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // تحديد عدد الأعمدة بناءً على حجم الشاشة
          int crossAxisCount = constraints.maxWidth < 600 ? 1 :
          (constraints.maxWidth < 900 ? 2 : 3);

          if (crossAxisCount == 1) {
            // عرض قائمة عمودية للشاشات الصغيرة
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCars.length,
              itemBuilder: (context, index) {
                final car = _filteredCars[index];
                return CarCard(
                  car: car,
                  newCarColor: _newCarColor,
                  usedCarColor: _usedCarColor,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.carDetails,
                      arguments: car.id,
                    ).then((_) {
                      _loadCars(); // تحديث القائمة بعد العودة من التفاصيل
                    });
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editCar,
                      arguments: car.id,
                    ).then((_) {
                      _loadCars(); // تحديث القائمة بعد التعديل
                    });
                  },
                  onDelete: () => _showDeleteConfirmation(car),
                );
              },
            );
          } else {
            // عرض شبكة للشاشات المتوسطة والكبيرة
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredCars.length,
              itemBuilder: (context, index) {
                final car = _filteredCars[index];
                return CarCard(
                  car: car,
                  newCarColor: _newCarColor,
                  usedCarColor: _usedCarColor,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.carDetails,
                      arguments: car.id,
                    ).then((_) {
                      _loadCars();
                    });
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editCar,
                      arguments: car.id,
                    ).then((_) {
                      _loadCars();
                    });
                  },
                  onDelete: () => _showDeleteConfirmation(car),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Car car) async {
    // تأكيد الحذف بتصميم محسن
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'هل أنت متأكد من حذف هذه السيارة؟',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${car.make} ${car.model} (${car.year})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'حذف',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );

    if (confirm == true) {
      try {
        await Provider.of<CarProvider>(context, listen: false)
            .deleteCar(car.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                const Text(
                  'تم حذف السيارة بنجاح',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 3),
          ),
        );

        _loadCars(); // تحديث القائمة بعد الحذف
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'فشل حذف السيارة: ${e.toString()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

// مكون البحث عن السيارات
class CarSearchDelegate extends SearchDelegate<String> {
  final List<Car> cars;
  final Color newCarColor;
  final Color usedCarColor;

  CarSearchDelegate(this.cars, {
    required this.newCarColor,
    required this.usedCarColor,
  });

  @override
  String get searchFieldLabel => 'البحث عن سيارة...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, size: 24),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, size: 24),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchContent(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchContent(context);
  }

  Widget _buildSearchContent(BuildContext context) {
    if (query.isEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search,
                    size: 60,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ابحث عن سيارات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'اكتب اسم الشركة، الموديل، أو أي تفاصيل أخرى للسيارة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final results = cars.where((car) =>
    car.title.toLowerCase().contains(query.toLowerCase()) ||
        car.make.toLowerCase().contains(query.toLowerCase()) ||
        car.model.toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 60,
                    color: Colors.orange[600],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'لا توجد نتائج',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد سيارات تطابق: "$query"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    query = '';
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('مسح البحث'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.withOpacity(0.3),
          thickness: 1,
        ),
        itemBuilder: (context, index) {
          final car = results[index];
          final isNewCar = car.type == 'NEW';
          final carColor = isNewCar ? newCarColor : usedCarColor;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: carColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: carColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: carColor,
                  size: 32,
                ),
              ),
              title: Text(
                '${car.make} ${car.model}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    car.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: carColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: carColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isNewCar ? 'جديدة' : 'مستعملة',
                          style: TextStyle(
                            color: carColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${car.year}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${car.price} ريال',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              onTap: () {
                close(context, query);
                Navigator.pushNamed(
                  context,
                  AppRoutes.carDetails,
                  arguments: car.id,
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}