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

class _TaskDetailScreenState extends State<TaskDetailScreen> {
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
    _loadTaskDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final taskDetails = await InventoryService.getProductionTask(companyId, _task!.id);

      if (!mounted) return;

      // Load user full names for comments
      final userIds = taskDetails.comments
          .map((comment) => comment.userId)
          .where((userId) => userId.isNotEmpty && !_userFullNames.containsKey(userId))
          .toSet()
          .toList();

      if (userIds.isNotEmpty) {
        final users = await AuthService.getUsersByIds(userIds);
        if (!mounted) return;

        for (final user in users) {
          _userFullNames[user.id] = user.fullName;
        }
      }

      if (!mounted) return;

      setState(() {
        _task = taskDetails;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          _task!.name.length > 30 ? '${_task!.name.substring(0, 30)}...' : _task!.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Badge
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4AA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'Z',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _task!.productionStageName ?? 'Project',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // // Task Title
                  // Container(
                  //   color: Colors.transparent,
                  //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  //   child: Text(
                  //     _task!.name,
                  //     style: const TextStyle(
                  //       fontSize: 24,
                  //       fontWeight: FontWeight.bold,
                  //       height: 1.2,
                  //     ),
                  //     textAlign: TextAlign.justify,
                  //   ),
                  // ),

                  // Progress Gauge
                  Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: AnimatedRadialGauge(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        radius: 100,
                        value: _task!.progressPercentage.toDouble(),
                        axis: GaugeAxis(
                          min: 0,
                          max: 100,
                          degrees: 270,
                          style: GaugeAxisStyle(
                            thickness: 16,
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
                  ),

                  const SizedBox(height: 8),

                  // Metadata Cards
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildMetadataRow(
                          label: l10n.state,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_task!.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(_task!.status),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _task!.statusDisplay,
                                  style: TextStyle(
                                    color: _getStatusColor(_task!.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildMetadataRow(
                          label: l10n.dueDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getDueDateColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getDueDateColor(),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 10,
                                  color: _getDueDateColor(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _task!.plannedEndDate != null
                                      ? _formatDate(_task!.plannedEndDate!)
                                      : l10n.notSet,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: _getDueDateColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildMetadataRow(
                          label: l10n.assignee,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(AppColors.primaryIndigo).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(AppColors.primaryIndigo),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: const Color(AppColors.primaryIndigo),
                                  child: Text(
                                    _getInitials(_task!.assignedToUserName),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _task!.assignedToUserName ?? l10n.unassigned,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: Color(AppColors.primaryIndigo),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_task!.createdBy != null) ...[
                          const Divider(height: 24),
                          _buildMetadataRow(
                            label: l10n.createdBy,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _userFullNames[_task!.createdBy!] ?? l10n.unknown,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  
                  // Task Operation Buttons
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Start/Complete
                        _buildCircleActionButton(
                          icon: _task!.status == 3
                              ? Icons.check_circle
                              : (_task!.status == 0 ? Icons.play_arrow : Icons.check_circle_outline),
                          color: _task!.status == 3 ? const Color(AppColors.success) : const Color(AppColors.primaryIndigo),
                          onTap: _task!.status == 3 ? null : () {
                            if (_task!.status == 0) {
                              _updateTaskStatus(1); // Start progress
                            } else {
                              _completeTask();
                            }
                          },
                        ),
                        // Reassign
                        _buildCircleActionButton(
                          icon: Icons.person_add_alt,
                          color: const Color(0xFF4A9DEC),
                          onTap: _showReassignDialog,
                        ),
                        // Return Task
                        _buildCircleActionButton(
                          icon: Icons.arrow_back,
                          color: const Color(AppColors.warning),
                          onTap: () => _updateTaskStatus(2), // On Hold
                        ),
                        // Assign to Me
                        _buildCircleActionButton(
                          icon: Icons.person,
                          color: const Color(0xFF66BB6A),
                          onTap: _assignTaskToMe,
                        ),
                        // Change Due Date
                        _buildCircleActionButton(
                          icon: Icons.calendar_today,
                          color: const Color(0xFFFF6B9D),
                          onTap: _showChangeDueDateDialog,
                        ),
                        // Change Progress
                        _buildCircleActionButton(
                          icon: Icons.timeline,
                          color: const Color(0xFF9C27B0),
                          onTap: _showChangeProgressDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),


                  // Description Section
                  if (_task!.description.isNotEmpty) ...[
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _task!.description,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Attachments Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.attachments,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(AppColors.primaryIndigo).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_task!.attachments.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(AppColors.primaryIndigo),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _task!.attachments.length + 1, // +1 for add button
                            itemBuilder: (context, index) {
                              if (index == _task!.attachments.length) {
                                // Add attachment button
                                return _buildAddAttachmentCard();
                              }
                              final attachment = _task!.attachments[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildAttachmentCard(attachment),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comments Section (Chat Style)
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Chat Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.comments,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(AppColors.primaryIndigo).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_task!.comments.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(AppColors.primaryIndigo),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Messages List
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 200,
                            maxHeight: 400,
                          ),
                          child: _task!.comments.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.chat_outlined, size: 48, color: Colors.grey[300]),
                                        const SizedBox(height: 12),
                                        Text(
                                          l10n.noCommentsYet,
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _task!.comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = _task!.comments.reversed.toList()[index];
                                    final isCurrentUser = comment.userId == AuthService.currentUser?.id;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _buildChatBubble(comment, isCurrentUser),
                                    );
                                  },
                                ),
                        ),

                        // Chat Input
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(
                              top: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: TextField(
                                    controller: _commentController,
                                    maxLines: null,
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                      hintText: l10n.writeComment,
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(AppColors.primaryIndigo),
                                      Color(0xFF6366F1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _addComment,
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16), // Space at bottom
                ],
              ),
            ),
      //bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDisabled ? Colors.grey[200] : color.withValues(alpha: 0.15),
            border: Border.all(
              color: isDisabled ? Colors.grey[400]! : color,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isDisabled ? Colors.grey[600] : color,
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildAttachmentCard(ProductionTaskAttachmentDto attachment) {
    final isImage = attachment.fileName.toLowerCase().endsWith('.png') ||
        attachment.fileName.toLowerCase().endsWith('.jpg') ||
        attachment.fileName.toLowerCase().endsWith('.jpeg');

    return GestureDetector(
      onTap: () => _downloadAttachment(attachment),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isImage ? Colors.white : Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    isImage ? Icons.image : Icons.insert_drive_file,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName.length > 15
                        ? '${attachment.fileName.substring(0, 15)}...'
                        : attachment.fileName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attachment.fileSize > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatFileSize(attachment.fileSize),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAttachmentCard() {
    return GestureDetector(
      onTap: _showAttachmentDialog,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(AppColors.primaryIndigo),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(AppColors.primaryIndigo),
                    Color(0xFF6366F1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.uploadFile,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.primaryIndigo),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ProductionTaskCommentDto comment, bool isCurrentUser) {
    final userName = _userFullNames[comment.userId] ?? comment.userName ?? 'Unknown';

    return Row(
      mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCurrentUser) ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[400],
            child: Text(
              _getInitials(userName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    Text(
                      comment.comment,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isCurrentUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _formatCommentTime(comment.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isCurrentUser) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(AppColors.primaryIndigo),
            child: Text(
              _getInitials(userName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentItem(ProductionTaskCommentDto comment, bool isCurrentUser) {
    final userName = _userFullNames[comment.userId] ?? comment.userName ?? 'Unknown';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isCurrentUser ? const Color(AppColors.primaryIndigo) : Colors.grey[400],
          child: Text(
            _getInitials(userName),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCommentTime(comment.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.comment,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomBarIcon(Icons.home_outlined, () {}),
              _buildBottomBarIcon(Icons.calendar_today_outlined, () {}),
              FloatingActionButton(
                onPressed: () => _showAddCommentDialog(context),
                backgroundColor: const Color(0xFFFF6B9D),
                elevation: 2,
                child: const Icon(Icons.add, color: Colors.white),
              ),
              _buildBottomBarIcon(Icons.layers_outlined, () => _showAttachmentDialog()),
              _buildBottomBarIcon(Icons.person_outline, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.grey[600], size: 28),
      onPressed: onTap,
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: // Not Started
        return Colors.grey;
      case 1: // In Progress
        return const Color(0xFF4A9DEC);
      case 2: // On Hold
        return const Color(0xFFFFA726);
      case 3: // Completed
        return const Color(0xFF66BB6A);
      case 4: // Cancelled
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  Color _getDueDateColor() {
    if (_task?.plannedEndDate == null) {
      return Colors.grey;
    }

    final now = DateTime.now();
    final dueDate = _task!.plannedEndDate!;
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      // Overdue
      return const Color(0xFFEF5350); // Red
    } else if (difference == 0) {
      // Due today
      return const Color(0xFFFFA726); // Orange
    } else if (difference <= 3) {
      // Due in 1-3 days
      return const Color(0xFFFFA726); // Orange
    } else if (difference <= 7) {
      // Due in 4-7 days
      return const Color(0xFF4A9DEC); // Blue
    } else {
      // Due in more than 7 days
      return const Color(0xFF66BB6A); // Green
    }
  }

  Color _getProgressColor(int progress) {
    if (progress < 33) {
      return const Color(AppColors.error); // Red
    } else if (progress < 67) {
      return const Color(AppColors.warning); // Orange/Yellow
    } else {
      return const Color(AppColors.success); // Green
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatCommentTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return _formatDate(dateTime);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showMoreOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editTask),
              onTap: () {
                Navigator.pop(context);
                _showUpdateProgressDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(l10n.reassignTask),
              onTap: () {
                Navigator.pop(context);
                _showReassignDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: Text(l10n.markAsComplete),
              onTap: () {
                Navigator.pop(context);
                _completeTask();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: Text(l10n.cancelTask, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showCancelDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCommentDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addComment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.enterYourComment,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: Text(l10n.internalComment),
              value: _isInternal,
              onChanged: (value) => setState(() => _isInternal = value ?? false),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => _addComment(),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.addProductionTaskComment(
        companyId,
        _task!.id,
        CreateProductionTaskCommentRequest(
          comment: _commentController.text.trim(),
          isInternal: _isInternal,
        ),
      );

      _commentController.clear();
      setState(() => _isInternal = false);

      if (mounted) {
        Navigator.pop(context);
        await _loadTaskDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commentAdded)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  Future<void> _showAttachmentDialog() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null) return;

    final file = result.files.first;
    if (file.path == null) return;

    final descriptionController = TextEditingController();

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.uploadFile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${l10n.fileSelected}: ${file.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: l10n.fileDescription,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.upload),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final companyId = CompanyService.getCurrentCompanyIdOrThrow();
        await InventoryService.uploadProductionTaskAttachment(
          companyId: companyId,
          taskId: _task!.id,
          filePath: file.path!,
          description: descriptionController.text.trim(),
        );

        await _loadTaskDetails();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.fileUploadedSuccessfully)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.errorUploadingFile}: $e')),
          );
        }
      }
    }
  }

  Future<void> _downloadAttachment(ProductionTaskAttachmentDto attachment) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.downloadingFile)),
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final fileBytes = await InventoryService.downloadProductionTaskAttachment(companyId, attachment.id);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      final filePath = '${directory!.path}/${attachment.fileName}';
      await File(filePath).writeAsBytes(fileBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.fileDownloadedSuccessfully),
            action: SnackBarAction(
              label: l10n.open,
              onPressed: () => OpenFilex.open(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorDownloadingFile}: $e')),
        );
      }
    }
  }

  Future<void> _showUpdateProgressDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final progressController = TextEditingController(text: _task!.progressPercentage.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.updateProgress),
        content: TextField(
          controller: progressController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.progressPercentage,
            suffixText: '%',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final progress = int.tryParse(progressController.text) ?? 0;
              if (progress >= 0 && progress <= 100) {
                Navigator.pop(context);
                await _updateProgress(progress);
              }
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProgress(int progress) async {
    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.updateProductionTaskProgress(
        companyId,
        _task!.id,
        UpdateTaskProgressRequest(
          taskId: _task!.id,
          progressPercentage: progress,
        ),
      );

      await _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.progressUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  Future<void> _showReassignDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final companyId = CompanyService.getCurrentCompanyIdOrThrow();

    try {
      final companyUsers = await CompanyService.getCompanyUsers(companyId);

      if (!mounted) return;

      CompanyUserDto? selectedUser;

      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.reassignTask),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<CompanyUserDto>(
                  value: selectedUser,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.selectUser,
                    border: const OutlineInputBorder(),
                  ),
                  items: companyUsers.map((user) {
                    return DropdownMenuItem<CompanyUserDto>(
                      value: user,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            child: Text(
                              user.firstName.isNotEmpty ? user.firstName[0] : '?',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              user.email != null && user.email!.isNotEmpty
                                  ? '${user.fullName} (${user.email})'
                                  : user.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedUser = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: selectedUser != null
                    ? () {
                        Navigator.pop(context);
                        _reassignTask(selectedUser!.userId);
                      }
                    : null,
                child: Text(l10n.reassign),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingData}: $e')),
        );
      }
    }
  }

  Future<void> _reassignTask(String userId) async {
    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.reassignTask(
        companyId,
        _task!.id,
        ReassignTaskRequest(userId: userId),
      );

      await _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskReassigned)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  Future<void> _completeTask() async {
    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.completeProductionTask(
        companyId,
        _task!.id,
        CompleteTaskRequest(
          completionDate: DateTime.now(),
          notes: 'Completed',
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskCompleted)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorCompletingTask}: $e')),
        );
      }
    }
  }

  Future<void> _showCancelDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelTask),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.reason,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelTask(reasonController.text.trim());
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTask(String reason) async {
    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.cancelProductionTask(
        companyId,
        _task!.id,
        CancelTaskRequest(reason: reason),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskCancelled)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  Future<void> _updateTaskStatus(int newStatus) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final request = UpdateTaskStatusRequest(
        taskId: widget.task.id,
        status: newStatus,
      );

      await InventoryService.updateTaskStatus(
        CompanyService.getCurrentCompanyIdOrThrow(),
        request,
      );

      await _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.statusUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingData}: $e')),
        );
      }
    }
  }

  Future<void> _assignTaskToMe() async {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = AuthService.currentUser;

    if (currentUser == null) return;

    try {
      final request = ReassignTaskRequest(
        userId: currentUser.id,
      );

      await InventoryService.reassignTask(
        CompanyService.getCurrentCompanyIdOrThrow(),
        widget.task.id,
        request,
      );

      await _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.taskReassigned)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorReassigningTask}: $e')),
        );
      }
    }
  }

  Future<void> _showChangeDueDateDialog() async {
    final l10n = AppLocalizations.of(context)!;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _task?.plannedEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null || !mounted) return;

    try {
      final request = UpdateTaskDueDateRequest(
        taskId: widget.task.id,
        plannedEndDate: selectedDate,
      );

      await InventoryService.updateTaskDueDate(
        CompanyService.getCurrentCompanyIdOrThrow(),
        request,
      );

      await _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dueDateUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingData}: $e')),
        );
      }
    }
  }

  Future<void> _showChangeProgressDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _task!.progressPercentage.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeProgress),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.progressPercentage,
                hintText: '0-100',
                border: const OutlineInputBorder(),
                suffixText: '%',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0 && value <= 100) {
                Navigator.pop(context, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.invalidProgressValue)),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || !mounted) return;

    try {
      final request = UpdateTaskProgressRequest(
        taskId: widget.task.id,
        progressPercentage: result,
      );

      await InventoryService.updateTaskProgress(
        CompanyService.getCurrentCompanyIdOrThrow(),
        request,
      );

      await _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.progressUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingData}: $e')),
        );
      }
    }
  }
}
