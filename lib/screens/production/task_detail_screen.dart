import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/production.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
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
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final taskDetails = await InventoryService.getProductionTask(companyId, _task!.id);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.progress,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textPrimary),
                  ),
                ),
                Text(
                  '${_task!.progressPercentage}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.primaryIndigo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _task!.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(_task!.progressPercentage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentInfo() {
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

    if (_task!.comments.isEmpty) {
      return Center(
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
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _task!.comments.length,
      itemBuilder: (context, index) {
        final comment = _task!.comments[index];
        return _buildCommentCard(comment);
      },
    );
  }

  Widget _buildAttachmentsTab() {
    final l10n = AppLocalizations.of(context)!;

    if (_task!.attachments.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _task!.attachments.length,
      itemBuilder: (context, index) {
        final attachment = _task!.attachments[index];
        return _buildAttachmentCard(attachment);
      },
    );
  }

  Widget _buildCommentCard(ProductionTaskCommentDto comment) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comment.userName ?? AppLocalizations.of(context)!.unknown,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                ),
                if (comment.isInternal)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.info).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.internal,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(AppColors.info),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(comment.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Color(AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
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
              onPressed: () {
                // TODO: Implement file download/view
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.fileDownloadNotImplemented)),
                );
              },
              icon: const Icon(Icons.download),
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
}