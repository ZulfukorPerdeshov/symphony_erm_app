import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';

class StockTakingScreen extends StatefulWidget {
  const StockTakingScreen({super.key});

  @override
  State<StockTakingScreen> createState() => _StockTakingScreenState();
}

class _StockTakingScreenState extends State<StockTakingScreen>
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
        title: Text(l10n.stockTaking),
        backgroundColor: const Color(AppColors.warning),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: l10n.newCount),
            Tab(text: l10n.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CreateStockTakingTab(),
          StockTakingHistoryTab(),
        ],
      ),
    );
  }
}

class CreateStockTakingTab extends StatefulWidget {
  const CreateStockTakingTab({super.key});

  @override
  State<CreateStockTakingTab> createState() => _CreateStockTakingTabState();
}

class _CreateStockTakingTabState extends State<CreateStockTakingTab> {
  final _notesController = TextEditingController();

  List<InventoryLocation> _locations = [];
  List<ProductDto> _products = [];
  InventoryLocation? _selectedLocation;
  Map<String, TextEditingController> _countControllers = {};
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _countControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final locations = await InventoryService.getLocations(companyId);
      setState(() {
        _locations = locations.where((location) => location.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingLocations}: $e')),
        );
      }
    }
  }

  Future<void> _loadProductsForLocation(InventoryLocation location) async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final products = await InventoryService.getProducts(companyId: companyId);

      _countControllers.clear();
      for (final product in products) {
        _countControllers[product.id] = TextEditingController();
      }

      setState(() {
        _products = products;
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

  Future<void> _submitStockTaking() async {
    if (_selectedLocation == null) return;

    final items = <StockCountItem>[];
    for (final product in _products) {
      final controller = _countControllers[product.id];
      final countText = controller?.text.trim() ?? '';

      if (countText.isNotEmpty) {
        final count = int.tryParse(countText);
        if (count != null) {
          items.add(StockCountItem(
            productId: product.id,
            countedQuantity: count,
          ));
        }
      }
    }

    if (items.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseCountAtLeastOne)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = StockTakingRequest(
        locationId: _selectedLocation!.id,
        items: items,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      await InventoryService.createStockTaking(companyId, request);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.stockTakingCompleted),
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
          SnackBar(content: Text('${l10n.errorLoadingStockTakings}: $e')),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedLocation = null;
      _products.clear();
      _countControllers.clear();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationSelector(),
          const SizedBox(height: 20),
          if (_selectedLocation != null) ...[
            _buildProductCountList(),
            const SizedBox(height: 20),
            _buildNotesInput(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectLocation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<InventoryLocation>(
          value: _selectedLocation,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: Text(l10n.chooseLocation),
          items: _locations.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    location.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.textSecondary),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (location) {
            setState(() => _selectedLocation = location);
            if (location != null) {
              _loadProductsForLocation(location);
            }
          },
        ),
      ],
    );
  }

  Widget _buildProductCountList() {
    final l10n = AppLocalizations.of(context)!;
    if (_products.isEmpty) {
      return Center(
        child: Text(l10n.noProductsFound),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.countProducts,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductCountItem(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCountItem(ProductDto product) {
    final controller = _countControllers[product.id]!;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    '${l10n.sku}: ${product.sku}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    '${l10n.system}: ${product.stockQuantity} ${product.unit}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.counted,
                  suffixText: product.unit,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintText: l10n.addNotesAboutStockTaking,
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
        onPressed: _isSubmitting ? null : _submitStockTaking,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.warning),
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
                l10n.submitStockCount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class StockTakingHistoryTab extends StatefulWidget {
  const StockTakingHistoryTab({super.key});

  @override
  State<StockTakingHistoryTab> createState() => _StockTakingHistoryTabState();
}

class _StockTakingHistoryTabState extends State<StockTakingHistoryTab> {
  List<StockTakingDto> _stockTakings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStockTakings();
  }

  Future<void> _loadStockTakings() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final stockTakings = await InventoryService.getStockTakings(companyId: companyId);
      setState(() {
        _stockTakings = stockTakings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingStockTakings}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stockTakings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fact_check,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noStockTakingsFound,
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
      onRefresh: _loadStockTakings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stockTakings.length,
        itemBuilder: (context, index) {
          final stockTaking = _stockTakings[index];
          return _buildStockTakingCard(stockTaking);
        },
      ),
    );
  }

  Widget _buildStockTakingCard(StockTakingDto stockTaking) {
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
                    stockTaking.locationName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockTaking.status == StockTakingStatus.completed
                        ? const Color(AppColors.success)
                        : const Color(AppColors.warning),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stockTaking.status.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${_formatDate(stockTaking.createdAt)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textSecondary),
              ),
            ),
            if (stockTaking.discrepancies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Discrepancies: ${stockTaking.discrepancies.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(AppColors.error),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (stockTaking.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                stockTaking.notes!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(AppColors.textSecondary),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}