import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../services/orders_service.dart';
import '../../utils/constants.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<OrderDto> _orders = [];
  OrderSummary? _orderSummary;
  OrderStatus? _selectedStatus;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  String _searchQuery = '';

  final List<OrderStatus> _statusTabs = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.ready,
    OrderStatus.shipped,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length + 1, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedStatus = _tabController.index == 0 ? null : _statusTabs[_tabController.index - 1];
      });
      _loadOrders(refresh: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      await _loadOrders(refresh: true);
      // Load order summary
      try {
        _orderSummary = await OrdersService.getOrderSummary();
      } catch (e) {
        print('Error loading order summary: $e');
        // Continue loading orders even if summary fails
      }

      setState(() {
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

  Future<List<OrderDto>> _loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _orders.clear();
    }

    if (!_hasMoreData) return _orders;

    try {
      final orders = await OrdersService.getOrders(
        page: _currentPage + 1, // Convert 0-based to 1-based pagination
        pageSize: AppConstants.defaultPageSize,
        status: _selectedStatus,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (refresh) {
        setState(() {
          _orders = orders;
          _currentPage++;
          _hasMoreData = orders.length == AppConstants.defaultPageSize;
        });
      } else {
        setState(() {
          _orders.addAll(orders);
          _currentPage++;
          _hasMoreData = orders.length == AppConstants.defaultPageSize;
        });
      }

      return _orders;
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingOrders}: $e')),
        );
      }
      return _orders;
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);
    await _loadOrders();
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
      _loadOrders(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        backgroundColor: const Color(AppColors.accentCyan),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: l10n.all),
            ..._statusTabs.map((status) => Tab(text: _getStatusDisplayName(status))),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadOrders(refresh: true),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildOrdersList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    if (_orderSummary == null) return const SizedBox();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.orderSummary,
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
                l10n.total,
                _orderSummary!.totalOrders.toString(),
                Icons.receipt_long,
                const Color(AppColors.info),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.revenue,
                '\$${_orderSummary!.totalRevenue.toStringAsFixed(0)}',
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
                l10n.pending,
                _orderSummary!.pendingOrders.toString(),
                Icons.pending,
                const Color(AppColors.warning),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.shipped,
                (_orderSummary!.totalOrders - _orderSummary!.pendingOrders - _orderSummary!.processingOrders).toString(),
                Icons.local_shipping,
                const Color(AppColors.accentCyan),
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

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.search,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.searchByOrderNumberOrCustomer,
            prefixIcon: const Icon(Icons.search, color: Color(AppColors.textSecondary)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(AppColors.borderLight)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(AppColors.borderLight)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(AppColors.accentCyan), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    final l10n = AppLocalizations.of(context)!;

    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: Color(AppColors.textHint),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noOrdersFound,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.orders,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orders.length + (_hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _orders.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final order = _orders[index];
            return _buildOrderCard(order);
          },
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderDto order) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(AppColors.borderLight)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
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
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppColors.backgroundLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 16,
                      color: Color(AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${order.totalItems} ${l10n.items}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatDate(order.orderDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(AppColors.textSecondary),
                        ),
                      ),
                    ),
                    Text(
                      '${order.formattedTotalAmount}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.accentCyan),
                      ),
                    ),
                  ],
                ),
              ),
              if (order.canProcess || order.canShip) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (order.canProcess)
                      Expanded(
                        child: _buildQuickActionButton(
                          l10n.processOrder,
                          Icons.play_arrow,
                          const Color(AppColors.info),
                          () => _quickProcessOrder(order),
                        ),
                      ),
                    if (order.canProcess && order.canShip)
                      const SizedBox(width: 8),
                    if (order.canShip)
                      Expanded(
                        child: _buildQuickActionButton(
                          l10n.ship,
                          Icons.local_shipping,
                          const Color(AppColors.success),
                          () => _quickShipOrder(order),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickProcessOrder(OrderDto order) async {
    try {
      await OrdersService.processOrder(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.orderMovedToProcessing),
            backgroundColor: Color(AppColors.success),
          ),
        );
        _loadOrders(refresh: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorProcessingOrder}: $e')),
        );
      }
    }
  }

  Future<void> _quickShipOrder(OrderDto order) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _TrackingNumberDialog(),
    );

    if (result != null) {
      try {
        await OrdersService.shipOrder(order.id, trackingNumber: result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.orderShippedSuccessfully),
              backgroundColor: Color(AppColors.success),
            ),
          );
          _loadOrders(refresh: true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.errorShippingOrder}: $e')),
          );
        }
      }
    }
  }

  void _navigateToOrderDetail(OrderDto order) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );

    if (result == true) {
      _loadOrders(refresh: true);
      _loadInitialData();
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case OrderStatus.draft:
        return l10n.draft;
      case OrderStatus.pending:
        return l10n.pending;
      case OrderStatus.confirmed:
        return l10n.confirmed;
      case OrderStatus.processing:
        return l10n.processing;
      case OrderStatus.ready:
        return l10n.ready;
      case OrderStatus.shipped:
        return l10n.shipped;
      case OrderStatus.delivered:
        return l10n.delivered;
      case OrderStatus.cancelled:
        return l10n.cancelled;
      case OrderStatus.returned:
        return l10n.returned;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _TrackingNumberDialog extends StatefulWidget {
  @override
  _TrackingNumberDialogState createState() => _TrackingNumberDialogState();
}

class _TrackingNumberDialogState extends State<_TrackingNumberDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.shipOrder),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.enterTrackingNumberOptional),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: l10n.trackingNumber,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.ship),
        ),
      ],
    );
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