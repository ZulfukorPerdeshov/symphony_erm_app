import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import '../../l10n/app_localizations.dart';
import '../../models/production.dart';
import '../../models/company.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class TaskDetailScreen extends StatefulWidget {
  final MyProductionTaskDto task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MyProductionTaskDto? _task;
  bool _isLoading = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isInternal = false;
  Map<String, String> _userFullNames = {}; // Cache user full names by userId

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _tabController = TabController(length: 3, vsync: this);
    _loadTaskDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final taskDetails = await InventoryService.getProductionTask(companyId, _task!.id);

      // Extract unique user IDs from comments
      final userIds = taskDetails.comments
          .map((comment) => comment.userId)
          .where((userId) => userId.isNotEmpty && !_userFullNames.containsKey(userId))
          .toSet()
          .toList();

      // Fetch user details if there are any new user IDs
      if (userIds.isNotEmpty) {
        try {
          final users = await AuthService.getUsersByIds(userIds);
          for (final user in users) {
            _userFullNames[user.id] = user.fullName;
          }
        } catch (e) {
          // If user fetching fails, continue with task display
          // Users will see userId instead of full name
        }
      }

      setState(() {
        _task = taskDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingTaskDetails}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_task == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_task!.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _loadTaskDetails,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.grey,
          tabs: [
            Tab(text: l10n.details),
            Tab(text: l10n.comments),
            Tab(text: l10n.attachments),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildCommentsTab(),
                _buildAttachmentsTab(),
              ],
            ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskHeader(),
          const SizedBox(height: 16),
          _buildTaskInfo(),
          const SizedBox(height: 16),
          _buildProgressCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildAssignmentInfo(),
          const SizedBox(height: 16),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _task!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                ),
                _buildStatusChip(_task!.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _task!.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textSecondary),
              ),
            ),
            if (_task!.isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 16,
                      color: Color(AppColors.error),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.taskIsOverdue,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.error),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfo() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.taskInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.priority, _task!.priorityDisplay, _getPriorityColor(_task!.priority)),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.status, _task!.statusDisplay, _getStatusColor(_task!.status)),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.duration, _task!.duration ?? l10n.notAvailable, null),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.estimatedHours, '${_task!.estimatedHours}h', null),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.actualHours, '${_task!.actualHours ?? 0}h', null),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.progress,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: AnimatedRadialGauge(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                radius: 120,
                value: _task!.progressPercentage.toDouble(),
                axis: GaugeAxis(
                  min: 0,
                  max: 100,
                  degrees: 270,
                  style: GaugeAxisStyle(
                    thickness: 20,
                    background: Colors.grey[300],
                    segmentSpacing: 4,
                  ),
                  progressBar: GaugeProgressBar.rounded(
                    color: _getProgressColor(_task!.progressPercentage),
                  ),
                  segments: [
                    GaugeSegment(
                      from: 0,
                      to: 33.33,
                      color: const Color(AppColors.error).withValues(alpha: 0.3),
                      cornerRadius: Radius.zero,
                    ),
                    GaugeSegment(
                      from: 33.33,
                      to: 66.66,
                      color: const Color(AppColors.warning).withValues(alpha: 0.3),
                      cornerRadius: Radius.zero,
                    ),
                    GaugeSegment(
                      from: 66.66,
                      to: 100,
                      color: const Color(AppColors.success).withValues(alpha: 0.3),
                      cornerRadius: Radius.zero,
                    ),
                  ],
                ),
                builder: (context, child, value) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(value.toInt()),
                        ),
                      ),
                      Text(
                        l10n.complete,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentInfo() {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = AuthService.currentUser?.id;
    final isAssignedToCurrentUser = _task!.assignedToUserId == currentUserId;
    final isAssigned = _task!.assignedToUserId != null;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.assignment,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            if (_task!.assignedToUserName != null)
              _buildInfoRow(l10n.assignedUser, _task!.assignedToUserName!, null),
            if (_task!.assignedToRoleName != null)
              _buildInfoRow(l10n.assignedRole, _task!.assignedToRoleName!, null),
            if (_task!.assignedToUserName == null && _task!.assignedToRoleName == null)
              Text(
                l10n.notAssigned,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(AppColors.textHint),
                ),
              ),
            const SizedBox(height: 16),
            // Assignment Actions
            Row(
              children: [
                if (!isAssigned) // Task not assigned
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _assignToSelf,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: Text(l10n.assignToMe),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryIndigo),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (isAssignedToCurrentUser) // Assigned to current user
                  ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _unassignTask,
                        icon: const Icon(Icons.person_remove, size: 18),
                        label: Text(l10n.returnTask),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(AppColors.warning),
                          side: const BorderSide(color: Color(AppColors.warning)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showReassignDialog,
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: Text(l10n.reassign),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.info),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                if (isAssigned && !isAssignedToCurrentUser) // Assigned to someone else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showReassignDialog,
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: Text(l10n.reassign),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.info),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.timeline,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            if (_task!.plannedStartDate != null)
              _buildDateRow(l10n.plannedStart, _task!.plannedStartDate!),
            if (_task!.plannedEndDate != null)
              _buildDateRow(l10n.plannedEnd, _task!.plannedEndDate!),
            if (_task!.actualStartDate != null)
              _buildDateRow(l10n.actualStart, _task!.actualStartDate!),
            if (_task!.actualEndDate != null)
              _buildDateRow(l10n.actualEnd, _task!.actualEndDate!),
            const SizedBox(height: 8),
            _buildDateRow(l10n.created, _task!.createdAt),
            _buildDateRow(l10n.updated, _task!.updatedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.taskActions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_task!.status == 0) // Not Started
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _startTask,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(l10n.startTask),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.success),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (_task!.status == 1) // In Progress
                  ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showUpdateProgressDialog,
                        icon: const Icon(Icons.update, size: 18),
                        label: Text(l10n.updateProgress),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.info),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _completeTask,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(l10n.complete),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.success),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
              ],
            ),
            if (_task!.status == 0 || _task!.status == 1) // Not Started or In Progress
              ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _cancelTask,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: Text(l10n.cancelTask),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(AppColors.error),
                      side: const BorderSide(color: Color(AppColors.error)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            if (_task!.status == 3) // Completed
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(AppColors.success).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Color(AppColors.success), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.taskCompleted,
                      style: const TextStyle(
                        color: Color(AppColors.success),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (_task!.status == 4) // Cancelled
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel, color: Color(AppColors.error), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.taskCancelled,
                      style: const TextStyle(
                        color: Color(AppColors.error),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTask() async {
    try {
      setState(() => _isLoading = true);

      final request = StartTaskRequest(
        startDate: DateTime.now(),
        notes: null,
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final updatedTask = await InventoryService.startProductionTask(companyId, _task!.id, request);

      setState(() {
        _task = updatedTask;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskStartedSuccessfully)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorStartingTask}: $e')),
        );
      }
    }
  }

  Future<void> _completeTask() async {
    final l10n = AppLocalizations.of(context)!;
    final actualHoursController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.completeTask),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.areYouSureCompleteTask),
              const SizedBox(height: 16),
              TextField(
                controller: actualHoursController,
                decoration: InputDecoration(
                  labelText: l10n.actualHoursOptional,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: l10n.completionNotesOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.success),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.complete),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      setState(() => _isLoading = true);

      final actualHours = actualHoursController.text.isNotEmpty
          ? int.tryParse(actualHoursController.text)
          : null;
      final notes = notesController.text.isNotEmpty ? notesController.text : null;

      final request = CompleteTaskRequest(
        completionDate: DateTime.now(),
        actualHours: actualHours,
        notes: notes,
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final updatedTask = await InventoryService.completeProductionTask(companyId, _task!.id, request);

      setState(() {
        _task = updatedTask;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskCompletedSuccessfully)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorCompletingTask}: $e')),
        );
      }
    }
  }

  Future<void> _cancelTask() async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelTaskConfirm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.areYouSureCancelTask),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.cancellationReason,
                border: const OutlineInputBorder(),
                hintText: l10n.pleaseProvideCancellationReason,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pleaseProvideCancellationReason)),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.error),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.cancelTask),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);

      final request = CancelTaskRequest(
        reason: reasonController.text.trim(),
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final updatedTask = await InventoryService.cancelProductionTask(companyId, _task!.id, request);

      setState(() {
        _task = updatedTask;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskCancelledSuccessfully)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorCancellingTask}: $e')),
        );
      }
    }
  }

  Future<void> _assignToSelf() async {
    try {
      setState(() => _isLoading = true);

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final updatedTask = await InventoryService.assignTaskToSelf(companyId, _task!.id);

      setState(() {
        _task = updatedTask;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskAssignedToYou)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorAssigningTask}: $e')),
        );
      }
    }
  }

  Future<void> _unassignTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.returnTask),
        content: Text(AppLocalizations.of(context)!.areYouSureReturnTask),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.returnTask),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final updatedTask = await InventoryService.unassignTask(companyId, _task!.id);

      setState(() {
        _task = updatedTask;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskReturned)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorReturningTask}: $e')),
        );
      }
    }
  }

  Future<void> _showReassignDialog() async {
    final l10n = AppLocalizations.of(context)!;

    // Show loading dialog while fetching users
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    List<CompanyUserDto> companyUsers = [];
    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      companyUsers = await CompanyService.getCompanyUsers(companyId);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingData}: $e')),
        );
      }
      return;
    }

    if (companyUsers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noUsersFound)),
        );
      }
      return;
    }

    // Show dropdown dialog
    CompanyUserDto? selectedUser;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.reassignTask),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.selectUserToReassign),
              const SizedBox(height: 16),
              DropdownButtonFormField<CompanyUserDto>(
                decoration: InputDecoration(
                  labelText: l10n.selectUser,
                  border: const OutlineInputBorder(),
                ),
                isExpanded: true,
                value: selectedUser,
                items: companyUsers.map((user) {
                  return DropdownMenuItem<CompanyUserDto>(
                    value: user,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(AppColors.primaryIndigo).withValues(alpha: 0.1),
                          child: Text(
                            user.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(AppColors.primaryIndigo),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            user.email != null ? '${user.fullName} (${user.email})' : user.fullName,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedUser = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pleaseSelectUser)),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.reassign),
            ),
          ],
        ),
      ),
    );

    if (result != true || selectedUser == null) return;

    try {
      setState(() => _isLoading = true);

      final request = ReassignTaskRequest(
        userId: selectedUser!.userId,
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final updatedTask = await InventoryService.reassignTask(companyId, _task!.id, request);

      setState(() {
        _task = updatedTask;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskReassigned)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorReassigningTask}: $e')),
        );
      }
    }
  }

  Future<void> _showUpdateProgressDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final progressController = TextEditingController(text: _task!.progressPercentage.toString());
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.updateProgress),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: progressController,
                decoration: InputDecoration(
                  labelText: l10n.progressPercentage,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: l10n.progressNotesOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final progress = int.tryParse(progressController.text);
              if (progress == null || progress < 0 || progress > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pleaseEnterValidProgress)),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.info),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.update),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      setState(() => _isLoading = true);

      final progress = int.parse(progressController.text);
      final notes = notesController.text.isNotEmpty ? notesController.text : null;

      final request = UpdateTaskProgressRequest(
        progressPercentage: progress,
        notes: notes,
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final updatedTask = await InventoryService.updateProductionTaskProgress(companyId, _task!.id, request);

      setState(() {
        _task = updatedTask;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.progressUpdatedSuccessfully)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorUpdatingProgress}: $e')),
        );
      }
    }
  }

  Widget _buildCommentsTab() {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = AuthService.currentUser?.id;

    return Column(
      children: [
        Expanded(
          child: _task!.comments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noCommentsYet,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.startConversation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: _task!.comments.length,
                  itemBuilder: (context, index) {
                    final comment = _task!.comments[_task!.comments.length - 1 - index];
                    final isCurrentUser = comment.userId == currentUserId;
                    return _buildChatBubble(comment, isCurrentUser);
                  },
                ),
        ),
        // Chat Input
        _buildChatInput(),
      ],
    );
  }

  Widget _buildAttachmentsTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: _task!.attachments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.attach_file_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noAttachments,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _task!.attachments.length,
                  itemBuilder: (context, index) {
                    final attachment = _task!.attachments[index];
                    return _buildAttachmentCard(attachment);
                  },
                ),
        ),
        // Add Attachment Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _showAddAttachmentDialog,
              icon: const Icon(Icons.attach_file),
              label: Text(l10n.addAttachment),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryIndigo),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(ProductionTaskCommentDto comment, bool isCurrentUser) {
    // Get user full name from cache, fallback to comment.userName, then unknown
    final userName = _userFullNames[comment.userId] ??
                     comment.userName ??
                     AppLocalizations.of(context)!.unknown;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // User name and internal badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (comment.isInternal) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.info).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.internal,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(AppColors.info),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? const Color(AppColors.primaryIndigo)
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                ),
              ),
              child: Text(
                comment.comment,
                style: TextStyle(
                  fontSize: 14,
                  color: isCurrentUser ? Colors.white : const Color(AppColors.textPrimary),
                  height: 1.4,
                ),
              ),
            ),
            // Timestamp
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                _formatDate(comment.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Internal toggle
            if (_isInternal)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(AppColors.info).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 16, color: Color(AppColors.info)),
                    const SizedBox(width: 8),
                    Text(
                      l10n.internalComment,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.info),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isInternal = false;
                        });
                      },
                      child: const Icon(Icons.close, size: 16, color: Color(AppColors.info)),
                    ),
                  ],
                ),
              ),
            // Input row
            Row(
              children: [
                // Internal button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isInternal = !_isInternal;
                    });
                  },
                  icon: Icon(
                    _isInternal ? Icons.lock : Icons.lock_open,
                    color: _isInternal
                        ? const Color(AppColors.info)
                        : Colors.grey[600],
                  ),
                  tooltip: l10n.internalComment,
                ),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: l10n.typeMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(AppColors.primaryIndigo)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                Container(
                  decoration: const BoxDecoration(
                    color: Color(AppColors.primaryIndigo),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendComment,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    tooltip: l10n.sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      final request = CreateProductionTaskCommentRequest(
        comment: commentText,
        isInternal: _isInternal,
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.addProductionTaskComment(companyId, _task!.id, request);

      // Clear input
      _commentController.clear();
      setState(() {
        _isInternal = false;
      });

      // Reload task details to get updated comments
      await _loadTaskDetails();

      // Unfocus keyboard
      _commentFocusNode.unfocus();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorAddingComment}: $e')),
        );
      }
    }
  }

  Widget _buildAttachmentCard(ProductionTaskAttachmentDto attachment) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryIndigo).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.insert_drive_file,
                color: Color(AppColors.primaryIndigo),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${attachment.formattedFileSize} • ${attachment.contentType}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                  if (attachment.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      attachment.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.textHint),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${AppLocalizations.of(context)!.uploadedBy} ${attachment.uploadedByName ?? AppLocalizations.of(context)!.unknown} • ${_formatDate(attachment.uploadedAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(AppColors.textHint),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _downloadAttachment(attachment),
              icon: const Icon(Icons.download),
              tooltip: AppLocalizations.of(context)!.downloadingFile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    Color backgroundColor;
    String text;

    switch (status) {
      case 0:
        backgroundColor = const Color(AppColors.textHint);
        text = 'NOT STARTED';
        break;
      case 1:
        backgroundColor = const Color(AppColors.info);
        text = 'IN PROGRESS';
        break;
      case 2:
        backgroundColor = const Color(AppColors.warning);
        text = 'ON HOLD';
        break;
      case 3:
        backgroundColor = const Color(AppColors.success);
        text = 'COMPLETED';
        break;
      case 4:
        backgroundColor = const Color(AppColors.error);
        text = 'CANCELLED';
        break;
      default:
        backgroundColor = Colors.grey;
        text = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(AppColors.textSecondary),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? const Color(AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _buildInfoRow(label, _formatDate(date), null),
    );
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

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color(AppColors.textHint);
      case 1:
        return const Color(AppColors.info);
      case 2:
        return const Color(AppColors.warning);
      case 3:
        return const Color(AppColors.success);
      case 4:
        return const Color(AppColors.error);
      default:
        return Colors.grey;
    }
  }

  Color _getProgressColor(int percentage) {
    if (percentage < 25) {
      return const Color(AppColors.error);
    } else if (percentage < 50) {
      return const Color(AppColors.warning);
    } else if (percentage < 75) {
      return const Color(AppColors.info);
    } else {
      return const Color(AppColors.success);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showAddAttachmentDialog() async {
    final l10n = AppLocalizations.of(context)!;

    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    if (file.path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorUploadingFile)),
        );
      }
      return;
    }

    // Show description dialog
    final descriptionController = TextEditingController();
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addAttachment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(file.size / 1024).toStringAsFixed(2)} KB',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: l10n.fileDescription,
                hintText: l10n.enterFileDescription,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.upload),
          ),
        ],
      ),
    );

    if (shouldUpload != true) return;

    // Upload file
    try {
      setState(() => _isLoading = true);

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.uploadProductionTaskAttachment(
        companyId: companyId,
        taskId: _task!.id,
        filePath: file.path!,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );

      // Reload task details
      await _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fileUploadedSuccessfully)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorUploadingFile}: $e')),
        );
      }
    }

  }

  Future<void> _downloadAttachment(ProductionTaskAttachmentDto attachment) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Show downloading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.downloadingFile),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();

      // Download file as bytes
      final fileBytes = await InventoryService.downloadProductionTaskAttachment(
        companyId,
        attachment.id,
      );

      // Get Documents directory (works on all platforms)
      final directory = await getApplicationDocumentsDirectory();

      // Create file path in Documents folder
      final filePath = '${directory.path}/${attachment.fileName}';
      final file = File(filePath);

      // Write bytes to file
      await file.writeAsBytes(fileBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.fileDownloadedSuccessfully}\n$filePath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: l10n.open,
              onPressed: () => _openFile(filePath),
            ),
          ),
        );

        // Automatically try to open the file
        await _openFile(filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorDownloadingFile}: $e')),
        );
      }
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);

      // Check if file opening failed
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.errorOpeningFile}: ${result.message}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorOpeningFile}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}