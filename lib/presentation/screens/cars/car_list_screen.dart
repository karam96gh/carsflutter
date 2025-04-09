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
    return Scaffold(
      appBar: AppBar(
        title: const Text('السيارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // عرض شريط البحث
              showSearch(
                context: context,
                delegate: CarSearchDelegate(
                  Provider.of<CarProvider>(context, listen: false).cars,
                ),
              ).then((value) {
                if (value != null && value.isNotEmpty) {
                  _handleSearch(value);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCars,
            tooltip: 'تحديث',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'جديد'),
            Tab(text: 'مستعمل'),
          ],
        ),
      ),
      body: _isLoading
          ? const CircularProgressIndicator()
          : _errorMessage != null
          ? CustomErrorWidget(
        message: _errorMessage!,
        onRetry: _loadCars,
      )
          : _buildCarList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addCar).then((_) {
            _loadCars(); // تحديث القائمة بعد الإضافة
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'إضافة سيارة جديدة',
      ),
    );
  }

  Widget _buildCarList() {
    if (_filteredCars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد سيارات في هذه الفئة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addCar);
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة سيارة'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCars,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredCars.length,
        itemBuilder: (context, index) {
          final car = _filteredCars[index];
          return CarCard(
            car: car,
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
            onDelete: () async {
              // تأكيد الحذف
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تأكيد الحذف'),
                  content: Text('هل أنت متأكد من حذف ${car.make} ${car.model}؟'),
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

              if (confirm == true) {
                try {
                  await Provider.of<CarProvider>(context, listen: false)
                      .deleteCar(car.id);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف السيارة بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _loadCars(); // تحديث القائمة بعد الحذف
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل حذف السيارة: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}

// مكون البحث عن السيارات
class CarSearchDelegate extends SearchDelegate<String> {
  final List<Car> cars;

  CarSearchDelegate(this.cars);

  @override
  String get searchFieldLabel => 'البحث عن سيارة...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
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
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('أدخل نص للبحث'),
      );
    }

    final results = cars.where((car) =>
    car.title.toLowerCase().contains(query.toLowerCase()) ||
        car.make.toLowerCase().contains(query.toLowerCase()) ||
        car.model.toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج لـ "$query"',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final car = results[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: car.type == 'NEW' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car,
              color: car.type == 'NEW' ? Colors.green : Colors.orange,
            ),
          ),
          title: Text(
            '${car.make} ${car.model}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(car.title),
          trailing: Text(
            '${car.year}',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
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
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'ابحث عن سيارة حسب الاسم، الشركة، أو الموديل',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final results = cars.where((car) =>
    car.title.toLowerCase().contains(query.toLowerCase()) ||
        car.make.toLowerCase().contains(query.toLowerCase()) ||
        car.model.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final car = results[index];
        return ListTile(
          leading: Icon(
            Icons.directions_car,
            color: car.type == 'NEW' ? Colors.green : Colors.orange,
          ),
          title: Text('${car.make} ${car.model}'),
          subtitle: Text(car.title),
          onTap: () {
            close(context, query);
            Navigator.pushNamed(
              context,
              AppRoutes.carDetails,
              arguments: car.id,
            );
          },
        );
      },
    );
  }
}

