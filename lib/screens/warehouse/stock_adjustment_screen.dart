import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';

class StockAdjustmentScreen extends StatefulWidget {
  final String? productId;

  const StockAdjustmentScreen({super.key, this.productId});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  List<ProductDto> _products = [];
  ProductDto? _selectedProduct;
  String? _selectedReason;
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<String> get _adjustmentReasons => [
    AppLocalizations.of(context)!.physicalCountCorrection,
    AppLocalizations.of(context)!.damagedGoods,
    AppLocalizations.of(context)!.expiredProducts,
    AppLocalizations.of(context)!.theftLoss,
    AppLocalizations.of(context)!.returnToSupplier,
    AppLocalizations.of(context)!.qualityControlRejection,
    AppLocalizations.of(context)!.systemErrorCorrection,
    AppLocalizations.of(context)!.other,
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final products = await InventoryService.getProducts(companyId: companyId);
      setState(() {
        _products = products;
        if (widget.productId != null) {
          _selectedProduct = products.firstWhere(
            (p) => p.id == widget.productId,
            orElse: () => products.first,
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingProducts}: $e')),
        );
      }
    }
  }

  Future<void> _submitAdjustment() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null || _selectedReason == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final quantityChange = int.parse(_quantityController.text);

      final request = StockAdjustmentRequest(
        productId: _selectedProduct!.id,
        quantityChange: quantityChange,
        reason: _selectedReason!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.adjustStock(companyId, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.stockAdjustmentCompleted),
            backgroundColor: Color(AppColors.success),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorAdjustingStock}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.stockAdjustment),
        backgroundColor: const Color(AppColors.accentCyan),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductSelector(),
                    const SizedBox(height: 20),
                    if (_selectedProduct != null) _buildCurrentStockInfo(),
                    const SizedBox(height: 20),
                    _buildQuantityInput(),
                    const SizedBox(height: 20),
                    _buildReasonSelector(),
                    const SizedBox(height: 20),
                    _buildNotesInput(),
                    const Spacer(),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.selectProduct,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ProductDto>(
          value: _selectedProduct,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          isExpanded: true,
          hint: Text(AppLocalizations.of(context)!.chooseProduct),
          items: _products.map((product) {
            return DropdownMenuItem(
              value: product,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (product.sku.isNotEmpty || product.stockQuantity > 0)
                    Text(
                      'SKU: ${product.sku} • Stock: ${product.stockQuantity}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(AppColors.textSecondary),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (product) {
            setState(() => _selectedProduct = product);
          },
          validator: (value) {
            if (value == null) {
              return AppLocalizations.of(context)!.pleaseSelectProduct;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCurrentStockInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppColors.info).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(AppColors.info).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info,
            color: Color(AppColors.info),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.currentStockInformation,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.info),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context)!.current}: ${_selectedProduct!.stockQuantity} ${_selectedProduct!.unit}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${AppLocalizations.of(context)!.minimum}: ${_selectedProduct!.minimumStockLevel} ${_selectedProduct!.unit}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${AppLocalizations.of(context)!.status}: ${_selectedProduct!.stockStatus}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedProduct!.isLowStock
                        ? const Color(AppColors.warning)
                        : const Color(AppColors.success),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.quantityChange,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: AppLocalizations.of(context)!.enterQuantity,
            prefixIcon: const Icon(Icons.edit),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseEnterQuantity;
            }
            final quantity = int.tryParse(value);
            if (quantity == null) {
              return AppLocalizations.of(context)!.pleaseEnterValidNumber;
            }
            if (quantity == 0) {
              return AppLocalizations.of(context)!.quantityCannotBeZero;
            }
            if (_selectedProduct != null) {
              final newQuantity = _selectedProduct!.stockQuantity + quantity;
              if (newQuantity < 0) {
                return AppLocalizations.of(context)!.cannotReduceBelowZero;
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.usePositiveNumbers,
          style: const TextStyle(
            fontSize: 12,
            color: Color(AppColors.textHint),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.adjustmentReason,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedReason,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: Text(AppLocalizations.of(context)!.selectReason),
          items: _adjustmentReasons.map((reason) {
            return DropdownMenuItem(
              value: reason,
              child: Text(reason),
            );
          }).toList(),
          onChanged: (reason) {
            setState(() => _selectedReason = reason);
          },
          validator: (value) {
            if (value == null) {
              return AppLocalizations.of(context)!.pleaseSelectReason;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.notesOptional,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintText: AppLocalizations.of(context)!.addNotes,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitAdjustment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.accentCyan),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.processing),
                ],
              )
            : Text(
                AppLocalizations.of(context)!.adjustStock,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}