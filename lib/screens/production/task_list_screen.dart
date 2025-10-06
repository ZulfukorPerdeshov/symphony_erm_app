import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/production.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<MyProductionTaskDto> _tasks = [];
  List<MyProductionTaskDto> _filteredTasks = [];
  bool _isLoading = false;
  int _selectedFilterIndex = 0; // 0: All, 1: To Do, 2: In Progress, 3: Overdue
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final tasks = await InventoryService.getMyProductionTasks(companyId);

      setState(() {
        _tasks = tasks;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    List<MyProductionTaskDto> filtered = _tasks;

    // Apply status filter
    switch (_selectedFilterIndex) {
      case 1: // To Do
        filtered = filtered.where((task) => task.status == 0).toList();
        break;
      case 2: // In Progress
        filtered = filtered.where((task) => task.status == 1).toList();
        break;
      case 3: // Overdue
        filtered = filtered.where((task) => task.isOverdue).toList();
        break;
      default: // All
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredTasks = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilterIndex = index;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myTasks),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchTasks,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),

          // Filter Tabs
          _buildFilterTabs(),

          // Task Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredTasks.length} ${l10n.tasks}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            return _buildTaskCard(task);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.all, 'To Do', l10n.inProgress, 'Overdue'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: index < labels.length - 1 ? 12 : 0),
            child: _buildFilterChip(label, _selectedFilterIndex == index, () {
              _onFilterChanged(index);
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
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

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTasksFound,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryAdjustingFilters,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(MyProductionTaskDto task) {
    final color = _getTaskColor(task.status, task.priority);
    final icon = _getTaskIcon(task.status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () => _navigateToTaskDetail(task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTaskBadge(
                    task.statusDisplay,
                    color,
                  ),
                  const SizedBox(width: 8),
                  _buildTaskBadge(
                    task.priorityDisplay,
                    _getPriorityColor(task.priority),
                  ),
                  if (task.isOverdue) ...[
                    const SizedBox(width: 8),
                    _buildTaskBadge(
                      AppLocalizations.of(context)!.taskIsOverdue,
                      const Color(AppColors.error),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: task.progressPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${task.progressPercentage}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (task.plannedEndDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatTaskDate(task.plannedEndDate!)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
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
      case 2: // On Hold
        return const Color(AppColors.warning);
      case 3: // Completed
        return const Color(AppColors.success);
      case 4: // Cancelled
        return const Color(AppColors.error);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return const Color(AppColors.success);
      case 1:
        return const Color(AppColors.info);
      case 2:
        return const Color(AppColors.warning);
      case 3:
        return const Color(AppColors.error);
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
      case 2: // On Hold
        return Icons.pause_circle_outline;
      case 3: // Completed
        return Icons.check_circle_outline;
      case 4: // Cancelled
        return Icons.cancel_outlined;
      default:
        return Icons.task_outlined;
    }
  }

  String _formatTaskDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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
      _loadTasks();
    }
  }
}
