import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/inventory_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  final bool showLowStockOnly;

  const ProductListScreen({super.key, this.showLowStockOnly = false});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<ProductDto> _products = [];
  List<ProductCategory> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final results = await Future.wait([
        _loadProducts(refresh: true),
        InventoryService.getCategories(companyId),
      ]);

      setState(() {
        _categories = results[1] as List<ProductCategory>;
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

  Future<List<ProductDto>> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _products.clear();
    }

    if (!_hasMoreData) return _products;

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final products = await InventoryService.getProducts(
        companyId: companyId,
        skip: _currentPage * AppConstants.defaultPageSize,
        take: AppConstants.defaultPageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        category: _selectedCategory,
        lowStockOnly: widget.showLowStockOnly,
      );

      if (refresh) {
        setState(() {
          _products = products;
          _currentPage++;
          _hasMoreData = products.length == AppConstants.defaultPageSize;
        });
      } else {
        setState(() {
          _products.addAll(products);
          _currentPage++;
          _hasMoreData = products.length == AppConstants.defaultPageSize;
        });
      }

      return _products;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingProducts}: $e')),
        );
      }
      return _products;
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);
    await _loadProducts();
    setState(() => _isLoadingMore = false);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _debounceSearch();
  }

  Timer? _debounceTimer;
  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadProducts(refresh: true);
    });
  }

  void _onCategoryChanged(String? category) {
    setState(() => _selectedCategory = category);
    _loadProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showLowStockOnly ? AppLocalizations.of(context)!.lowStockProducts : AppLocalizations.of(context)!.products),
        backgroundColor: const Color(AppColors.primaryIndigo),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _navigateToAddProduct(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(AppColors.backgroundLight),
        border: Border(
          bottom: BorderSide(color: Color(AppColors.textHint), width: 0.5),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchProducts,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: Text(AppLocalizations.of(context)!.allCategories),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(AppLocalizations.of(context)!.allCategories),
              ),
              ..._categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.name,
                  child: Text('${category.name} (${category.productCount})'),
                );
              }),
            ],
            onChanged: _onCategoryChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.showLowStockOnly
                  ? AppLocalizations.of(context)!.noLowStockProductsFound
                  : AppLocalizations.of(context)!.noProductsFound,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (!widget.showLowStockOnly) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _navigateToAddProduct(),
                child: Text(AppLocalizations.of(context)!.addFirstProduct),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProducts(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _products.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductDto product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToProductDetail(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildProductImage(product),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.sku}: ${product.sku}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.category}: ${product.category}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStockStatusChip(product),
                        const Spacer(),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.primaryIndigo),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductDto product) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(AppColors.backgroundLight),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(AppColors.textHint).withValues(alpha: 0.3),
        ),
      ),
      child: product.mainImageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.mainImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.inventory,
                    color: Color(AppColors.textHint),
                  );
                },
              ),
            )
          : const Icon(
              Icons.inventory,
              color: Color(AppColors.textHint),
            ),
    );
  }

  Widget _buildStockStatusChip(ProductDto product) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (product.isOutOfStock) {
      backgroundColor = const Color(AppColors.error);
      textColor = Colors.white;
      text = AppLocalizations.of(context)!.outOfStock;
    } else if (product.isLowStock) {
      backgroundColor = const Color(AppColors.warning);
      textColor = Colors.white;
      text = '${AppLocalizations.of(context)!.lowStock} (${product.stockQuantity})';
    } else {
      backgroundColor = const Color(AppColors.success);
      textColor = Colors.white;
      text = '${AppLocalizations.of(context)!.inStock} (${product.stockQuantity})';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _navigateToProductDetail(ProductDto product) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );

    if (result == true) {
      _loadProducts(refresh: true);
    }
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );

    if (result == true) {
      _loadProducts(refresh: true);
    }
  }
}

class Timer {
  final Duration duration;
  final VoidCallback callback;

  Timer(this.duration, this.callback) {
    Future.delayed(duration, callback);
  }

  void cancel() {
    // In a real implementation, this would cancel the timer
  }
}