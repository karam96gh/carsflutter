import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/car_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../presentation/widgets/app_drawer.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  int _totalCars = 0;
  int _newCars = 0;
  int _usedCars = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      await carProvider.loadCars();

      setState(() {
        _totalCars = carProvider.cars.length;
        _newCars = carProvider.cars.where((car) => car.type == 'NEW').length;
        _usedCars = carProvider.cars.where((car) => car.type == 'USED').length;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const CircularProgressIndicator()
          : RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ترحيب بالمستخدم
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                            radius: 24,
                            child: const Icon(
                              Icons.person,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً، ${user?.name ?? 'المدير'}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'مدير النظام',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
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
              const SizedBox(height: 24),

              // عنوان الإحصائيات
              Text(
                'الإحصائيات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // بطاقات الإحصائيات
              Row(
                children: [
                  // إجمالي السيارات
                  Expanded(
                    child: _StatisticCard(
                      title: 'إجمالي السيارات',
                      value: _totalCars.toString(),
                      icon: Icons.directions_car,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // السيارات الجديدة
                  Expanded(
                    child: _StatisticCard(
                      title: 'السيارات الجديدة',
                      value: _newCars.toString(),
                      icon: Icons.fiber_new,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // السيارات المستعملة
                  Expanded(
                    child: _StatisticCard(
                      title: 'السيارات المستعملة',
                      value: _usedCars.toString(),
                      icon: Icons.history,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // عمليات البيع الأخيرة (مساحة للتوسع مستقبلاً)
                  Expanded(
                    child: _StatisticCard(
                      title: 'عمليات البيع',
                      value: '0',
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // الإجراءات السريعة
              Text(
                'الإجراءات السريعة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // بطاقات الإجراءات السريعة
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _ActionCard(
                    title: 'إضافة سيارة',
                    icon: Icons.add_circle_outline,
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addCar);
                    },
                  ),
                  _ActionCard(
                    title: 'عرض السيارات',
                    icon: Icons.list_alt,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.carList);
                    },
                  ),
                  _ActionCard(
                    title: 'البحث',
                    icon: Icons.search,
                    color: Colors.purple,
                    onTap: () {
                      // فتح شاشة البحث
                      showSearch(
                        context: context,
                        delegate: CarSearchDelegate(
                          Provider.of<CarProvider>(context, listen: false).cars,
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    title: 'التقارير',
                    icon: Icons.bar_chart,
                    color: Colors.green,
                    onTap: () {
                      // شاشة التقارير (يمكن إضافتها لاحقاً)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ستتوفر قريباً')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addCar);
        },
        child: const Icon(Icons.add),
        tooltip: 'إضافة سيارة جديدة',
      ),
    );
  }
}

// مكون بطاقة الإحصائيات
class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// مكون بطاقة الإجراءات
class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// مكون البحث عن السيارات
class CarSearchDelegate extends SearchDelegate<String> {
  final List<dynamic> cars;

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
    final results = cars.where((car) {
      return car.title.toLowerCase().contains(query.toLowerCase()) ||
          car.make.toLowerCase().contains(query.toLowerCase()) ||
          car.model.toLowerCase().contains(query.toLowerCase());
    }).toList();

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
          trailing: Text('${car.year}'),
          onTap: () {
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
    final results = cars.where((car) {
      return car.title.toLowerCase().contains(query.toLowerCase()) ||
          car.make.toLowerCase().contains(query.toLowerCase()) ||
          car.model.toLowerCase().contains(query.toLowerCase());
    }).toList();

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
          trailing: Text('${car.year}'),
          onTap: () {
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