import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/orders_service.dart';
import '../../utils/constants.dart';
import 'orders_screen.dart';
import 'order_detail_screen.dart';

class OrdersDashboardScreen extends StatefulWidget {
  const OrdersDashboardScreen({super.key});

  @override
  State<OrdersDashboardScreen> createState() => _OrdersDashboardScreenState();
}

class _OrdersDashboardScreenState extends State<OrdersDashboardScreen> {
  OrderSummary? _orderSummary;
  List<OrderDto> _pendingOrders = [];
  List<OrderDto> _urgentOrders = [];
  List<OrderDto> _todaysOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load each section separately to handle individual failures
      final List<Future> futures = [
        _loadOrderSummary(),
        _loadPendingOrders(),
        _loadUrgentOrders(),
        _loadTodaysOrders(),
      ];

      await Future.wait(futures);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadDashboardData,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadOrderSummary() async {
    try {
      print('Loading order summary from API...');
      final summary = await OrdersService.getOrderSummary();
      print('Order summary loaded successfully: ${summary.totalOrders} orders');
      setState(() {
        _orderSummary = summary;
      });
    } catch (e) {
      print('Error loading order summary: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Using offline mode - Order summary unavailable'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      // Create default summary if API fails
      setState(() {
        _orderSummary = OrderSummary(
          totalOrders: 0,
          totalRevenue: 0,
          pendingOrders: 0,
          processingOrders: 0,
          shippedOrders: 0,
          deliveredOrders: 0,
        );
      });
    }
  }

  Future<void> _loadPendingOrders() async {
    try {
      print('Loading pending orders from API...');
      final orders = await OrdersService.getPendingOrders();
      print('Pending orders loaded: ${orders.length} orders');
      setState(() {
        _pendingOrders = orders.take(5).toList();
      });
    } catch (e) {
      print('Error loading pending orders: $e');
      setState(() {
        _pendingOrders = [];
      });
    }
  }

  Future<void> _loadUrgentOrders() async {
    try {
      print('Loading urgent orders from API...');
      final orders = await OrdersService.getUrgentOrders();
      print('Urgent orders loaded: ${orders.length} orders');
      setState(() {
        _urgentOrders = orders.take(5).toList();
      });
    } catch (e) {
      print('Error loading urgent orders: $e');
      setState(() {
        _urgentOrders = [];
      });
    }
  }

  Future<void> _loadTodaysOrders() async {
    try {
      print('Loading today\'s orders from API...');
      final orders = await OrdersService.getTodaysOrders();
      print('Today\'s orders loaded: ${orders.length} orders');
      setState(() {
        _todaysOrders = orders.take(5).toList();
      });
    } catch (e) {
      print('Error loading today\'s orders: $e');
      setState(() {
        _todaysOrders = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Dashboard'),
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
                    _buildSummaryCards(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildPendingOrders(),
                    const SizedBox(height: 20),
                    _buildUrgentOrders(),
                    const SizedBox(height: 20),
                    _buildTodaysOrders(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    if (_orderSummary == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Overview',
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
              child: _buildSummaryCard(
                'Total Orders',
                _orderSummary!.totalOrders.toString(),
                Icons.receipt_long,
                const Color(AppColors.info),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Revenue',
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
              child: _buildSummaryCard(
                'Pending',
                _orderSummary!.pendingOrders.toString(),
                Icons.pending,
                const Color(AppColors.warning),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Processing',
                _orderSummary!.processingOrders.toString(),
                Icons.settings,
                const Color(AppColors.primaryIndigo),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Shipped',
                _orderSummary!.shippedOrders.toString(),
                Icons.local_shipping,
                const Color(AppColors.accentCyan),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Delivered',
                _orderSummary!.deliveredOrders.toString(),
                Icons.done_all,
                const Color(AppColors.success),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
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
              'All Orders',
              Icons.receipt_long,
              const Color(AppColors.primaryIndigo),
              () => _navigateToOrders(),
            ),
            _buildActionCard(
              'Pending Orders',
              Icons.pending,
              const Color(AppColors.warning),
              () => _navigateToOrders(status: OrderStatus.pending),
            ),
            _buildActionCard(
              'Ready to Ship',
              Icons.local_shipping,
              const Color(AppColors.accentCyan),
              () => _navigateToOrders(status: OrderStatus.ready),
            ),
            _buildActionCard(
              'Search Orders',
              Icons.search,
              const Color(AppColors.info),
              () => _navigateToOrders(focusSearch: true),
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

  Widget _buildPendingOrders() {
    return _buildOrderSection(
      'Pending Orders',
      _pendingOrders,
      const Color(AppColors.warning),
      () => _navigateToOrders(status: OrderStatus.pending),
    );
  }

  Widget _buildUrgentOrders() {
    return _buildOrderSection(
      'Urgent Orders',
      _urgentOrders,
      const Color(AppColors.error),
      () => _navigateToOrders(), // In real app, this would filter urgent orders
    );
  }

  Widget _buildTodaysOrders() {
    return _buildOrderSection(
      'Today\'s Orders',
      _todaysOrders,
      const Color(AppColors.info),
      () => _navigateToOrders(), // In real app, this would filter today's orders
    );
  }

  Widget _buildOrderSection(
    String title,
    List<OrderDto> orders,
    Color color,
    VoidCallback onViewAll,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getIconForSection(title),
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            if (orders.isNotEmpty)
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View All',
                  style: TextStyle(color: color),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  _getIconForSection(title),
                  color: color.withValues(alpha: 0.5),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No ${title.toLowerCase()} found',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: orders.map((order) => _buildOrderSummaryCard(order)).toList(),
          ),
      ],
    );
  }

  Widget _buildOrderSummaryCard(OrderDto order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status).withValues(alpha: 0.1),
          child: Icon(
            Icons.receipt_long,
            color: _getStatusColor(order.status),
            size: 20,
          ),
        ),
        title: Text(
          order.orderNumber,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(AppColors.textPrimary),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.customerName,
              style: const TextStyle(
                color: Color(AppColors.textSecondary),
              ),
            ),
            Text(
              '${order.formattedTotalAmount} • ${order.totalItems} items',
              style: const TextStyle(
                fontSize: 12,
                color: Color(AppColors.textHint),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            order.status.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        onTap: () => _navigateToOrderDetail(order),
      ),
    );
  }

  IconData _getIconForSection(String title) {
    switch (title) {
      case 'Pending Orders':
        return Icons.pending;
      case 'Urgent Orders':
        return Icons.priority_high;
      case 'Today\'s Orders':
        return Icons.today;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return const Color(AppColors.textHint);
      case OrderStatus.pending:
        return const Color(AppColors.warning);
      case OrderStatus.confirmed:
        return const Color(AppColors.info);
      case OrderStatus.processing:
        return const Color(AppColors.primaryIndigo);
      case OrderStatus.ready:
        return const Color(AppColors.accentCyan);
      case OrderStatus.shipped:
        return const Color(AppColors.success);
      case OrderStatus.delivered:
        return const Color(AppColors.success);
      case OrderStatus.cancelled:
        return const Color(AppColors.error);
      case OrderStatus.returned:
        return const Color(AppColors.error);
    }
  }

  void _navigateToOrders({OrderStatus? status, bool focusSearch = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrdersScreen(),
      ),
    );
  }

  void _navigateToOrderDetail(OrderDto order) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );

    if (result == true) {
      _loadDashboardData();
    }
  }
}