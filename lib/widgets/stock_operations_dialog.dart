import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../models/product.dart';
import '../services/inventory_service.dart';
import '../services/company_service.dart';
import '../utils/constants.dart';

enum StockOperationType { adjust, reserve, release, transfer }

class StockOperationsDialog extends StatefulWidget {
  final StockItem stockItem;
  final List<InventoryLocation> warehouses;
  final VoidCallback onSuccess;

  const StockOperationsDialog({
    super.key,
    required this.stockItem,
    required this.warehouses,
    required this.onSuccess,
  });

  @override
  State<StockOperationsDialog> createState() => _StockOperationsDialogState();
}

class _StockOperationsDialogState extends State<StockOperationsDialog> {
  StockOperationType _selectedOperation = StockOperationType.adjust;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedWarehouseId;
  bool _isLoading = false;

  final List<String> _adjustReasons = [
    'Inventory Count Correction',
    'Damaged Items',
    'Expired Items',
    'Loss/Theft',
    'Returned Items',
    'Other',
  ];

  final List<String> _reserveReasons = [
    'Customer Order',
    'Production Order',
    'Quality Control',
    'Maintenance',
    'Other',
  ];

  final List<String> _releaseReasons = [
    'Order Cancelled',
    'Quality Issue',
    'Customer Request',
    'Expired Reservation',
    'Other',
  ];

  final List<String> _transferReasons = [
    'Warehouse Optimization',
    'Customer Request',
    'Production Requirement',
    'Maintenance',
    'Other',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> get _currentReasons {
    switch (_selectedOperation) {
      case StockOperationType.adjust:
        return _adjustReasons;
      case StockOperationType.reserve:
        return _reserveReasons;
      case StockOperationType.release:
        return _releaseReasons;
      case StockOperationType.transfer:
        return _transferReasons;
    }
  }

  String get _operationTitle {
    switch (_selectedOperation) {
      case StockOperationType.adjust:
        return 'Adjust Stock';
      case StockOperationType.reserve:
        return 'Reserve Stock';
      case StockOperationType.release:
        return 'Release Stock';
      case StockOperationType.transfer:
        return 'Transfer Stock';
    }
  }

  String get _quantityLabel {
    switch (_selectedOperation) {
      case StockOperationType.adjust:
        return 'Quantity Change (+/-)';
      case StockOperationType.reserve:
        return 'Quantity to Reserve';
      case StockOperationType.release:
        return 'Quantity to Release';
      case StockOperationType.transfer:
        return 'Quantity to Transfer';
    }
  }

  int get _maxQuantity {
    switch (_selectedOperation) {
      case StockOperationType.adjust:
        return 999999; // Allow negative adjustments
      case StockOperationType.reserve:
        return widget.stockItem.availableQuantity;
      case StockOperationType.release:
        return widget.stockItem.reservedQuantity;
      case StockOperationType.transfer:
        return widget.stockItem.availableQuantity;
    }
  }

  Future<void> _performOperation() async {
    if (_quantityController.text.isEmpty || _reasonController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null) {
      _showError('Please enter a valid quantity');
      return;
    }

    if (_selectedOperation == StockOperationType.transfer && _selectedWarehouseId == null) {
      _showError('Please select a destination warehouse');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();

      switch (_selectedOperation) {
        case StockOperationType.adjust:
          await InventoryService.adjustStockItem(
            companyId,
            widget.stockItem.id,
            StockItemAdjustmentRequest(
              stockItemId: widget.stockItem.id,
              adjustmentQuantity: quantity,
              reason: _reasonController.text,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            ),
          );
          break;
        case StockOperationType.reserve:
          await InventoryService.reserveStockItem(
            companyId,
            widget.stockItem.id,
            ReserveStockRequest(
              stockItemId: widget.stockItem.id,
              quantity: quantity,
              reason: _reasonController.text,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            ),
          );
          break;
        case StockOperationType.release:
          await InventoryService.releaseStockItem(
            companyId,
            widget.stockItem.id,
            ReleaseStockRequest(
              quantity: quantity,
              reason: _reasonController.text,
            ),
          );
          break;
        case StockOperationType.transfer:
          await InventoryService.transferStockItem(
            companyId,
            widget.stockItem.id,
            TransferStockRequest(
              toWarehouseId: _selectedWarehouseId!,
              quantity: quantity,
              reason: _reasonController.text,
            ),
          );
          break;
      }

      widget.onSuccess();
      Navigator.of(context).pop();
      _showSuccess('${_operationTitle} completed successfully');
    } catch (e) {
      _showError('Failed to perform operation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(AppColors.error),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(AppColors.success),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.settings, color: Color(AppColors.primaryIndigo)),
                const SizedBox(width: 8),
                Text(
                  'Stock Operations',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textPrimary),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stockItem.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('SKU: ${widget.stockItem.sku}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Total: ${widget.stockItem.quantity}'),
                      const SizedBox(width: 16),
                      Text('Available: ${widget.stockItem.availableQuantity}'),
                      const SizedBox(width: 16),
                      Text('Reserved: ${widget.stockItem.reservedQuantity}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Operation Type Selection
            Text(
              'Operation Type',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildOperationChip(StockOperationType.adjust, 'Adjust', Icons.tune),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOperationChip(StockOperationType.reserve, 'Reserve', Icons.lock),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildOperationChip(StockOperationType.release, 'Release', Icons.lock_open),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOperationChip(StockOperationType.transfer, 'Transfer', Icons.swap_horiz),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quantity Input
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _quantityLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                helperText: _selectedOperation == StockOperationType.adjust
                    ? 'Use positive numbers to add, negative to subtract'
                    : 'Max: $_maxQuantity',
              ),
            ),
            const SizedBox(height: 16),

            // Reason Selection
            DropdownButtonFormField<String>(
              value: _reasonController.text.isEmpty ? null : _reasonController.text,
              decoration: InputDecoration(
                labelText: 'Reason *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _currentReasons.map((reason) {
                return DropdownMenuItem(value: reason, child: Text(reason));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _reasonController.text = value;
                }
              },
            ),
            const SizedBox(height: 16),

            // Warehouse Selection (for transfer only)
            if (_selectedOperation == StockOperationType.transfer) ...[
              DropdownButtonFormField<String>(
                value: _selectedWarehouseId,
                decoration: InputDecoration(
                  labelText: 'Destination Warehouse *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: widget.warehouses
                    .where((w) => w.id != widget.stockItem.warehouseId && w.isActive)
                    .map((warehouse) {
                  return DropdownMenuItem(
                    value: warehouse.id,
                    child: Text(warehouse.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedWarehouseId = value);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Notes Input
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _performOperation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.primaryIndigo),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_operationTitle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationChip(StockOperationType type, String label, IconData icon) {
    final isSelected = _selectedOperation == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedOperation = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(AppColors.primaryIndigo)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}