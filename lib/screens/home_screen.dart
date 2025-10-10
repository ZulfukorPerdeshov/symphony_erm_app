import 'package:SymphonyERP/screens/warehouse/warehouses_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/inventory_service.dart';
import '../services/company_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/company_selector.dart';
import '../widgets/app_drawer.dart';
import '../models/production.dart';
import '../models/user.dart';
import '../main.dart';
import 'auth/login_screen.dart';
import 'orders/orders_screen.dart';
import 'production/task_detail_screen.dart';
import 'production/task_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<_DashboardScreenState> _dashboardKey = GlobalKey<_DashboardScreenState>();
  final GlobalKey<State<WarehousesListScreen>> _warehouseKey = GlobalKey<State<WarehousesListScreen>>();
  final GlobalKey<State<OrdersScreen>> _ordersKey = GlobalKey<State<OrdersScreen>>();
  final GlobalKey<_ProfileScreenState> _profileKey = GlobalKey<_ProfileScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(key: _dashboardKey),
      WarehousesListScreen(key: _warehouseKey),
      OrdersScreen(key: _ordersKey),
      const ProductionScreen(),
      ProfileScreen(
        key: _profileKey,
        onCompanyChanged: _handleCompanyChanged,
      ),
    ];
  }

  void _handleCompanyChanged() {
    // Refresh all screens when company changes
    _dashboardKey.currentState?._loadMyTasks();
    // Refresh warehouse screen
    if (_warehouseKey.currentState != null) {
      _warehouseKey.currentState!.setState(() {});
    }
    // Refresh orders screen
    if (_ordersKey.currentState != null) {
      _ordersKey.currentState!.setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(AppColors.primaryIndigo),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.warehouse_outlined),
            activeIcon: const Icon(Icons.warehouse),
            label: l10n.warehouse,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart_outlined),
            activeIcon: const Icon(Icons.shopping_cart),
            label: l10n.orders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.factory_outlined),
            activeIcon: const Icon(Icons.factory),
            label: l10n.production,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<MyProductionTaskDto> _myTasks = [];
  bool _isLoadingTasks = false;
  int _selectedTabIndex = 0; // 0: All, 1: To Do, 2: In Progress, 3: Overdue

  @override
  void initState() {
    super.initState();
    _loadMyTasks();
  }

  Future<void> _loadMyTasks() async {
    setState(() => _isLoadingTasks = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final tasks = await InventoryService.getMyProductionTasks(companyId);

      setState(() {
        _myTasks = tasks;
        _isLoadingTasks = false;
      });
    } catch (e) {
      setState(() => _isLoadingTasks = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  List<MyProductionTaskDto> get _filteredTasks {
    switch (_selectedTabIndex) {
      case 1: // To Do
        return _myTasks.where((task) => task.status == 0).toList();
      case 2: // In Progress
        return _myTasks.where((task) => task.status == 1).toList();
      case 3: // Overdue
        return _myTasks.where((task) => task.isOverdue).toList();
      default: // All
        return _myTasks;
    }
  }

  Map<String, int> get _taskStats {
    final todayTasks = _myTasks.where((task) {
      final today = DateTime.now();
      final plannedStart = task.plannedStartDate;
      return plannedStart != null &&
          plannedStart.year == today.year &&
          plannedStart.month == today.month &&
          plannedStart.day == today.day;
    }).length;

    final ongoingTasks = _myTasks.where((task) => task.status == 1).length;
    final completedTasks = _myTasks.where((task) => task.status == 3).length;
    final overdueTasks = _myTasks.where((task) => task.isOverdue).length;

    return {
      'today': todayTasks,
      'ongoing': ongoingTasks,
      'completed': completedTasks,
      'overdue': overdueTasks,
      'total': _myTasks.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = AuthService.currentUser;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()} ${user?.firstName ?? ''}'+'!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              DateHelper.formatDate(DateTime.now()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyTasks,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Header with description
                  Text(
                    l10n.allActivitiesInOnePlace,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primaryIndigo),
                    ),
                  ),
            // const SizedBox(height: 8),
            // Text(
            //   l10n.theHomeScreenGivesUsers,
            //   style: theme.textTheme.bodyMedium?.copyWith(
            //     color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            //   ),
            // ),
            // const SizedBox(height: 24),

            // // Task Status Tabs
            // _buildTaskStatusTabs(context),
            const SizedBox(height: 24),

            // Quick Stats Cards
            _buildQuickStatsCards(context),
            const SizedBox(height: 24),

            // Task Overview Chart
            _buildTaskOverview(context),
            const SizedBox(height: 24),

            // In Progress Tasks
            _buildInProgressTasks(context),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Widget _buildTaskStatusTabs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.all, 'To Do', l10n.inProgress, 'Overdue'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: index < labels.length - 1 ? 12 : 0),
            child: _buildStatusTab(context, label, _selectedTabIndex == index, () {
              setState(() => _selectedTabIndex = index);
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusTab(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(AppColors.primaryIndigo) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(AppColors.primaryIndigo) : theme.colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCards(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = _taskStats;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            l10n.todayTasks,
            '${stats['today']}',
            l10n.tasks,
            const Color(AppColors.primaryIndigo),
            Icons.assignment_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Ongoing',
            '${stats['ongoing']}',
            l10n.tasks,
            const Color(AppColors.accentCyan),
            Icons.play_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskOverview(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final stats = _taskStats;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.taskOverview,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: (stats['ongoing']! + 0.1).toDouble(),
                            color: const Color(AppColors.primaryIndigo),
                            title: '',
                            radius: 25,
                          ),
                          PieChartSectionData(
                            value: (stats['overdue']! + 0.1).toDouble(),
                            color: const Color(AppColors.error),
                            title: '',
                            radius: 20,
                          ),
                          PieChartSectionData(
                            value: (stats['completed']! + 0.1).toDouble(),
                            color: const Color(AppColors.success),
                            title: '',
                            radius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Stats
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats['total']}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.tasks,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(l10n.inProgress, '${stats['ongoing']}', const Color(AppColors.primaryIndigo)),
                      const SizedBox(height: 8),
                      _buildStatRow('Overdue', '${stats['overdue']}', const Color(AppColors.error)),
                      const SizedBox(height: 8),
                      _buildStatRow(l10n.completed, '${stats['completed']}', const Color(AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInProgressTasks(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final filteredTasks = _filteredTasks.take(10).toList(); // Show max 10 tasks

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedTabIndex == 0 ? l10n.tasks : _getTabLabel(_selectedTabIndex),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_filteredTasks.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TaskListScreen(),
                        ),
                      ).then((_) => _loadMyTasks());
                    },
                    child: Text(l10n.showAll),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingTasks)
              const Center(child: CircularProgressIndicator())
            else if (filteredTasks.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.task_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noDataAvailable,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TaskListScreen(),
                          ),
                        ).then((_) => _loadMyTasks());
                      },
                      icon: const Icon(Icons.business),
                      label: Text(l10n.viewCompanyTasks),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(AppColors.primaryIndigo),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredTasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 12),
                    _buildTaskItem(task),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  String _getTabLabel(int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 1:
        return l10n.tasks;
      case 2:
        return l10n.tasks;
      case 3:
        return l10n.tasks;
      default:
        return l10n.tasks;
    }
  }

  Widget _buildTaskItem(MyProductionTaskDto task) {
    final color = _getTaskColor(task.status, task.priority);
    final icon = _getTaskIcon(task.status);

    return InkWell(
      onTap: () => _navigateToTaskDetail(task),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (task.isOverdue)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: const Color(AppColors.error).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.taskIsOverdue,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(AppColors.error),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      task.statusDisplay,
                      '${task.progressPercentage}%',
                      if (task.plannedEndDate != null) 'Due ${_formatTaskDate(task.plannedEndDate!)}',
                    ].join(' • '),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Color _getTaskColor(int status, int priority) {
    switch (status) {
      case 0: // Not Started
        return priority >= 2 ? const Color(AppColors.warning) : Colors.grey;
      case 1: // In Progress
        return const Color(AppColors.info);
      case 2: // Completed
        return const Color(AppColors.success);
      case 3: // Cancelled
        return const Color(AppColors.error);
      case 4: // On Hold
        return const Color(AppColors.warning);
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskIcon(int status) {
    switch (status) {
      case 0: // Not Started
        return Icons.play_circle_outline;
      case 1: // In Progress
        return Icons.hourglass_bottom;
      case 2: // Completed
        return Icons.check_circle_outline;
      case 3: // Cancelled
        return Icons.cancel_outlined;
      case 4: // On Hold
        return Icons.pause_circle_outline;
      default:
        return Icons.task_outlined;
    }
  }

  String _formatTaskDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today'; // This would need a localization key
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow'; // This would need a localization key
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday'; // This would need a localization key
    } else {
      return '${date.day}/${date.month}';
    }
  }

  Future<void> _navigateToTaskDetail(MyProductionTaskDto task) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );

    // Refresh tasks if task was updated
    if (result == true) {
      _loadMyTasks();
    }
  }
}

// Placeholder screens removed - now using actual implementations from warehouse/ and orders/ folders

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.production)),
      body: const Center(child: Text('Production Screen - Coming Soon')),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onCompanyChanged;

  const ProfileScreen({super.key, this.onCompanyChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  Future<void> _handleAvatarUpload() async {
    // TODO: Implement avatar upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.uploadAvatar)),
    );
  }

  Future<void> _handleChangePassword() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      try {
        final request = ChangePasswordRequest(
          currentPassword: result['currentPassword']!,
          newPassword: result['newPassword']!,
        );

        await AuthService.changePassword(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.passwordChangedSuccessfully),
              backgroundColor: const Color(AppColors.success),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${e.toString()}'),
              backgroundColor: const Color(AppColors.error),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(AppColors.gradientStart),
                    Color(AppColors.gradientMiddle),
                    Color(AppColors.gradientEnd),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage: user?.avatarUrl != null
                              ? NetworkImage('${ApiConstants.identityServiceBaseUrl}/${user!.avatarUrl}!')
                              : null,
                          child: user?.avatarUrl == null
                              ? Text(
                                  user?.initials ?? 'U',
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _handleAvatarUpload,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Color(AppColors.primaryIndigo),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings Sections
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company & Branch Section
                  _buildSectionHeader(context, 'Company & Branch'),
                  const SizedBox(height: 12),
                  CompanySelector(onCompanyChanged: (companyId) {
                    setState(() {});
                    // Notify parent HomeScreen to refresh all screens
                    widget.onCompanyChanged?.call();
                  }),

                  const SizedBox(height: 24),

                  // Account Settings
                  _buildSectionHeader(context, 'Account Settings'),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.lock_outline,
                    title: l10n.changePassword,
                    subtitle: l10n.updateProfile,
                    onTap: _handleChangePassword,
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.person_outline,
                    title: l10n.updateProfile,
                    subtitle: l10n.profileUpdatedSuccessfully,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.updateProfile)),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // App Preferences
                  _buildSectionHeader(context, 'App Preferences'),
                  const SizedBox(height: 12),
                  _buildLanguageSelector(context),
                  const SizedBox(height: 8),
                  _buildThemeSelector(context),

                  const SizedBox(height: 24),

                  // About
                  _buildSectionHeader(context, 'About'),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline,
                    title: l10n.settings,
                    subtitle: AppConstants.appVersion,
                    showArrow: false,
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.logout),
                            content: Text(l10n.logoutConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.logout),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && mounted) {
                          await AuthService.logout();
                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logout),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(AppColors.error),
                        side: BorderSide(color: Color(AppColors.error)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: showArrow ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final languageName = locale.languageCode == 'ru' ? 'Русский' :
                         locale.languageCode == 'uz' ? 'O\'zbekcha' : 'English';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.language, color: theme.colorScheme.primary),
        ),
        title: Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(languageName),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _LanguageSelector(
              currentLocale: locale,
              onLanguageChanged: (newLocale) {
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeName = themeProvider.themeMode == ThemeMode.light ? l10n.lightTheme :
                      themeProvider.themeMode == ThemeMode.dark ? l10n.darkTheme : l10n.systemTheme;

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.brightness_6, color: theme.colorScheme.primary),
        ),
        title: Text(l10n.theme, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(themeName),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _ThemeSelector(
              currentThemeMode: themeProvider.themeMode,
              onThemeChanged: (newMode) {
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}

// Change Password Dialog
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.changePassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              decoration: InputDecoration(
                labelText: l10n.currentPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? l10n.passwordRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: l10n.newPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return l10n.passwordRequired;
                if (value!.length < 6) return l10n.passwordTooShort;
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return l10n.passwordRequired;
                if (value != _newPasswordController.text) return l10n.passwordsDoNotMatch;
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, {
                'currentPassword': _currentPasswordController.text,
                'newPassword': _newPasswordController.text,
              });
            }
          },
          child: Text(l10n.changePassword),
        ),
      ],
    );
  }
}

// Language Selector Bottom Sheet
class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale)? onLanguageChanged;

  const _LanguageSelector({required this.currentLocale, this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildLanguageOption(context, 'English', 'en', isSelected: currentLocale.languageCode == 'en'),
          _buildLanguageOption(context, 'Русский', 'ru', isSelected: currentLocale.languageCode == 'ru'),
          _buildLanguageOption(context, 'O\'zbekcha', 'uz', isSelected: currentLocale.languageCode == 'uz'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code, {bool isSelected = false}) {
    return ListTile(
      title: Text(name),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        final newLocale = Locale(code);
        Provider.of<AppStateProvider>(context, listen: false).setLocale(newLocale);
        onLanguageChanged?.call(newLocale);
        Navigator.pop(context);
      },
    );
  }
}

// Theme Selector Bottom Sheet
class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode)? onThemeChanged;

  const _ThemeSelector({required this.currentThemeMode, this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.theme,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildThemeOption(context, l10n.lightTheme, Icons.light_mode, ThemeMode.light, isSelected: currentThemeMode == ThemeMode.light),
          _buildThemeOption(context, l10n.darkTheme, Icons.dark_mode, ThemeMode.dark, isSelected: currentThemeMode == ThemeMode.dark),
          _buildThemeOption(context, l10n.systemTheme, Icons.brightness_auto, ThemeMode.system, isSelected: currentThemeMode == ThemeMode.system),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String name, IconData icon, ThemeMode mode, {bool isSelected = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        Provider.of<ThemeProvider>(context, listen: false).setThemeMode(mode);
        onThemeChanged?.call(mode);
        Navigator.pop(context);
      },
    );
  }
}