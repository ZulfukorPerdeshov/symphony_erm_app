import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../models/warehouse.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';
import '../../widgets/stock_operations_dialog.dart';
import '../../widgets/raw_material_operations_dialog.dart';

class WarehouseDetailsScreen extends StatefulWidget {
  final InventoryLocation warehouse;

  const WarehouseDetailsScreen({super.key, required this.warehouse});

  @override
  State<WarehouseDetailsScreen> createState() => _WarehouseDetailsScreenState();
}

class _WarehouseDetailsScreenState extends State<WarehouseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<StockItem> _stockItems = [];
  List<RawMaterialStockItem> _rawMaterials = [];
  List<InventoryLocation> _allWarehouses = [];
  bool _isLoadingStock = true;
  bool _isLoadingRawMaterials = true;
  String _stockSearchQuery = '';
  String _rawMaterialSearchQuery = '';
  final TextEditingController _stockSearchController = TextEditingController();
  final TextEditingController _rawMaterialSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stockSearchController.dispose();
    _rawMaterialSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadStockItems(),
      _loadRawMaterials(),
      _loadWarehouses(),
    ]);
  }

  Future<void> _loadWarehouses() async {
    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final warehouses = await InventoryService.getLocations(companyId);
      setState(() {
        _allWarehouses = warehouses;
      });
    } catch (e) {
      print('Error loading warehouses: $e');
    }
  }

  Future<void> _loadStockItems() async {
    setState(() => _isLoadingStock = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final stockItems = await InventoryService.getStockItemsByWarehouse(
        companyId,
        widget.warehouse.id,
      );

      setState(() {
        _stockItems = stockItems;
        _isLoadingStock = false;
      });
    } catch (e) {
      setState(() => _isLoadingStock = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingStockItems}: $e')),
        );
      }
    }
  }

  Future<void> _loadRawMaterials() async {
    setState(() => _isLoadingRawMaterials = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final rawMaterials = await InventoryService.getRawMaterialStockItems(
        companyId,
        warehouseId: widget.warehouse.id,
      );

      setState(() {
        _rawMaterials = rawMaterials;
        _isLoadingRawMaterials = false;
      });
    } catch (e) {
      setState(() => _isLoadingRawMaterials = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingRawMaterials}: $e')),
        );
      }
    }
  }

  List<StockItem> get _filteredStockItems {
    if (_stockSearchQuery.isEmpty) return _stockItems;

    return _stockItems.where((item) =>
      item.productName.toLowerCase().contains(_stockSearchQuery.toLowerCase()) ||
      item.sku.toLowerCase().contains(_stockSearchQuery.toLowerCase())
    ).toList();
  }

  List<RawMaterialStockItem> get _filteredRawMaterials {
    if (_rawMaterialSearchQuery.isEmpty) return _rawMaterials;

    return _rawMaterials.where((item) =>
      item.name.toLowerCase().contains(_rawMaterialSearchQuery.toLowerCase()) ||
      item.description.toLowerCase().contains(_rawMaterialSearchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warehouse.name),
        backgroundColor: const Color(AppColors.accentCyan),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l10n.stockItems, icon: Icon(Icons.inventory_2)),
            Tab(text: l10n.rawMaterials, icon: Icon(Icons.science)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Warehouse Info
          _buildWarehouseInfo(),

          // Tabs Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStockItemsTab(),
                _buildRawMaterialsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(AppColors.backgroundLight),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.warehouse.isActive
                      ? const Color(AppColors.accentCyan).withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warehouse,
                  color: widget.warehouse.isActive
                      ? Color(AppColors.accentCyan)
                      : Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.warehouse.type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.warehouse.isActive
                            ? const Color(AppColors.primaryIndigo)
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.warehouse.description.isNotEmpty)
                      Text(
                        widget.warehouse.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.warehouse.isActive
                      ? const Color(AppColors.success).withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.warehouse.isActive ? l10n.active : l10n.inactive,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.warehouse.isActive
                        ? const Color(AppColors.success)
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          if (widget.warehouse.address?.isNotEmpty == true ||
              widget.warehouse.phone?.isNotEmpty == true ||
              widget.warehouse.managerName?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.warehouse.address?.isNotEmpty == true) ...[
                  const Icon(Icons.location_on, size: 16, color: Color(AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.warehouse.address!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.textSecondary),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ],
            ),
            if (widget.warehouse.phone?.isNotEmpty == true ||
                widget.warehouse.managerName?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.warehouse.phone?.isNotEmpty == true) ...[
                    const Icon(Icons.phone, size: 16, color: Color(AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.warehouse.phone!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppColors.textSecondary),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.warehouse.managerName?.isNotEmpty == true)
                      const SizedBox(width: 16),
                  ],
                  if (widget.warehouse.managerName?.isNotEmpty == true) ...[
                    const Icon(Icons.person, size: 16, color: Color(AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${l10n.managerLabel}: ${widget.warehouse.managerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppColors.textSecondary),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStockItemsTab() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _stockSearchController,
            decoration: InputDecoration(
              hintText: l10n.searchStockItems,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _stockSearchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _stockSearchController.clear();
                        setState(() => _stockSearchQuery = '');
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => _stockSearchQuery = value);
            },
          ),
        ),

        // Stock Items List
        Expanded(
          child: _isLoadingStock
              ? const Center(child: CircularProgressIndicator())
              : _filteredStockItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _stockSearchQuery.isEmpty
                                ? l10n.noStockItemsFound
                                : l10n.noStockItemsMatchSearch,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStockItems,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredStockItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredStockItems[index];
                          return _buildStockItemCard(item);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildRawMaterialsTab() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _rawMaterialSearchController,
            decoration: InputDecoration(
              hintText: l10n.searchRawMaterials,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _rawMaterialSearchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _rawMaterialSearchController.clear();
                        setState(() => _rawMaterialSearchQuery = '');
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => _rawMaterialSearchQuery = value);
            },
          ),
        ),

        // Raw Materials List
        Expanded(
          child: _isLoadingRawMaterials
              ? const Center(child: CircularProgressIndicator())
              : _filteredRawMaterials.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.science,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _rawMaterialSearchQuery.isEmpty
                                ? l10n.noRawMaterialsFound
                                : l10n.noRawMaterialsMatchSearch,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRawMaterials,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredRawMaterials.length,
                        itemBuilder: (context, index) {
                          final item = _filteredRawMaterials[index];
                          return _buildRawMaterialCard(item);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildStockItemCard(StockItem item) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.sku.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${item.sku}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primaryIndigo),
                      ),
                    ),
                    Text(
                      l10n.total,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showStockOperationsDialog(item),
                  icon: const Icon(Icons.more_vert),
                  tooltip: l10n.stockOperations,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip('${l10n.available}: ${item.availableQuantity}', Colors.green),
                _buildInfoChip('${l10n.reserved}: ${item.reservedQuantity}', Colors.orange),
                _buildInfoChip('${l10n.total}: \$${item.totalValue.toStringAsFixed(2)}', Colors.blue),
              ],
            ),
            if (item.location?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Color(AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.location!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.textSecondary),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    l10n.adjust,
                    Icons.tune,
                    () => _showStockOperationsDialog(item),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    l10n.reserve,
                    Icons.lock,
                    () => _showStockOperationsDialog(item),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    l10n.transfer,
                    Icons.swap_horiz,
                    () => _showStockOperationsDialog(item),
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawMaterialCard(RawMaterialStockItem item) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.textSecondary),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primaryIndigo),
                      ),
                    ),
                    Text(
                      item.unit,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showRawMaterialOperationsDialog(item),
                  icon: const Icon(Icons.more_vert),
                  tooltip: l10n.rawMaterialOperations,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip('${l10n.available}: ${item.availableQuantity.toStringAsFixed(2)} ${item.unit}', Colors.green),
                _buildInfoChip('${l10n.reserved}: ${item.reservedQuantity.toStringAsFixed(2)} ${item.unit}', Colors.orange),
                _buildInfoChip('${l10n.total}: \$${item.totalValue.toStringAsFixed(2)}', Colors.blue),
                if (item.supplierName?.isNotEmpty == true)
                  _buildInfoChip('${l10n.supplier}: ${item.supplierName}', Colors.purple),
              ],
            ),
            if (item.expiryDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Color(AppColors.warning)),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.expires}: ${item.expiryDate!.day}/${item.expiryDate!.month}/${item.expiryDate!.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.warning),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    l10n.adjust,
                    Icons.tune,
                    () => _showRawMaterialOperationsDialog(item),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    l10n.reserve,
                    Icons.lock,
                    () => _showRawMaterialOperationsDialog(item),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    l10n.transfer,
                    Icons.swap_horiz,
                    () => _showRawMaterialOperationsDialog(item),
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockOperationsDialog(StockItem stockItem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StockOperationsDialog(
          stockItem: stockItem,
          warehouses: _allWarehouses,
          onSuccess: () {
            _loadStockItems();
          },
        ),
      ),
    );
  }

  void _showRawMaterialOperationsDialog(RawMaterialStockItem rawMaterial) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RawMaterialOperationsDialog(
          rawMaterial: rawMaterial,
          warehouses: _allWarehouses,
          onSuccess: () {
            _loadRawMaterials();
          },
        ),
      ),
    );
  }
}