import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';
import 'product_list_screen.dart';
import 'stock_adjustment_screen.dart';
import 'stock_transfer_screen.dart';
import 'stock_taking_screen.dart';
import 'warehouses_list_screen.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  Map<String, dynamic>? _inventoryStats;
  List<ProductDto> _lowStockProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();

      // Load data separately to handle individual failures gracefully
      Map<String, dynamic>? inventoryStats;
      List<ProductDto> lowStockProducts = [];

      // Try to get inventory stats - handle 404 gracefully
      try {
        inventoryStats = await InventoryService.getInventoryStats(companyId);
      } catch (e) {
        print('Inventory stats endpoint not available: $e');
        // Create mock stats if endpoint doesn't exist
        inventoryStats = {
          'totalProducts': 0,
          'lowStockCount': 0,
          'outOfStockCount': 0,
          'totalValue': 0.0,
        };
      }

      // Try to get low stock products
      try {
        lowStockProducts = await InventoryService.getLowStockProducts(companyId);
      } catch (e) {
        print('Low stock products endpoint error: $e');
        // Continue without low stock products
      }

      setState(() {
        _inventoryStats = inventoryStats;
        _lowStockProducts = lowStockProducts;
        _isLoading = false;
      });
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.warehouse),
        backgroundColor: const Color(AppColors.primaryIndigo),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildLowStockAlert(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    if (_inventoryStats == null) return const SizedBox();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.inventory,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.products,
                _inventoryStats!['totalProducts']?.toString() ?? '0',
                Icons.inventory,
                const Color(AppColors.info),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.totalValue,
                '\$${_inventoryStats!['totalValue']?.toStringAsFixed(2) ?? '0.00'}',
                Icons.attach_money,
                const Color(AppColors.success),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.lowStock,
                _inventoryStats!['lowStockCount']?.toString() ?? '0',
                Icons.warning,
                const Color(AppColors.warning),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.outOfStock,
                _inventoryStats!['outOfStockCount']?.toString() ?? '0',
                Icons.error,
                const Color(AppColors.error),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.actions,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              l10n.products,
              Icons.inventory_2,
              const Color(AppColors.primaryIndigo),
              () => _navigateToScreen(const ProductListScreen()),
            ),
            _buildActionCard(
              l10n.warehouses,
              Icons.warehouse,
              const Color(AppColors.accentCyan),
              () => _navigateToScreen(const WarehousesListScreen()),
            ),
            _buildActionCard(
              l10n.stockAdjustment,
              Icons.tune,
              const Color(AppColors.info),
              () => _navigateToScreen(const StockAdjustmentScreen()),
            ),
            _buildActionCard(
              l10n.stockTransfer,
              Icons.swap_horiz,
              const Color(AppColors.success),
              () => _navigateToScreen(const StockTransferScreen()),
            ),
            _buildActionCard(
              l10n.stockTaking,
              Icons.fact_check,
              const Color(AppColors.warning),
              () => _navigateToScreen(const StockTakingScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlert() {
    if (_lowStockProducts.isEmpty) return const SizedBox();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning,
              color: Color(AppColors.warning),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.lowStockProducts,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(AppColors.warning).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(AppColors.warning).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _lowStockProducts.take(5).length; i++)
                _buildLowStockItem(_lowStockProducts[i], i == 0),
              if (_lowStockProducts.length > 5)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextButton(
                    onPressed: () => _navigateToScreen(
                      const ProductListScreen(showLowStockOnly: true),
                    ),
                    child: Text(
                      '${AppLocalizations.of(context)!.lowStockProducts}: ${_lowStockProducts.length}',
                      style: const TextStyle(
                        color: Color(AppColors.warning),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockItem(ProductDto product, bool isFirst) {
    return Container(
      margin: EdgeInsets.only(top: isFirst ? 0 : 1),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 12 : 0),
          topRight: Radius.circular(isFirst ? 12 : 0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(AppColors.warning).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory,
              color: Color(AppColors.warning),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                  '${AppLocalizations.of(context)!.stock}: ${product.stockQuantity} / ${AppLocalizations.of(context)!.minimum}: ${product.minimumStockLevel}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateToScreen(
              StockAdjustmentScreen(productId: product.id),
            ),
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(AppColors.primaryIndigo),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}