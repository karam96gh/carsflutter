import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/car_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../presentation/widgets/app_drawer.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';

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
    });
  }

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
    // حساب حجم الشاشة
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    final isLargeScreen = screenSize.width >= 900;

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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStatistics,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ترحيب بالمستخدم
                  _buildWelcomeCard(context, user),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // عنوان الإحصائيات
                  Text(
                    'الإحصائيات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // بطاقات الإحصائيات
                  _buildStatisticsCards(context, isSmallScreen, isMediumScreen, isLargeScreen),
                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // الإجراءات السريعة
                  Text(
                    'الإجراءات السريعة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // بطاقات الإجراءات السريعة
                  _buildActionCards(context, isSmallScreen, isMediumScreen, isLargeScreen),
                ],
              ),
            );
          },
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

  Widget _buildWelcomeCard(BuildContext context, dynamic user) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 600;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(isNarrow ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      radius: isNarrow ? 20 : 24,
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: isNarrow ? 20 : 24,
                      ),
                    ),
                    SizedBox(width: isNarrow ? 8 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً، ${user?.name ?? 'المدير'}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isNarrow ? 18 : null,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCards(BuildContext context, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    // قائمة بطاقات الإحصائيات
    final statCards = [
      {
        'title': 'إجمالي السيارات',
        'value': _totalCars.toString(),
        'icon': Icons.directions_car,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'السيارات الجديدة',
        'value': _newCars.toString(),
        'icon': Icons.fiber_new,
        'color': Colors.green,
      },
      {
        'title': 'السيارات المستعملة',
        'value': _usedCars.toString(),
        'icon': Icons.history,
        'color': Colors.orange,
      },
      {
        'title': 'عمليات البيع',
        'value': '0',
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
      },
    ];

    // تحديد عدد الأعمدة بناءً على حجم الشاشة
    int crossAxisCount = isSmallScreen ? 1 : (isMediumScreen ? 2 : 2);
    double spacing = isSmallScreen ? 10 : 16;
    double childAspectRatio = isSmallScreen ? 2.5 : 2.2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: statCards.length,
      itemBuilder: (context, index) {
        final card = statCards[index];
        return _StatisticCard(
          title: card['title'] as String,
          value: card['value'] as String,
          icon: card['icon'] as IconData,
          color: card['color'] as Color,
        );
      },
    );
  }

  Widget _buildActionCards(BuildContext context, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    // قائمة الإجراءات
    final actionCards = [
      {
        'title': 'إضافة سيارة',
        'icon': Icons.add_circle_outline,
        'color': AppTheme.primaryColor,
        'onTap': () {
          Navigator.pushNamed(context, AppRoutes.addCar);
        },
      },
      {
        'title': 'عرض السيارات',
        'icon': Icons.list_alt,
        'color': Colors.blue,
        'onTap': () {
          Navigator.pushNamed(context, AppRoutes.carList);
        },
      },
      {
        'title': 'البحث',
        'icon': Icons.search,
        'color': Colors.purple,
        'onTap': () {
          showSearch(
            context: context,
            delegate: CarSearchDelegate(
              Provider.of<CarProvider>(context, listen: false).cars,
            ),
          );
        },
      },
      {
        'title': 'التقارير',
        'icon': Icons.bar_chart,
        'color': Colors.green,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ستتوفر قريباً')),
          );
        },
      },
    ];

    // تحديد عدد الأعمدة ونسبة العرض بناءً على حجم الشاشة
    int crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);
    double childAspectRatio = isSmallScreen ? 1.0 : 1.2;
    double spacing = 12;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: actionCards.length,
        itemBuilder: (context, index) {
          final card = actionCards[index];
          return _ActionCard(
            title: card['title'] as String,
            icon: card['icon'] as IconData,
            color: card['color'] as Color,
            onTap: card['onTap'] as VoidCallback,
          );
        },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 200;
        final double iconSize = isNarrow ? 32 : 36;

        return Card(
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  color.withOpacity(0.1),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(isNarrow ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: iconSize,
                        ),
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: isNarrow ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isNarrow ? 8 : 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: isNarrow ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 200;
        final bool isCompact = constraints.maxWidth < 150;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Card(
            elevation: 4,
            shadowColor: color.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white,
                    color.withOpacity(0.08),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 10.0 : (isNarrow ? 12.0 : 16.0)),
                child: isCompact
                // التصميم الأفقي للشاشات الصغيرة جداً
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                // التصميم العمودي للشاشات العادية
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isNarrow ? 8 : 12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: isNarrow ? 26 : 32,
                      ),
                    ),
                    SizedBox(height: isNarrow ? 8 : 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[800],
                        fontSize: isNarrow ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = cars.where((car) {
      return car.title.toLowerCase().contains(query.toLowerCase()) ||
          car.make.toLowerCase().contains(query.toLowerCase()) ||
          car.model.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl, // تحديد اتجاه النص للغة العربية
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return results.isEmpty
              ? Center(
            child: Text(
              'لا توجد نتائج للبحث',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
              : ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final car = results[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.0 : 16.0,
                  vertical: isSmallScreen ? 4.0 : 8.0,
                ),
                leading: Icon(
                  Icons.directions_car,
                  color: car.type == 'NEW' ? Colors.green : Colors.orange,
                  size: isSmallScreen ? 24 : 28,
                ),
                title: Text(
                  '${car.make} ${car.model}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  car.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${car.year}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
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
        },
      ),
    );
  }
}