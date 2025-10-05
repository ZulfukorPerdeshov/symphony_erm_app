import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';
import 'warehouse_details_screen.dart';

class WarehousesListScreen extends StatefulWidget {
  const WarehousesListScreen({super.key});

  @override
  State<WarehousesListScreen> createState() => _WarehousesListScreenState();
}

class _WarehousesListScreenState extends State<WarehousesListScreen> {
  List<InventoryLocation> _warehouses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWarehouses() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final warehouses = await InventoryService.getLocations(companyId);

      setState(() {
        _warehouses = warehouses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLoadingWarehouses}: $e')),
        );
      }
    }
  }

  List<InventoryLocation> get _filteredWarehouses {
    if (_searchQuery.isEmpty) return _warehouses;

    return _warehouses.where((warehouse) =>
      warehouse.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      warehouse.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      warehouse.type.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToWarehouseDetails(InventoryLocation warehouse) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WarehouseDetailsScreen(warehouse: warehouse),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.warehouses),
        backgroundColor: const Color(AppColors.accentCyan),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadWarehouses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchWarehouses,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(AppColors.primaryIndigo)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(AppColors.primaryIndigo), width: 2),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Warehouses List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWarehouses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warehouse,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? l10n.warehousesNotFound
                                  : l10n.noWarehousesMatchSearch,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _loadWarehouses,
                                child: Text(l10n.refresh),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWarehouses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredWarehouses.length,
                          itemBuilder: (context, index) {
                            final warehouse = _filteredWarehouses[index];
                            return _buildWarehouseCard(warehouse);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseCard(InventoryLocation warehouse) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToWarehouseDetails(warehouse),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: warehouse.isActive
                          ? const Color(AppColors.primaryIndigo).withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.warehouse,
                      color: warehouse.isActive
                          ? const Color(AppColors.primaryIndigo)
                          : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warehouse.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          warehouse.type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: warehouse.isActive
                                ? const Color(AppColors.primaryIndigo)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: warehouse.isActive
                              ? const Color(AppColors.success).withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          warehouse.isActive ? l10n.active : l10n.inactive,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: warehouse.isActive
                                ? const Color(AppColors.success)
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              if (warehouse.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  warehouse.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(AppColors.textSecondary),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (warehouse.address?.isNotEmpty == true || warehouse.managerName?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (warehouse.address?.isNotEmpty == true) ...[
                      const Icon(Icons.location_on, size: 14, color: Color(AppColors.textSecondary)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          warehouse.address!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.textSecondary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (warehouse.managerName?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Color(AppColors.textSecondary)),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.managerLabel}: ${warehouse.managerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}