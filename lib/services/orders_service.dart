import '../models/order.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'company_service.dart';

class OrdersService {
  static Future<List<OrderDto>> getOrders({
    String? companyId,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    OrderStatus? status,
    String? search,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Use provided companyId or get current company
    final currentCompanyId = companyId ?? CompanyService.getCurrentCompanyIdOrThrow();

    final queryParams = <String, dynamic>{
      'companyId': currentCompanyId,
      'page': page,
      'pageSize': pageSize,
    };

    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (customerId != null && customerId.isNotEmpty) {
      queryParams['customerId'] = customerId;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }

    final response = await ApiService.get<dynamic>(
      ApiConstants.orderServiceBaseUrl,
      ApiConstants.ordersEndpoint,
      queryParameters: queryParams,
    );
    
    // Handle paginated response format
    if (response is Map<String, dynamic> && response.containsKey('items')) {
      final items = response['items'] as List<dynamic>;
      return items.map((json) => OrderDto.fromJson(json)).toList();
    } else if (response is List<dynamic>) {
      // Fallback for direct array response
      return response.map((json) => OrderDto.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<OrderDto> getOrder(String orderId) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/$orderId',
    );

    return OrderDto.fromJson(response);
  }

  static Future<OrderDto> createOrder(CreateOrderRequest request, {String? companyId}) async {
    // Use provided companyId or get current company
    final currentCompanyId = companyId ?? CompanyService.getCurrentCompanyIdOrThrow();

    // Add companyId to the request if not already present
    final requestData = request.toJson();
    if (!requestData.containsKey('companyId')) {
      requestData['companyId'] = currentCompanyId;
    }

    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      ApiConstants.ordersEndpoint,
      data: requestData,
    );

    return OrderDto.fromJson(response);
  }

  static Future<OrderDto> updateOrderStatus(
    String orderId,
    UpdateOrderStatusRequest request,
  ) async {
    final response = await ApiService.put<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/$orderId/status',
      data: request.toJson(),
    );

    return OrderDto.fromJson(response);
  }

  // Specific order operations
  static Future<OrderDto> confirmOrder(String orderId, {String? notes}) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/$orderId/confirm',
      data: notes != null ? {'notes': notes} : null,
    );

    return OrderDto.fromJson(response);
  }

  static Future<OrderDto> processOrder(String orderId, {String? notes}) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/$orderId/process',
      data: notes != null ? {'notes': notes} : null,
    );

    return OrderDto.fromJson(response);
  }

  static Future<OrderDto> markOrderReady(String orderId, {String? notes}) async {
    final request = UpdateOrderStatusRequest(
      status: OrderStatus.ready,
      notes: notes,
    );

    return updateOrderStatus(orderId, request);
  }

  static Future<OrderDto> shipOrder(
    String orderId, {
    String? trackingNumber,
    String? notes,
  }) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/$orderId/ship',
      data: {
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (notes != null) 'notes': notes,
      },
    );

    return OrderDto.fromJson(response);
  }

  static Future<OrderDto> cancelOrder(
    String orderId, {
    required String reason,
    String? notes,
  }) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/$orderId/cancel',
      data: {
        'reason': reason,
        if (notes != null) 'notes': notes,
      },
    );

    return OrderDto.fromJson(response);
  }

  static Future<OrderDto> returnOrder(
    String orderId, {
    required String reason,
    String? notes,
  }) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/$orderId/return',
      data: {
        'reason': reason,
        if (notes != null) 'notes': notes,
      },
    );

    return OrderDto.fromJson(response);
  }

  static Future<OrderDto> markOrderDelivered(
    String orderId, {
    String? notes,
  }) async {
    final request = UpdateOrderStatusRequest(
      status: OrderStatus.delivered,
      notes: notes,
    );

    return updateOrderStatus(orderId, request);
  }

  // Statistics and analytics
  static Future<OrderSummary> getOrderSummary({
    String? companyId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Use provided companyId or get current company
    final currentCompanyId = companyId ?? CompanyService.getCurrentCompanyIdOrThrow();

    final queryParams = <String, dynamic>{
      'companyId': currentCompanyId,
    };

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }

    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/summary',
      queryParameters: queryParams,
    );

    return OrderSummary.fromJson(response);
  }

  static Future<List<OrderDto>> getPendingOrders() async {
    return getOrders(status: OrderStatus.pending);
  }

  static Future<List<OrderDto>> getProcessingOrders() async {
    return getOrders(status: OrderStatus.processing);
  }

  static Future<List<OrderDto>> getReadyOrders() async {
    return getOrders(status: OrderStatus.ready);
  }

  static Future<List<OrderDto>> getShippedOrders() async {
    return getOrders(status: OrderStatus.shipped);
  }

  static Future<List<OrderDto>> getTodaysOrders() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return getOrders(fromDate: startOfDay, toDate: endOfDay);
  }

  static Future<List<OrderDto>> searchOrders(String query) async {
    return getOrders(search: query);
  }

  static Future<List<OrderDto>> getCustomerOrders(String customerId) async {
    return getOrders(customerId: customerId);
  }

  // Order history and tracking
  static Future<List<OrderStatusHistoryDto>> getOrderHistory(String orderId) async {
    final response = await ApiService.get<dynamic>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/$orderId/history',
    );

    // Handle paginated response format
    if (response is Map<String, dynamic> && response.containsKey('items')) {
      final items = response['items'] as List<dynamic>;
      return items.map((json) => OrderStatusHistoryDto.fromJson(json)).toList();
    } else if (response is List<dynamic>) {
      // Fallback for direct array response
      return response.map((json) => OrderStatusHistoryDto.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  // Bulk operations
  static Future<void> bulkUpdateOrderStatus(
    List<String> orderIds,
    OrderStatus status, {
    String? notes,
  }) async {
    await ApiService.post<void>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/bulk-status-update',
      data: {
        'orderIds': orderIds,
        'status': status.name,
        if (notes != null) 'notes': notes,
      },
    );
  }

  static Future<List<OrderDto>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return getOrders(fromDate: startDate, toDate: endDate);
  }

  // Priority orders
  static Future<List<OrderDto>> getUrgentOrders({String? companyId}) async {
    // Use provided companyId or get current company
    final currentCompanyId = companyId ?? CompanyService.getCurrentCompanyIdOrThrow();

    final response = await ApiService.get<dynamic>(
      ApiConstants.orderServiceBaseUrl,
      '${ApiConstants.ordersEndpoint}/urgent',
      queryParameters: {'companyId': currentCompanyId},
    );

    // Handle paginated response format
    if (response is Map<String, dynamic> && response.containsKey('items')) {
      final items = response['items'] as List<dynamic>;
      return items.map((json) => OrderDto.fromJson(json)).toList();
    } else if (response is List<dynamic>) {
      // Fallback for direct array response
      return response.map((json) => OrderDto.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  // Order validation
  static Future<bool> canProcessOrder(String orderId) async {
    try {
      final order = await getOrder(orderId);
      return order.canProcess;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> canShipOrder(String orderId) async {
    try {
      final order = await getOrder(orderId);
      return order.canShip;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> canCancelOrder(String orderId) async {
    try {
      final order = await getOrder(orderId);
      return order.canCancel;
    } catch (e) {
      return false;
    }
  }
}