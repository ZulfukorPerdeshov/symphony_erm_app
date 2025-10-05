import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../models/product.dart';
import '../services/inventory_service.dart';
import '../services/company_service.dart';
import '../utils/constants.dart';

enum RawMaterialOperationType { adjust, reserve, release, transfer }

class RawMaterialOperationsDialog extends StatefulWidget {
  final RawMaterialStockItem rawMaterial;
  final List<InventoryLocation> warehouses;
  final VoidCallback onSuccess;

  const RawMaterialOperationsDialog({
    super.key,
    required this.rawMaterial,
    required this.warehouses,
    required this.onSuccess,
  });

  @override
  State<RawMaterialOperationsDialog> createState() => _RawMaterialOperationsDialogState();
}

class _RawMaterialOperationsDialogState extends State<RawMaterialOperationsDialog> {
  RawMaterialOperationType _selectedOperation = RawMaterialOperationType.adjust;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedWarehouseId;
  bool _isLoading = false;

  final List<String> _adjustReasons = [
    'Inventory Count Correction',
    'Damaged Materials',
    'Expired Materials',
    'Loss/Theft',
    'Returned Materials',
    'Supplier Adjustment',
    'Other',
  ];

  final List<String> _reserveReasons = [
    'Production Order',
    'Quality Control',
    'Research & Development',
    'Maintenance',
    'Special Project',
    'Other',
  ];

  final List<String> _releaseReasons = [
    'Production Cancelled',
    'Quality Issue',
    'Expired Reservation',
    'Project Change',
    'Other',
  ];

  final List<String> _transferReasons = [
    'Production Requirement',
    'Warehouse Optimization',
    'Quality Control',
    'Emergency Need',
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
      case RawMaterialOperationType.adjust:
        return _adjustReasons;
      case RawMaterialOperationType.reserve:
        return _reserveReasons;
      case RawMaterialOperationType.release:
        return _releaseReasons;
      case RawMaterialOperationType.transfer:
        return _transferReasons;
    }
  }

  String get _operationTitle {
    switch (_selectedOperation) {
      case RawMaterialOperationType.adjust:
        return 'Adjust Raw Material';
      case RawMaterialOperationType.reserve:
        return 'Reserve Raw Material';
      case RawMaterialOperationType.release:
        return 'Release Raw Material';
      case RawMaterialOperationType.transfer:
        return 'Transfer Raw Material';
    }
  }

  String get _quantityLabel {
    switch (_selectedOperation) {
      case RawMaterialOperationType.adjust:
        return 'Quantity Change (+/-)';
      case RawMaterialOperationType.reserve:
        return 'Quantity to Reserve';
      case RawMaterialOperationType.release:
        return 'Quantity to Release';
      case RawMaterialOperationType.transfer:
        return 'Quantity to Transfer';
    }
  }

  double get _maxQuantity {
    switch (_selectedOperation) {
      case RawMaterialOperationType.adjust:
        return 999999; // Allow negative adjustments
      case RawMaterialOperationType.reserve:
        return widget.rawMaterial.availableQuantity;
      case RawMaterialOperationType.release:
        return widget.rawMaterial.reservedQuantity;
      case RawMaterialOperationType.transfer:
        return widget.rawMaterial.availableQuantity;
    }
  }

  Future<void> _performOperation() async {
    if (_quantityController.text.isEmpty || _reasonController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null) {
      _showError('Please enter a valid quantity');
      return;
    }

    if (_selectedOperation == RawMaterialOperationType.transfer && _selectedWarehouseId == null) {
      _showError('Please select a destination warehouse');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();

      switch (_selectedOperation) {
        case RawMaterialOperationType.adjust:
          await InventoryService.adjustRawMaterialStock(
            companyId,
            RawMaterialAdjustRequest(
              rawMaterialId: widget.rawMaterial.id,
              quantityChange: quantity,
              reason: _reasonController.text,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            ),
          );
          break;
        case RawMaterialOperationType.reserve:
          await InventoryService.reserveRawMaterial(
            companyId,
            RawMaterialReserveRequest(
              rawMaterialId: widget.rawMaterial.id,
              quantity: quantity,
              purpose: _reasonController.text,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            ),
          );
          break;
        case RawMaterialOperationType.release:
          await InventoryService.releaseRawMaterial(
            companyId,
            RawMaterialReleaseRequest(
              rawMaterialId: widget.rawMaterial.id,
              quantity: quantity,
              reason: _reasonController.text,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            ),
          );
          break;
        case RawMaterialOperationType.transfer:
          await InventoryService.transferRawMaterial(
            companyId,
            RawMaterialTransferRequest(
              rawMaterialId: widget.rawMaterial.id,
              toWarehouseId: _selectedWarehouseId!,
              quantity: quantity,
              reason: _reasonController.text,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
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
                const Icon(Icons.science, color: Color(AppColors.primaryIndigo)),
                const SizedBox(width: 8),
                Text(
                  'Raw Material Operations',
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

            // Raw Material Info
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
                    widget.rawMaterial.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.rawMaterial.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(widget.rawMaterial.description),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Total: ${widget.rawMaterial.quantity.toStringAsFixed(2)} ${widget.rawMaterial.unit}'),
                      const SizedBox(width: 16),
                      Text('Available: ${widget.rawMaterial.availableQuantity.toStringAsFixed(2)}'),
                      const SizedBox(width: 16),
                      Text('Reserved: ${widget.rawMaterial.reservedQuantity.toStringAsFixed(2)}'),
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
                  child: _buildOperationChip(RawMaterialOperationType.adjust, 'Adjust', Icons.tune),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOperationChip(RawMaterialOperationType.reserve, 'Reserve', Icons.lock),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildOperationChip(RawMaterialOperationType.release, 'Release', Icons.lock_open),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOperationChip(RawMaterialOperationType.transfer, 'Transfer', Icons.swap_horiz),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quantity Input
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${_quantityLabel} (${widget.rawMaterial.unit})',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                helperText: _selectedOperation == RawMaterialOperationType.adjust
                    ? 'Use positive numbers to add, negative to subtract'
                    : 'Max: ${_maxQuantity.toStringAsFixed(2)}',
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
            if (_selectedOperation == RawMaterialOperationType.transfer) ...[
              DropdownButtonFormField<String>(
                value: _selectedWarehouseId,
                decoration: InputDecoration(
                  labelText: 'Destination Warehouse *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: widget.warehouses
                    .where((w) => w.id != widget.rawMaterial.warehouseId && w.isActive)
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

  Widget _buildOperationChip(RawMaterialOperationType type, String label, IconData icon) {
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