import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../services/orders_service.dart';
import '../../utils/constants.dart';

class OrderOperationsDialog extends StatefulWidget {
  final OrderDto order;
  final Function(OrderDto) onOrderUpdated;

  const OrderOperationsDialog({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<OrderOperationsDialog> createState() => _OrderOperationsDialogState();
}

class _OrderOperationsDialogState extends State<OrderOperationsDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(AppColors.accentCyan).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Color(AppColors.accentCyan),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderOperations,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      widget.order.orderNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Color(AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else
            _buildOperationsList(),
        ],
      ),
    );
  }

  Widget _buildOperationsList() {
    final l10n = AppLocalizations.of(context)!;
    final operations = <Widget>[];

    if (widget.order.status == OrderStatus.pending) {
      operations.add(_buildOperationTile(
        l10n.confirmOrder,
        l10n.acceptAndConfirmOrder,
        Icons.check_circle,
        const Color(AppColors.success),
        () => _confirmOrder(),
      ));
    }

    if (widget.order.canProcess) {
      operations.add(_buildOperationTile(
        l10n.processOrder,
        l10n.moveToProcessing,
        Icons.play_arrow,
        const Color(AppColors.info),
        () => _processOrder(),
      ));
    }

    if (widget.order.status == OrderStatus.processing) {
      operations.add(_buildOperationTile(
        l10n.markAsReady,
        l10n.markOrderReadyForShipping,
        Icons.assignment_turned_in,
        const Color(AppColors.accentCyan),
        () => _markOrderReady(),
      ));
    }

    if (widget.order.canShip) {
      operations.add(_buildOperationTile(
        l10n.shipOrder,
        l10n.shipOrderWithTracking,
        Icons.local_shipping,
        const Color(AppColors.primaryIndigo),
        () => _shipOrder(),
      ));
    }

    if (widget.order.status == OrderStatus.shipped) {
      operations.add(_buildOperationTile(
        l10n.markAsDelivered,
        l10n.markOrderAsDelivered,
        Icons.done_all,
        const Color(AppColors.success),
        () => _markOrderDelivered(),
      ));
    }

    if (widget.order.canCancel) {
      operations.add(_buildOperationTile(
        l10n.cancelOrder,
        l10n.cancelOrderWithReason,
        Icons.cancel,
        const Color(AppColors.error),
        () => _cancelOrder(),
      ));
    }

    if (widget.order.status == OrderStatus.delivered) {
      operations.add(_buildOperationTile(
        l10n.processReturnForOrder,
        l10n.processReturnForOrder,
        Icons.keyboard_return,
        const Color(AppColors.warning),
        () => _processReturn(),
      ));
    }

    if (operations.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            l10n.noOperationsAvailable,
            style: TextStyle(
              fontSize: 16,
              color: Color(AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return Column(children: operations);
  }

  Widget _buildOperationTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(AppColors.borderLight)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final notes = await _showNotesDialog(l10n.confirmOrder, l10n.addConfirmationNotesOptional);
    if (notes == null) return;

    await _performOperation(() => OrdersService.confirmOrder(widget.order.id, notes: notes));
  }

  Future<void> _processOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final notes = await _showNotesDialog(l10n.processOrder, l10n.addProcessingNotesOptional);
    if (notes == null) return;

    await _performOperation(() => OrdersService.processOrder(widget.order.id, notes: notes));
  }

  Future<void> _markOrderReady() async {
    final l10n = AppLocalizations.of(context)!;
    final notes = await _showNotesDialog(l10n.markAsReady, l10n.notes);
    if (notes == null) return;

    await _performOperation(() => OrdersService.markOrderReady(widget.order.id, notes: notes));
  }

  Future<void> _shipOrder() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ShipOrderDialog(),
    );

    if (result == null) return;

    await _performOperation(() => OrdersService.shipOrder(
          widget.order.id,
          trackingNumber: result['trackingNumber'],
          notes: result['notes'],
        ));
  }

  Future<void> _markOrderDelivered() async {
    final l10n = AppLocalizations.of(context)!;
    final notes = await _showNotesDialog(l10n.markAsDelivered, l10n.addDeliveryNotesOptional);
    if (notes == null) return;

    await _performOperation(() => OrdersService.markOrderDelivered(widget.order.id, notes: notes));
  }

  Future<void> _cancelOrder() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _CancelOrderDialog(),
    );

    if (result == null) return;

    await _performOperation(() => OrdersService.cancelOrder(
          widget.order.id,
          reason: result['reason']!,
          notes: result['notes'],
        ));
  }

  Future<void> _processReturn() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ReturnOrderDialog(),
    );

    if (result == null) return;

    await _performOperation(() => OrdersService.returnOrder(
          widget.order.id,
          reason: result['reason']!,
          notes: result['notes'],
        ));
  }

  Future<void> _performOperation(Future<OrderDto> Function() operation) async {
    setState(() => _isLoading = true);

    try {
      final updatedOrder = await operation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.operationCompletedSuccessfully),
            backgroundColor: Color(AppColors.success),
          ),
        );
        widget.onOrderUpdated(updatedOrder);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String?> _showNotesDialog(String title, String hint) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hint,
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.notes,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(AppColors.backgroundLight),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Color(AppColors.textSecondary)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.accentCyan),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(l10n.continueButton),
          ),
        ],
      ),
    );
  }
}

class _ShipOrderDialog extends StatefulWidget {
  @override
  _ShipOrderDialogState createState() => _ShipOrderDialogState();
}

class _ShipOrderDialogState extends State<_ShipOrderDialog> {
  final _trackingController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _trackingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.shipOrder,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textPrimary),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _trackingController,
            decoration: InputDecoration(
              labelText: l10n.trackingNumber,
              hintText: l10n.trackingNumber,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(AppColors.backgroundLight),
              prefixIcon: const Icon(Icons.local_shipping, color: Color(AppColors.accentCyan)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notesOptional,
              hintText: l10n.addShippingNotes,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(AppColors.backgroundLight),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: Color(AppColors.textSecondary)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'trackingNumber': _trackingController.text.trim(),
              'notes': _notesController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.success),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(l10n.ship),
        ),
      ],
    );
  }
}

class _CancelOrderDialog extends StatefulWidget {
  @override
  _CancelOrderDialogState createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  final _notesController = TextEditingController();
  String? _selectedReason;

  List<String> _getCancelReasons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.customerRequest,
      l10n.outOfStock,
      l10n.paymentIssues,
      l10n.addressIssues,
      l10n.systemError,
      l10n.duplicateOrder,
      l10n.qualityConcerns,
      l10n.other,
    ];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cancelReasons = _getCancelReasons(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.cancelOrder,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textPrimary),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: InputDecoration(
              labelText: l10n.cancellationReason,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(AppColors.backgroundLight),
              prefixIcon: const Icon(Icons.cancel, color: Color(AppColors.error)),
            ),
            items: cancelReasons.map((reason) {
              return DropdownMenuItem(value: reason, child: Text(reason));
            }).toList(),
            onChanged: (value) => setState(() => _selectedReason = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.additionalNotes,
              hintText: l10n.addCancellationDetails,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(AppColors.backgroundLight),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: Color(AppColors.textSecondary)),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedReason != null
              ? () {
                  Navigator.of(context).pop({
                    'reason': _selectedReason!,
                    'notes': _notesController.text.trim(),
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.error),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(l10n.cancelOrder),
        ),
      ],
    );
  }
}

class _ReturnOrderDialog extends StatefulWidget {
  @override
  _ReturnOrderDialogState createState() => _ReturnOrderDialogState();
}

class _ReturnOrderDialogState extends State<_ReturnOrderDialog> {
  final _notesController = TextEditingController();
  String? _selectedReason;

  List<String> _getReturnReasons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.defectiveProduct,
      l10n.wrongItemSent,
      l10n.customerDissatisfaction,
      l10n.sizeFitIssues,
      l10n.damagedDuringShipping,
      l10n.changedMind,
      l10n.qualityIssues,
      l10n.other,
    ];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final returnReasons = _getReturnReasons(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.processReturnForOrder,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textPrimary),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: InputDecoration(
              labelText: l10n.returnReason,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(AppColors.backgroundLight),
              prefixIcon: const Icon(Icons.keyboard_return, color: Color(AppColors.warning)),
            ),
            items: returnReasons.map((reason) {
              return DropdownMenuItem(value: reason, child: Text(reason));
            }).toList(),
            onChanged: (value) => setState(() => _selectedReason = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.returnDetails,
              hintText: l10n.addReturnProcessingDetails,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(AppColors.backgroundLight),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: Color(AppColors.textSecondary)),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedReason != null
              ? () {
                  Navigator.of(context).pop({
                    'reason': _selectedReason!,
                    'notes': _notesController.text.trim(),
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.warning),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(l10n.processReturnForOrder),
        ),
      ],
    );
  }
}