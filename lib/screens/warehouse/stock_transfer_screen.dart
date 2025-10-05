import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';
import 'stock_transfer_list_screen.dart';

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stockTransfer),
        backgroundColor: const Color(AppColors.info),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: l10n.createTransfer),
            Tab(text: l10n.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CreateStockTransferTab(),
          StockTransferListScreen(),
        ],
      ),
    );
  }
}

class CreateStockTransferTab extends StatefulWidget {
  const CreateStockTransferTab({super.key});

  @override
  State<CreateStockTransferTab> createState() => _CreateStockTransferTabState();
}

class _CreateStockTransferTabState extends State<CreateStockTransferTab> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  List<ProductDto> _products = [];
  List<InventoryLocation> _locations = [];
  ProductDto? _selectedProduct;
  InventoryLocation? _fromLocation;
  InventoryLocation? _toLocation;
  String? _selectedReason;
  bool _isLoading = false;
  bool _isSubmitting = false;

  final List<String> _transferReasons = [
    'Warehouse Relocation',
    'Stock Redistribution',
    'Department Transfer',
    'Location Optimization',
    'Quality Control',
    'Customer Request',
    'Inventory Balancing',
    'Emergency Transfer',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final results = await Future.wait([
        InventoryService.getProducts(companyId: companyId),
        InventoryService.getLocations(companyId),
      ]);

      setState(() {
        _products = results[0] as List<ProductDto>;
        _locations = (results[1] as List<InventoryLocation>)
            .where((location) => location.isActive)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingProducts}: $e')),
        );
      }
    }
  }

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate() ||
        _selectedProduct == null ||
        _fromLocation == null ||
        _toLocation == null ||
        _selectedReason == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final quantity = int.parse(_quantityController.text);

      final request = StockTransferRequest(
        productId: _selectedProduct!.id,
        fromLocation: _fromLocation!.id,
        toLocation: _toLocation!.id,
        quantity: quantity,
        reason: _selectedReason!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.transferStock(companyId, request);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.stockTransferCreated),
            backgroundColor: const Color(AppColors.success),
          ),
        );
        _resetForm();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorCreatingTransfer}: $e')),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedProduct = null;
      _fromLocation = null;
      _toLocation = null;
      _selectedReason = null;
      _quantityController.clear();
      _notesController.clear();
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductSelector(),
            const SizedBox(height: 20),
            _buildLocationSelectors(),
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
    );
  }

  Widget _buildProductSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectProduct,
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
          hint: Text(l10n.chooseProduct),
          items: _products.map((product) {
            return DropdownMenuItem(
              value: product,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${l10n.sku}: ${product.sku} • ${l10n.stock}: ${product.stockQuantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (product) {
            setState(() {
              _selectedProduct = product;
              _fromLocation = null;
              _toLocation = null;
            });
          },
          validator: (value) {
            if (value == null) {
              return l10n.pleaseSelectProduct;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSelectors() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stockTransfer,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fromLocation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<InventoryLocation>(
                    value: _fromLocation,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: Text(l10n.selectFromLocation),
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(
                          location.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (location) {
                      setState(() {
                        _fromLocation = location;
                        if (_toLocation == location) {
                          _toLocation = null;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return l10n.pleaseSelectFromLocation;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward,
              color: Color(AppColors.info),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.toLocation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<InventoryLocation>(
                    value: _toLocation,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: Text(l10n.selectToLocation),
                    items: _locations
                        .where((location) => location != _fromLocation)
                        .map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(
                          location.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (location) {
                      setState(() => _toLocation = location);
                    },
                    validator: (value) {
                      if (value == null) {
                        return l10n.pleaseSelectToLocation;
                      }
                      if (value == _fromLocation) {
                        return l10n.locationsCannotBeSame;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.transferQuantity,
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
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: l10n.enterTransferQuantity,
            prefixIcon: const Icon(Icons.swap_horiz),
            suffixText: _selectedProduct?.unit,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterTransferQuantity;
            }
            final quantity = int.tryParse(value);
            if (quantity == null || quantity <= 0) {
              return l10n.pleaseEnterValidNumber;
            }
            if (_selectedProduct != null && quantity > _selectedProduct!.stockQuantity) {
              return l10n.insufficientStock;
            }
            return null;
          },
        ),
        if (_selectedProduct != null) ...[
          const SizedBox(height: 8),
          Text(
            'Available stock: ${_selectedProduct!.stockQuantity} ${_selectedProduct!.unit}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(AppColors.textHint),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReasonSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adjustmentReason,
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
          hint: Text(l10n.selectReason),
          items: _transferReasons.map((reason) {
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
              return l10n.pleaseSelectReason;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notesOptional,
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
            hintText: l10n.addNotes,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitTransfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.info),
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
                  Text(l10n.processing),
                ],
              )
            : Text(
                l10n.createTransfer,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}