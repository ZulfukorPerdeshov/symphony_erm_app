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
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  // Filters
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool? _isOverdueFilter;
  DateTime? _fromDate;
  DateTime? _toDate;

  // Sorting
  String _sortBy = 'CreatedAt';
  bool _sortDescending = true;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadTasks();
      }
    }
  }

  Future<void> _loadTasks({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 0;
        _tasks = [];
        _hasMoreData = true;
        _isLoading = true;
      });
    } else {
      if (_isLoadingMore || !_hasMoreData) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();

      final request = ProductionTaskListRequest(
        status: _statusFilter,
        priority: _priorityFilter,
        isOverdue: _isOverdueFilter,
        fromDate: _fromDate,
        toDate: _toDate,
        skip: _currentPage * _pageSize,
        take: _pageSize,
        orderBy: _sortBy,
        orderDescending: _sortDescending,
      );

      final tasks = await InventoryService.getProductionTasks(companyId, request);

      setState(() {
        if (reset) {
          _tasks = tasks;
        } else {
          _tasks.addAll(tasks);
        }
        _currentPage++;
        _hasMoreData = tasks.length == _pageSize;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterDialog(
        statusFilter: _statusFilter,
        priorityFilter: _priorityFilter,
        isOverdueFilter: _isOverdueFilter,
        fromDate: _fromDate,
        toDate: _toDate,
        onApply: (status, priority, isOverdue, fromDate, toDate) {
          setState(() {
            _statusFilter = status;
            _priorityFilter = priority;
            _isOverdueFilter = isOverdue;
            _fromDate = fromDate;
            _toDate = toDate;
          });
          _loadTasks(reset: true);
        },
        onClear: () {
          setState(() {
            _statusFilter = null;
            _priorityFilter = null;
            _isOverdueFilter = null;
            _fromDate = null;
            _toDate = null;
          });
          _loadTasks(reset: true);
        },
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SortDialog(
        sortBy: _sortBy,
        sortDescending: _sortDescending,
        onApply: (sortBy, descending) {
          setState(() {
            _sortBy = sortBy;
            _sortDescending = descending;
          });
          _loadTasks(reset: true);
        },
      ),
    );
  }

  int get _activeFilterCount {
    int count = 0;
    if (_statusFilter != null) count++;
    if (_priorityFilter != null) count++;
    if (_isOverdueFilter != null) count++;
    if (_fromDate != null) count++;
    if (_toDate != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.companyTasks),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTasks(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and Sort Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchTasks,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Badge(
                  isLabelVisible: _activeFilterCount > 0,
                  label: Text('$_activeFilterCount'),
                  child: IconButton.filled(
                    icon: const Icon(Icons.filter_alt_outlined),
                    onPressed: _showFilterDialog,
                    style: IconButton.styleFrom(
                      backgroundColor: _activeFilterCount > 0
                          ? const Color(AppColors.primaryIndigo)
                          : theme.colorScheme.surfaceContainerLowest,
                      foregroundColor: _activeFilterCount > 0 ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.sort),
                  color: theme.colorScheme.onSurface,
                  onPressed: _showSortDialog,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),

          // Task Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${_tasks.length} ${l10n.tasks}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (_hasMoreData) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.more_horiz, size: 16, color: Colors.grey[600]),
                ],
              ],
            ),
          ),

          // Task List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _loadTasks(reset: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _tasks.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _tasks.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final task = _tasks[index];
                            return _buildTaskCard(task);
                          },
                        ),
                      ),
          ),
        ],
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

              // Production Context Info
              if (task.product != null || task.productionBatch != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Info
                      if (task.product != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                task.product!.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Production Batch Info
                      if (task.productionBatch != null) ...[
                        if (task.product != null) const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.widgets_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      task.productionBatch!.batchNumber,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color.fromARGB(255, 185, 50, 16).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '${task.productionBatch!.plannedQuantity} ${AppLocalizations.of(context)!.units}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTaskBadge(
                    task.statusDisplay,
                    color,
                  ),
                  _buildTaskBadge(
                    task.priorityDisplay,
                    _getPriorityColor(task.priority),
                  ),
                  if (task.isOverdue)
                    _buildTaskBadge(
                      AppLocalizations.of(context)!.taskIsOverdue,
                      const Color(AppColors.error),
                    ),
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
      _loadTasks(reset: true);
    }
  }
}

// Filter Dialog Widget
class _FilterDialog extends StatefulWidget {
  final TaskStatus? statusFilter;
  final TaskPriority? priorityFilter;
  final bool? isOverdueFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final Function(TaskStatus?, TaskPriority?, bool?, DateTime?, DateTime?) onApply;
  final VoidCallback onClear;

  const _FilterDialog({
    required this.statusFilter,
    required this.priorityFilter,
    required this.isOverdueFilter,
    required this.fromDate,
    required this.toDate,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late TaskStatus? _status;
  late TaskPriority? _priority;
  late bool? _isOverdue;
  late DateTime? _fromDate;
  late DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _status = widget.statusFilter;
    _priority = widget.priorityFilter;
    _isOverdue = widget.isOverdueFilter;
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.filters,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  widget.onClear();
                  Navigator.pop(context);
                },
                child: Text(l10n.clearAll),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Filter
          Text(l10n.status, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(l10n.all, _status == null, () => setState(() => _status = null)),
              _buildFilterChip(l10n.notStarted, _status == TaskStatus.notStarted, () => setState(() => _status = TaskStatus.notStarted)),
              _buildFilterChip(l10n.inProgress, _status == TaskStatus.inProgress, () => setState(() => _status = TaskStatus.inProgress)),
              _buildFilterChip(l10n.onHold, _status == TaskStatus.onHold, () => setState(() => _status = TaskStatus.onHold)),
              _buildFilterChip(l10n.completed, _status == TaskStatus.completed, () => setState(() => _status = TaskStatus.completed)),
            ],
          ),
          const SizedBox(height: 24),

          // Priority Filter
          Text(l10n.priority, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(l10n.all, _priority == null, () => setState(() => _priority = null)),
              _buildFilterChip(l10n.low, _priority == TaskPriority.low, () => setState(() => _priority = TaskPriority.low)),
              _buildFilterChip(l10n.medium, _priority == TaskPriority.medium, () => setState(() => _priority = TaskPriority.medium)),
              _buildFilterChip(l10n.high, _priority == TaskPriority.high, () => setState(() => _priority = TaskPriority.high)),
              _buildFilterChip(l10n.urgent, _priority == TaskPriority.urgent, () => setState(() => _priority = TaskPriority.urgent)),
            ],
          ),
          const SizedBox(height: 24),

          // Overdue Filter
          CheckboxListTile(
            title: Text(l10n.showOverdueOnly),
            value: _isOverdue ?? false,
            onChanged: (value) => setState(() => _isOverdue = value == true ? true : null),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_status, _priority, _isOverdue, _fromDate, _toDate);
                Navigator.pop(context);
              },
              child: Text(l10n.applyFilters),
            ),
          ),
        ],
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
}

// Sort Dialog Widget
class _SortDialog extends StatefulWidget {
  final String sortBy;
  final bool sortDescending;
  final Function(String, bool) onApply;

  const _SortDialog({
    required this.sortBy,
    required this.sortDescending,
    required this.onApply,
  });

  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  late String _sortBy;
  late bool _sortDescending;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.sortBy;
    _sortDescending = widget.sortDescending;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sortBy,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            RadioListTile<String>(
              title: Text(l10n.createdDate),
              value: 'CreatedAt',
              groupValue: _sortBy,
              onChanged: (value) => setState(() => _sortBy = value!),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: Text(l10n.dueDate),
              value: 'PlannedEndDate',
              groupValue: _sortBy,
              onChanged: (value) => setState(() => _sortBy = value!),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: Text(l10n.priority),
              value: 'Priority',
              groupValue: _sortBy,
              onChanged: (value) => setState(() => _sortBy = value!),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: Text(l10n.progress),
              value: 'ProgressPercentage',
              groupValue: _sortBy,
              onChanged: (value) => setState(() => _sortBy = value!),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: Text(l10n.descending),
              value: _sortDescending,
              onChanged: (value) => setState(() => _sortDescending = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_sortBy, _sortDescending);
                  Navigator.pop(context);
                },
                child: Text(l10n.apply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
