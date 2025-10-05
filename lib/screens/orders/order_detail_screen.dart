import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/orders_service.dart';
import '../../services/inventory_service.dart';
import '../../utils/constants.dart';
import 'order_operations_dialog.dart';
import '../warehouse/product_detail_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderDto order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderDto _order;
  List<OrderStatusHistoryDto> _orderHistory = [];
  bool _isLoading = false;
  Map<String, ProductDto> _productCache = {};
  Map<String, bool> _loadingProducts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _order = widget.order;
    print('OrderDetailScreen initialized with order: ${_order.id}');
    print('Order has ${_order.items.length} items');
    for (int i = 0; i < _order.items.length; i++) {
      print('Item $i: ${_order.items[i].productId} - ${_order.items[i].quantity}');
    }

    // If the order doesn't have items, fetch the full order details
    if (_order.items.isEmpty) {
      print('Order has no items, fetching full order details...');
      _loadFullOrderDetails();
    }

    _loadOrderHistory();
  }

  Future<void> _loadFullOrderDetails() async {
    try {
      setState(() => _isLoading = true);
      final fullOrder = await OrdersService.getOrder(_order.id);
      setState(() {
        _order = fullOrder;
        _isLoading = false;
      });
      print('Loaded full order with ${_order.items.length} items');
    } catch (e) {
      print('Error loading full order details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderHistory() async {
    setState(() => _isLoading = true);

    try {
      final history = await OrdersService.getOrderHistory(_order.id);
      setState(() {
        _orderHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingOrderHistory}: $e')),
        );
      }
    }
  }

  Future<ProductDto?> _getProductDetails(String productId) async {
    if (_productCache.containsKey(productId)) {
      return _productCache[productId];
    }

    if (_loadingProducts[productId] == true) {
      return null; // Already loading
    }

    try {
      _loadingProducts[productId] = true;
      final product = await InventoryService.getProduct(_order.companyId, productId);
      _productCache[productId] = product;
      if (mounted) setState(() {});
      return product;
    } catch (e) {
      print('Error fetching product details for $productId: $e');
      return null;
    } finally {
      _loadingProducts[productId] = false;
    }
  }

  String _getProductName(String productId) {
    final cachedProduct = _productCache[productId];
    if (cachedProduct != null) {
      return cachedProduct.name;
    }

    // Trigger async load if not already loading
    if (_loadingProducts[productId] != true) {
      _getProductDetails(productId);
    }

    // Return fallback name while loading
    final parts = productId.split('-');
    if (parts.isNotEmpty) {
      return 'Product ${parts.first}';
    }
    return 'Product $productId';
  }

  void _preloadProductDetails() {
    for (final item in _order.items) {
      _getProductDetails(item.productId);
    }
  }

  Future<void> _navigateToProductDetails(String productId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch product details
      final product = await InventoryService.getProduct(_order.companyId, productId);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to product details screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshOrder() async {
    try {
      final updatedOrder = await OrdersService.getOrder(_order.id);
      setState(() => _order = updatedOrder);
      _loadOrderHistory();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorRefreshingOrder}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_order.orderNumber),
        backgroundColor: const Color(AppColors.accentCyan),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshOrder,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              if (_order.canProcess)
                PopupMenuItem(
                  value: 'process',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow, color: Color(AppColors.info)),
                      SizedBox(width: 8),
                      Text(l10n.processOrder),
                    ],
                  ),
                ),
              if (_order.canShip)
                PopupMenuItem(
                  value: 'ship',
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping, color: Color(AppColors.success)),
                      SizedBox(width: 8),
                      Text(l10n.shipOrder),
                    ],
                  ),
                ),
              if (_order.canCancel)
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Color(AppColors.error)),
                      SizedBox(width: 8),
                      Text(l10n.cancelOrder),
                    ],
                  ),
                ),
              if (_order.status == OrderStatus.delivered)
                PopupMenuItem(
                  value: 'return',
                  child: Row(
                    children: [
                      Icon(Icons.keyboard_return, color: Color(AppColors.warning)),
                      SizedBox(width: 8),
                      Text(l10n.processReturnForOrder),
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
            Tab(text: l10n.details),
            Tab(text: l10n.items),
            Tab(text: l10n.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildItemsTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(),
          const SizedBox(height: 20),
          _buildCustomerInfo(),
          const SizedBox(height: 20),
          _buildShippingInfo(),
          const SizedBox(height: 20),
          _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(AppColors.borderLight)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.accentCyan).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Color(AppColors.accentCyan),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderInformation,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _order.orderNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(_order.status),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Color(AppColors.borderLight)),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.orderDate, _formatDate(_order.orderDate)),
            if (_order.dueDate != null)
              _buildInfoRow(l10n.dueDate, _formatDate(_order.dueDate!)),
            _buildInfoRow(l10n.totalItems, '${_order.totalItems}'),
            const SizedBox(height: 12),
            Divider(color: Color(AppColors.borderLight)),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.subtotal, '${_order.formattedSubTotalAmount}'),
            if (_order.discountAmount > 0)
              _buildInfoRow(l10n.discount, '-${_order.formattedDiscountAmount}'),
            _buildInfoRow(l10n.totalAmount, '${_order.formattedTotalAmount}', isBold: true),
            _buildInfoRow(l10n.paidAmount, '${_order.formattedPaidAmount}'),
            if (_order.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Divider(color: Color(AppColors.borderLight)),
              const SizedBox(height: 12),
              Text(
                l10n.notes,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _order.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(AppColors.textPrimary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(AppColors.borderLight)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.info).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(AppColors.info),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.customerInformation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _order.customerName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.textPrimary),
              ),
            ),
            if (_order.customer?.phone?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    color: Color(AppColors.textSecondary),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _order.customer!.phone!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
            if (_order.customer?.email?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.email,
                    color: Color(AppColors.textSecondary),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _order.customer!.email!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(AppColors.borderLight)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.accentCyan).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Color(AppColors.accentCyan),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.deliveryInformation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.deliveryType, _order.deliveryType.name.toUpperCase()),
            _buildInfoRow(l10n.deliveryStatus, _order.deliveryStatus.name.toUpperCase()),
            if (_order.deliveryPrice > 0)
              _buildInfoRow(l10n.deliveryPrice, _order.formattedDeliveryPrice),
            if (_order.deliveryAddress?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Divider(color: Color(AppColors.borderLight)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(AppColors.accentCyan),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _order.deliveryAddress!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(AppColors.textPrimary),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_order.parcelReceiverContactName?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildInfoRow(l10n.receiver, _order.parcelReceiverContactName!),
            ],
            if (_order.parcelReceiverPhone?.isNotEmpty == true)
              _buildInfoRow(l10n.receiverPhone, _order.parcelReceiverPhone!),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(AppColors.borderLight)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.success).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.summarize,
                    color: Color(AppColors.success),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.orderSummary,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    l10n.items,
                    '${_order.totalItems}',
                    Icons.shopping_cart,
                    const Color(AppColors.info),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    l10n.total,
                    '\$${_order.totalAmount.toStringAsFixed(2)}',
                    Icons.attach_money,
                    const Color(AppColors.success),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildItemsTab() {
    print('Building items tab with ${_order.items.length} items');
    final l10n = AppLocalizations.of(context)!;

    if (_order.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Color(AppColors.textHint),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noItemsFound,
              style: TextStyle(
                fontSize: 16,
                color: Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items count: ${_order.items.length}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(AppColors.textHint),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('Debug: Order ID: ${_order.id}');
                print('Debug: Items count: ${_order.items.length}');
                print('Debug: Items list: ${_order.items}');
                print('Debug: Full order JSON: ${_order.toJson()}');
              },
              child: Text(l10n.debugOrder),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _order.items.length,
      itemBuilder: (context, index) {
        final item = _order.items[index];
        return _buildOrderItem(item);
      },
    );
  }

  Widget _buildOrderItem(OrderItemDto item) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(AppColors.borderLight)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: InkWell(
        onTap: () => _navigateToProductDetails(item.productId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(AppColors.accentCyan).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory,
                  color: Color(AppColors.accentCyan),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getProductName(item.productId),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.info).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${l10n.quantity}: ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(AppColors.info),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '@${item.formattedUnitPrice}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.formattedTotalPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.accentCyan),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = AppLocalizations.of(context)!;

    if (_orderHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              l10n.noHistoryAvailable,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orderHistory.length,
      itemBuilder: (context, index) {
        final historyItem = _orderHistory[index];
        return _buildHistoryItem(historyItem, index == 0);
      },
    );
  }

  Widget _buildHistoryItem(OrderStatusHistoryDto historyItem, bool isLatest) {
    Color statusColor = isLatest ? const Color(AppColors.accentCyan) : const Color(AppColors.textSecondary);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              if (historyItem != _orderHistory.last)
                Container(
                  width: 2,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: Color(AppColors.borderLight),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isLatest ? statusColor : Color(AppColors.borderLight),
                  width: isLatest ? 2 : 1,
                ),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            historyItem.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(historyItem.changedAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(AppColors.textHint),
                          ),
                        ),
                      ],
                    ),
                    if (historyItem.changedBy != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.of(context)!.changedBy}: ${historyItem.changedBy}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppColors.textSecondary),
                        ),
                      ),
                    ],
                    if (historyItem.notes != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.backgroundLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          historyItem.notes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ],
                    if (historyItem.trackingNumber != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.info).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(AppColors.info).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_shipping,
                              size: 18,
                              color: Color(AppColors.info),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${AppLocalizations.of(context)!.tracking}: ${historyItem.trackingNumber}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppColors.info),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case OrderStatus.draft:
        backgroundColor = const Color(AppColors.textHint);
        break;
      case OrderStatus.pending:
        backgroundColor = const Color(AppColors.warning);
        break;
      case OrderStatus.confirmed:
        backgroundColor = const Color(AppColors.info);
        break;
      case OrderStatus.processing:
        backgroundColor = const Color(AppColors.primaryIndigo);
        break;
      case OrderStatus.ready:
        backgroundColor = const Color(AppColors.accentCyan);
        break;
      case OrderStatus.shipped:
        backgroundColor = const Color(AppColors.success);
        break;
      case OrderStatus.delivered:
        backgroundColor = const Color(AppColors.success);
        break;
      case OrderStatus.cancelled:
        backgroundColor = const Color(AppColors.error);
        break;
      case OrderStatus.returned:
        backgroundColor = const Color(AppColors.error);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget? _buildActionButton() {
    if (!_order.canProcess && !_order.canShip && !_order.canCancel) {
      return null;
    }
    final l10n = AppLocalizations.of(context)!;

    return FloatingActionButton.extended(
      onPressed: _showOrderOperations,
      backgroundColor: const Color(AppColors.accentCyan),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.settings),
      label: Text(l10n.actions),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Color(AppColors.textPrimary),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'process':
        await _processOrder();
        break;
      case 'ship':
        await _showShipOrderDialog();
        break;
      case 'cancel':
        await _showCancelOrderDialog();
        break;
      case 'return':
        await _showReturnOrderDialog();
        break;
    }
  }

  void _showOrderOperations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderOperationsDialog(
        order: _order,
        onOrderUpdated: (updatedOrder) {
          setState(() => _order = updatedOrder);
          _loadOrderHistory();
          Navigator.of(context).pop(true);
        },
      ),
    );
  }

  Future<void> _processOrder() async {
    try {
      final updatedOrder = await OrdersService.processOrder(_order.id);
      setState(() => _order = updatedOrder);
      _loadOrderHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.orderMovedToProcessing),
            backgroundColor: Color(AppColors.success),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorProcessingOrder}: $e')),
        );
      }
    }
  }

  Future<void> _showShipOrderDialog() async {
    // This will be implemented in the order operations dialog
    _showOrderOperations();
  }

  Future<void> _showCancelOrderDialog() async {
    // This will be implemented in the order operations dialog
    _showOrderOperations();
  }

  Future<void> _showReturnOrderDialog() async {
    // This will be implemented in the order operations dialog
    _showOrderOperations();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}