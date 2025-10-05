import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../models/warehouse.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';
import 'stock_adjustment_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductDto product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProductDto _product;
  List<StockMovementDto> _stockMovements = [];
  Map<String, double> _stockByLocation = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _product = widget.product;
    _loadAdditionalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdditionalData() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final results = await Future.wait([
        InventoryService.getStockMovements(companyId: companyId, productId: _product.id),
        InventoryService.getStockItemsByProduct(companyId, _product.id),
      ]);

      // Convert List<StockItem> to Map<String, double> (location name -> quantity)
      final stockItems = results[1] as List<StockItem>;
      final stockByLocation = <String, double>{};
      for (final item in stockItems) {
        final locationName = item.warehouseName ?? 'Unknown Location';
        stockByLocation[locationName] = (stockByLocation[locationName] ?? 0.0) + item.quantity;
      }

      setState(() {
        _stockMovements = results[0] as List<StockMovementDto>;
        _stockByLocation = stockByLocation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingData}: $e')),
        );
      }
    }
  }

  Future<void> _refreshProduct() async {
    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final updatedProduct = await InventoryService.getProduct(companyId, _product.id);
      setState(() => _product = updatedProduct);
      _loadAdditionalData();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingData}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product.name),
        backgroundColor: const Color(AppColors.primaryIndigo),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshProduct,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'adjust',
                child: Row(
                  children: [
                    const Icon(Icons.tune),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.adjustStock),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.editProduct),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.details),
            Tab(text: AppLocalizations.of(context)!.stock),
            Tab(text: AppLocalizations.of(context)!.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildStockTab(),
          _buildHistoryTab(),
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
          _buildProductImages(),
          const SizedBox(height: 20),
          _buildBasicInfo(),
          const SizedBox(height: 20),
          _buildPricingInfo(),
          const SizedBox(height: 20),
          _buildStockStatus(),
        ],
      ),
    );
  }

  Widget _buildProductImages() {
    if (_product.imageUrls.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(AppColors.textHint).withValues(alpha: 0.3),
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.inventory,
            size: 64,
            color: Color(AppColors.textHint),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: _product.imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(AppColors.textHint).withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _product.imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Color(AppColors.textHint),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.productDetails,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.sku, _product.sku),
            _buildInfoRow(l10n.category, _product.categoryName),
            _buildInfoRow(l10n.unit, _product.unit),
            _buildInfoRow(l10n.status, _product.isActive ? l10n.active : l10n.inactive),
            const SizedBox(height: 12),
            Text(
              l10n.description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _product.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.primaryIndigo).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.unitPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.textSecondary),
                          ),
                        ),
                        Text(
                          '\$${_product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.primaryIndigo),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.success).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.totalValue,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.textSecondary),
                          ),
                        ),
                        Text(
                          '\$${(_product.price * _product.stockQuantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.success),
                          ),
                        ),
                      ],
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

  Widget _buildStockStatus() {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    if (_product.isOutOfStock) {
      statusColor = const Color(AppColors.error);
    } else if (_product.isLowStock) {
      statusColor = const Color(AppColors.warning);
    } else {
      statusColor = const Color(AppColors.success);
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.stockStatus,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStockCard(
                    l10n.currentStock,
                    '${_product.stockQuantity}',
                    _product.unit,
                    statusColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStockCard(
                    l10n.minimum,
                    '${_product.minimumStockLevel}',
                    _product.unit,
                    const Color(AppColors.info),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _product.isOutOfStock
                        ? Icons.error
                        : _product.isLowStock
                            ? Icons.warning
                            : Icons.check_circle,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _product.stockStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
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

  Widget _buildStockCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockTab() {
    return RefreshIndicator(
      onRefresh: _loadAdditionalData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentStockCard(),
            const SizedBox(height: 20),
            _buildStockByLocationCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStockCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentStock,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '${_product.stockQuantity}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _product.isLowStock
                          ? const Color(AppColors.warning)
                          : const Color(AppColors.success),
                    ),
                  ),
                  Text(
                    _product.unit,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(AppColors.textSecondary),
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

  Widget _buildStockByLocationCard() {
    final l10n = AppLocalizations.of(context)!;
    if (_stockByLocation.isEmpty) {
      return const SizedBox();
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.stock} by ${l10n.location}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            ..._stockByLocation.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(AppColors.textPrimary),
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(entry.value == entry.value.roundToDouble() ? 0 : 2)} ${_product.unit}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.actions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToStockAdjustment(),
                icon: const Icon(Icons.tune),
                label: Text(l10n.adjustStock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.accentCyan),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stockMovements.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noHistoryAvailable,
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
      onRefresh: _loadAdditionalData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stockMovements.length,
        itemBuilder: (context, index) {
          final movement = _stockMovements[index];
          return _buildMovementCard(movement);
        },
      ),
    );
  }

  Widget _buildMovementCard(StockMovementDto movement) {
    final isIncrease = movement.quantityChange > 0;
    final color = isIncrease
        ? const Color(AppColors.success)
        : const Color(AppColors.error);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isIncrease ? Icons.add_circle : Icons.remove_circle,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    movement.type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                ),
                Text(
                  '${isIncrease ? '+' : ''}${movement.quantityChange}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${movement.reason}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textSecondary),
              ),
            ),
            Text(
              'Stock: ${movement.previousQuantity} → ${movement.newQuantity}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textSecondary),
              ),
            ),
            if (movement.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${movement.notes}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(AppColors.textSecondary),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _formatDate(movement.createdAt),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'adjust':
        _navigateToStockAdjustment();
        break;
      case 'edit':
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.editProduct} feature coming soon')),
        );
        break;
    }
  }

  void _navigateToStockAdjustment() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StockAdjustmentScreen(productId: _product.id),
      ),
    );

    if (result == true) {
      _refreshProduct();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}