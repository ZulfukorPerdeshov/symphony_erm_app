import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';

class StockTransferListScreen extends StatefulWidget {
  const StockTransferListScreen({super.key});

  @override
  State<StockTransferListScreen> createState() => _StockTransferListScreenState();
}

class _StockTransferListScreenState extends State<StockTransferListScreen> {
  final _scrollController = ScrollController();

  List<StockTransferDto> _transfers = [];
  TransferStatus? _selectedStatus;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTransfers(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransfers();
    }
  }

  Future<void> _loadTransfers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _hasMoreData = true;
        _transfers.clear();
      });
    }

    if (!_hasMoreData) return;

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final transfers = await InventoryService.getStockTransfers(
        companyId: companyId,
        skip: _currentPage * AppConstants.defaultPageSize,
        take: AppConstants.defaultPageSize,
        status: _selectedStatus,
      );

      setState(() {
        if (refresh) {
          _transfers = transfers;
        } else {
          _transfers.addAll(transfers);
        }
        _currentPage++;
        _hasMoreData = transfers.length == AppConstants.defaultPageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorCreatingTransfer}: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreTransfers() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);
    await _loadTransfers();
    setState(() => _isLoadingMore = false);
  }

  void _onStatusFilterChanged(TransferStatus? status) {
    setState(() => _selectedStatus = status);
    _loadTransfers(refresh: true);
  }

  Future<void> _completeTransfer(StockTransferDto transfer) async {
    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.completeStockTransfer(companyId, transfer.id);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.transferCompleted),
            backgroundColor: const Color(AppColors.success),
          ),
        );
        _loadTransfers(refresh: true);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorCompletingTransfer}: $e')),
        );
      }
    }
  }

  Future<void> _cancelTransfer(StockTransferDto transfer) async {
    final reason = await _showCancelReasonDialog();
    if (reason == null) return;

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.cancelStockTransfer(companyId, transfer.id, reason);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.transferCancelled),
            backgroundColor: const Color(AppColors.warning),
          ),
        );
        _loadTransfers(refresh: true);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorCancellingTransfer}: $e')),
        );
      }
    }
  }

  Future<String?> _showCancelReasonDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelTransferTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.provideCancellationReason),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.cancellationReason,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusFilter(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTransferList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(AppColors.backgroundLight),
        border: Border(
          bottom: BorderSide(color: Color(AppColors.textHint), width: 0.5),
        ),
      ),
      child: DropdownButtonFormField<TransferStatus>(
        value: _selectedStatus,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        hint: Text(l10n.allStatuses),
        items: [
          DropdownMenuItem<TransferStatus>(
            value: null,
            child: Text(l10n.allStatuses),
          ),
          ...TransferStatus.values.map((status) {
            return DropdownMenuItem<TransferStatus>(
              value: status,
              child: Text(status.name.toUpperCase()),
            );
          }),
        ],
        onChanged: _onStatusFilterChanged,
      ),
    );
  }

  Widget _buildTransferList() {
    final l10n = AppLocalizations.of(context)!;
    if (_transfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.swap_horiz,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTransfersFound,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTransfers(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _transfers.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _transfers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final transfer = _transfers[index];
          return _buildTransferCard(transfer);
        },
      ),
    );
  }

  Widget _buildTransferCard(StockTransferDto transfer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    transfer.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                ),
                _buildStatusChip(transfer.status),
              ],
            ),
            const SizedBox(height: 8),
            _buildTransferDetails(transfer),
            const SizedBox(height: 12),
            _buildTransferActions(transfer),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferDetails(StockTransferDto transfer) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: Color(AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${transfer.fromLocation} → ${transfer.toLocation}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(AppColors.textSecondary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.inventory,
              size: 16,
              color: Color(AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            Text(
              'Quantity: ${transfer.quantity}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textSecondary),
              ),
            ),
            const Spacer(),
            Text(
              _formatDate(transfer.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Color(AppColors.textHint),
              ),
            ),
          ],
        ),
        if (transfer.notes != null) ...[
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.note,
                size: 16,
                color: Color(AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  transfer.notes!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(AppColors.textSecondary),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip(TransferStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case TransferStatus.pending:
        backgroundColor = const Color(AppColors.warning);
        textColor = Colors.white;
        break;
      case TransferStatus.inProgress:
        backgroundColor = const Color(AppColors.info);
        textColor = Colors.white;
        break;
      case TransferStatus.completed:
        backgroundColor = const Color(AppColors.success);
        textColor = Colors.white;
        break;
      case TransferStatus.cancelled:
        backgroundColor = const Color(AppColors.error);
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTransferActions(StockTransferDto transfer) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[];

    if (transfer.status == TransferStatus.pending || transfer.status == TransferStatus.inProgress) {
      actions.add(
        TextButton(
          onPressed: () => _completeTransfer(transfer),
          child: Text(l10n.completeTransfer),
        ),
      );
      actions.add(
        TextButton(
          onPressed: () => _cancelTransfer(transfer),
          style: TextButton.styleFrom(
            foregroundColor: const Color(AppColors.error),
          ),
          child: Text(l10n.cancelTransfer),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}