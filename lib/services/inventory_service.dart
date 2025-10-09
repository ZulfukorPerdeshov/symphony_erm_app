import 'package:dio/dio.dart';
import '../models/product.dart';
import '../models/warehouse.dart';
import '../models/production.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class InventoryService {
  static Future<List<ProductDto>> getProducts({
    required String companyId,
    int skip = 0,
    int take = AppConstants.defaultPageSize,
    String? search,
    String? category,
    bool? lowStockOnly,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (lowStockOnly == true) {
      queryParams['lowStockOnly'] = true;
    }

    final response = await ApiService.get<List<dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.productsEndpoint(companyId),
      queryParameters: queryParams,
    );

    return response.map((json) => ProductDto.fromJson(json)).toList();
  }

  static Future<ProductDto> getProduct(String companyId, String productId) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.productsEndpoint(companyId)}/$productId',
    );

    return ProductDto.fromJson(response);
  }

  static Future<ProductDto> createProduct(String companyId, CreateProductRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.productsEndpoint(companyId),
      data: request.toJson(),
    );

    return ProductDto.fromJson(response);
  }

  static Future<ProductDto> updateProduct(
    String companyId,
    String productId,
    UpdateProductRequest request,
  ) async {
    final response = await ApiService.put<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.productsEndpoint(companyId)}/$productId',
      data: request.toJson(),
    );

    return ProductDto.fromJson(response);
  }

  static Future<void> deleteProduct(String companyId, String productId) async {
    await ApiService.delete<void>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.productsEndpoint(companyId)}/$productId',
    );
  }

  static Future<void> adjustStock(String companyId, StockAdjustmentRequest request) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryTransactionAdjustmentEndpoint(companyId), // Using correct inventory transaction endpoint
      data: request.toJson(),
    );
  }

  static Future<void> transferStock(String companyId, StockTransferRequest request) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryTransactionMoveEndpoint(companyId), // Using correct inventory transaction move endpoint
      data: request.toJson(),
    );
  }

  static Future<List<StockMovementDto>> getStockMovements({
    required String companyId,
    String? productId,
    int skip = 0,
    int take = AppConstants.defaultPageSize,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (productId != null) {
      queryParams['productId'] = productId;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }

    final response = await ApiService.get<List<dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryTransactionHistoryEndpoint(companyId), // Using correct inventory transaction history endpoint
      queryParameters: queryParams,
    );

    return response.map((json) => StockMovementDto.fromJson(json)).toList();
  }

  static Future<List<ProductCategory>> getCategories(String companyId) async {
    try {
      final response = await ApiService.get<List<dynamic>>(
        ApiConstants.inventoryServiceBaseUrl,
        ApiConstants.categoriesEndpoint, // Categories are NOT company-scoped
      );

      return response.map((json) => ProductCategory.fromJson(json)).toList();
    } catch (e) {
      print('Categories endpoint not available: $e');
      // Return empty list if categories endpoint doesn't exist
      return [];
    }
  }

  static Future<List<ProductDto>> getLowStockProducts(String companyId) async {
    return getProducts(companyId: companyId, lowStockOnly: true);
  }

  static Future<Map<String, dynamic>> getInventoryStats(String companyId) async {
    try {
      // Use warehouse summary endpoint for inventory statistics
      final response = await ApiService.get<Map<String, dynamic>>(
        ApiConstants.inventoryServiceBaseUrl,
        ApiConstants.inventoryWarehouseSummaryEndpoint(companyId),
      );

      return response;
    } catch (e) {
      print('Inventory stats endpoint not available: $e');
      // Return fallback stats if endpoint doesn't exist
      return {
        'totalProducts': 0,
        'lowStockCount': 0,
        'outOfStockCount': 0,
        'totalValue': 0.0,
      };
    }
  }

  static Future<List<ProductDto>> searchProducts(String companyId, String query) async {
    return getProducts(companyId: companyId, search: query);
  }

  static Future<void> bulkUpdateStock(String companyId, List<BulkStockUpdateRequest> requests) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryBulkUpdateEndpoint(companyId),
      data: requests.map((r) => r.toJson()).toList(),
    );
  }

  // Stock Transfer Operations
  static Future<List<StockTransferDto>> getStockTransfers({
    required String companyId,
    int skip = 0,
    int take = AppConstants.defaultPageSize,
    TransferStatus? status,
    String? productId,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (productId != null) {
      queryParams['productId'] = productId;
    }

    final response = await ApiService.get<List<dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryTransactionsEndpoint(companyId), // Using general inventory transactions
      queryParameters: queryParams,
    );

    return response.map((json) => StockTransferDto.fromJson(json)).toList();
  }

  static Future<StockTransferDto> getStockTransfer(String companyId, String transferId) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.inventoryTransactionsEndpoint(companyId)}/$transferId',
    );

    return StockTransferDto.fromJson(response);
  }

  static Future<void> completeStockTransfer(String companyId, String transferId) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.inventoryTransactionsEndpoint(companyId)}/$transferId/complete',
    );
  }

  static Future<void> cancelStockTransfer(String companyId, String transferId, String reason) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.inventoryTransactionsEndpoint(companyId)}/$transferId/cancel',
      data: {'reason': reason},
    );
  }

  // Warehouse Management (renamed from Location to match API docs)
  static Future<List<InventoryLocation>> getLocations(String companyId) async {
    try {
      final response = await ApiService.get<List<dynamic>>(
        ApiConstants.inventoryServiceBaseUrl,
        ApiConstants.warehousesEndpoint(companyId), // Using correct warehouses endpoint
      );

      return response.map((json) => InventoryLocation.fromJson(json)).toList();
    } catch (e) {
      print('Warehouses endpoint not available: $e');
      // Return empty list if warehouses endpoint doesn't exist
      return [];
    }
  }

  static Future<InventoryLocation> getLocation(String companyId, String locationId) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.warehouseByIdEndpoint(companyId, locationId), // Using correct warehouse by ID endpoint
    );

    return InventoryLocation.fromJson(response);
  }

  // Stock Taking Operations
  static Future<StockTakingDto> createStockTaking(String companyId, StockTakingRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryStockTakingEndpoint(companyId),
      data: request.toJson(),
    );

    return StockTakingDto.fromJson(response);
  }

  static Future<List<StockTakingDto>> getStockTakings({
    required String companyId,
    int skip = 0,
    int take = AppConstants.defaultPageSize,
    StockTakingStatus? status,
    String? locationId,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (locationId != null) {
      queryParams['locationId'] = locationId;
    }

    final response = await ApiService.get<List<dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryStockTakingEndpoint(companyId),
      queryParameters: queryParams,
    );

    return response.map((json) => StockTakingDto.fromJson(json)).toList();
  }

  static Future<StockTakingDto> getStockTaking(String companyId, String stockTakingId) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.inventoryStockTakingEndpoint(companyId)}/$stockTakingId',
    );

    return StockTakingDto.fromJson(response);
  }

  static Future<void> completeStockTaking(String companyId, String stockTakingId) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.inventoryStockTakingEndpoint(companyId)}/$stockTakingId/complete',
    );
  }

  static Future<void> cancelStockTaking(String companyId, String stockTakingId, String reason) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.inventoryStockTakingEndpoint(companyId)}/$stockTakingId/cancel',
      data: {'reason': reason},
    );
  }

  // Product Stock Levels by Location
  // static Future<Map<String, int>> getProductStockByLocation(String companyId, String productId) async {
  //   final response = await ApiService.get<Map<String, dynamic>>(
  //     ApiConstants.inventoryServiceBaseUrl,
  //     '${ApiConstants.productsEndpoint(companyId)}/$productId/stock-by-location',
  //   );

  //   return Map<String, int>.from(response);
  // }

  // Inventory Alerts
  static Future<List<ProductDto>> getExpiringProducts({
    required String companyId,
    int daysAhead = 30,
  }) async {
    final response = await ApiService.get<List<dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryExpiringEndpoint(companyId),
      queryParameters: {'daysAhead': daysAhead},
    );

    return response.map((json) => ProductDto.fromJson(json)).toList();
  }

  static Future<List<ProductDto>> getOverstockedProducts(String companyId) async {
    final response = await ApiService.get<List<dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.inventoryOverstockedEndpoint(companyId),
    );

    return response.map((json) => ProductDto.fromJson(json)).toList();
  }

  // Raw Material Stock Items Operations
  static Future<List<RawMaterialStockItem>> getRawMaterialStockItems(
    String companyId, {
    int skip = 0,
    int take = AppConstants.defaultPageSize,
    String? search,
    String? warehouseId,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (warehouseId != null && warehouseId.isNotEmpty) {
      queryParams['warehouseId'] = warehouseId;
    }

    try {
      final response = await ApiService.get<List<dynamic>>(
        ApiConstants.inventoryServiceBaseUrl,
        ApiConstants.rawMaterialStockItemsEndpoint(companyId),
        queryParameters: queryParams,
      );

      return response.map((json) => RawMaterialStockItem.fromJson(json)).toList();
    } catch (e) {
      print('Raw material stock items endpoint error: $e');
      return [];
    }
  }

  static Future<void> adjustRawMaterialStock(
    String companyId,
    RawMaterialAdjustRequest request,
  ) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.rawMaterialStockItemAdjustEndpoint(companyId),
      data: request.toJson(),
    );
  }

  static Future<void> reserveRawMaterial(
    String companyId,
    RawMaterialReserveRequest request,
  ) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.rawMaterialStockItemReserveEndpoint(companyId),
      data: request.toJson(),
    );
  }

  // Stock Items Operations - Full CRUD and Advanced Operations

  // Get all stock items by warehouse (using GET /stock-items/{warehouseId})
  static Future<List<StockItem>> getStockItemsByWarehouse(
    String companyId,
    String warehouseId,
  ) async {
    try {
      final response = await ApiService.get<List<dynamic>>(
        ApiConstants.inventoryServiceBaseUrl,
        ApiConstants.stockItemsByWarehouseEndpoint(companyId, warehouseId),
      );

      return response.map((json) => StockItem.fromJson(json)).toList();
    } catch (e) {
      print('Stock items by warehouse endpoint error: $e');
      return [];
    }
  }

  // Get a specific stock item by ID
  static Future<StockItem> getStockItemById(
    String companyId,
    String stockItemId,
  ) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemByIdEndpoint(companyId, stockItemId),
    );

    return StockItem.fromJson(response);
  }

  // Create a new stock item
  static Future<StockItem> createStockItem(
    String companyId,
    CreateStockItemRequest request,
  ) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemsEndpoint(companyId),
      data: request.toJson(),
    );

    return StockItem.fromJson(response);
  }

  // Update a stock item
  static Future<StockItem> updateStockItem(
    String companyId,
    String stockItemId,
    UpdateStockItemRequest request,
  ) async {
    final response = await ApiService.put<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemByIdEndpoint(companyId, stockItemId),
      data: request.toJson(),
    );

    return StockItem.fromJson(response);
  }

  // Delete a stock item
  static Future<void> deleteStockItem(
    String companyId,
    String stockItemId,
  ) async {
    await ApiService.delete<void>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemByIdEndpoint(companyId, stockItemId),
    );
  }

  // Search stock items with filters
  static Future<StockItemSearchResult> searchStockItems(
    String companyId,
    StockItemSearchRequest request,
  ) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemSearchEndpoint(companyId),
      data: request.toJson(),
    );

    return StockItemSearchResult.fromJson(response);
  }

  // Get all stock items for a specific product
  static Future<List<StockItem>> getStockItemsByProduct(
    String companyId,
    String productId,
  ) async {
    final response = await ApiService.get<List<dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemsByProductEndpoint(companyId, productId),
    );

    return response.map((json) => StockItem.fromJson(json)).toList();
  }

  // Get stock summary for a specific product
  static Future<StockItemSummary> getStockItemSummary(
    String companyId,
    String productId,
  ) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemSummaryEndpoint(companyId, productId),
    );

    return StockItemSummary.fromJson(response);
  }

  // Stock Item Actions

  // Adjust stock quantity for a stock item
  static Future<StockItem> adjustStockItem(
    String companyId,
    String stockItemId,
    StockItemAdjustmentRequest request,
  ) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemAdjustEndpoint(companyId, stockItemId),
      data: request.toJson(),
    );

    return StockItem.fromJson(response);
  }

  // Reserve stock quantity
  static Future<StockItem> reserveStockItem(
    String companyId,
    String stockItemId,
    ReserveStockRequest request,
  ) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemReserveEndpoint(companyId, stockItemId),
      data: request.toJson(),
    );

    return StockItem.fromJson(response);
  }

  // Release reserved stock
  static Future<StockItem> releaseStockItem(
    String companyId,
    String stockItemId,
    ReleaseStockRequest request,
  ) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemReleaseEndpoint(companyId, stockItemId),
      data: request.toJson(),
    );

    return StockItem.fromJson(response);
  }

  // Transfer stock to another warehouse
  static Future<void> transferStockItem(
    String companyId,
    String stockItemId,
    TransferStockRequest request,
  ) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemTransferEndpoint(companyId, stockItemId),
      data: request.toJson(),
    );
  }

  // Stock Items Reports

  // Get low stock report
  static Future<LowStockReport> getLowStockReport(String companyId) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemsLowStockReportEndpoint(companyId),
    );

    return LowStockReport.fromJson(response);
  }

  // Get expiring stock report
  static Future<ExpiringStockReport> getExpiringStockReport(
    String companyId, {
    int daysAhead = 30,
  }) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemsExpiringReportEndpoint(companyId),
      queryParameters: {'daysAhead': daysAhead},
    );

    return ExpiringStockReport.fromJson(response);
  }

  // Get available quantity for a product
  static Future<int> getStockItemAvailableQuantity(
    String companyId,
    String productId, {
    String? warehouseId,
  }) async {
    final queryParams = {'productId': productId};
    if (warehouseId != null) {
      queryParams['warehouseId'] = warehouseId;
    }

    final response = await ApiService.get<int>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemsAvailableQuantityEndpoint(companyId),
      queryParameters: queryParams,
    );

    return response;
  }

  // Get total quantity for a product
  static Future<int> getStockItemTotalQuantity(
    String companyId,
    String productId, {
    String? warehouseId,
  }) async {
    final queryParams = {'productId': productId};
    if (warehouseId != null) {
      queryParams['warehouseId'] = warehouseId;
    }

    final response = await ApiService.get<int>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemsTotalQuantityEndpoint(companyId),
      queryParameters: queryParams,
    );

    return response;
  }

  // Bulk Operations

  // Create multiple stock items in bulk
  static Future<List<StockItem>> createStockItemsBulk(
    String companyId,
    List<CreateStockItemRequest> requests,
  ) async {
    final response = await ApiService.post<List<dynamic>>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemsBulkEndpoint(companyId),
      data: requests.map((r) => r.toJson()).toList(),
    );

    return response.map((json) => StockItem.fromJson(json)).toList();
  }

  // Update minimum stock levels in bulk
  static Future<void> updateStockItemMinLevelsBulk(
    String companyId,
    Map<String, int> minLevels,
  ) async {
    await ApiService.patch<void>(
      ApiConstants.inventoryServiceBaseUrl,
      ApiConstants.stockItemsBulkMinLevelsEndpoint(companyId),
      data: minLevels,
    );
  }

  // Raw Material Release Operation
  static Future<void> releaseRawMaterial(
    String companyId,
    RawMaterialReleaseRequest request,
  ) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.rawMaterialStockItemsEndpoint(companyId)}/release',
      data: request.toJson(),
    );
  }

  static Future<void> transferRawMaterial(
    String companyId,
    RawMaterialTransferRequest request,
  ) async {
    await ApiService.post<void>(
      ApiConstants.inventoryServiceBaseUrl,
      '${ApiConstants.rawMaterialStockItemsEndpoint(companyId)}/transfer',
      data: request.toJson(),
    );
  }

  // Production Tasks Operations

  /// Get production tasks with filtering and pagination
  static Future<List<MyProductionTaskDto>> getProductionTasks(
    String companyId,
    ProductionTaskListRequest request,
  ) async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        ApiConstants.productionServiceBaseUrl,
        ApiConstants.productionTasksListEndpoint(companyId),
        queryParameters: request.toJson(),
      );

      // Check if response has the wrapped structure
      if (response.containsKey('data')) {
        final data = response['data'] as List<dynamic>;
        return data.map((json) => MyProductionTaskDto.fromJson(json)).toList();
      } else {
        // Fallback for direct response
        final data = response as List<dynamic>;
        return data.map((json) => MyProductionTaskDto.fromJson(json)).toList();
      }
    } catch (e) {
      print('Production tasks endpoint error: $e');
      return [];
    }
  }

  static Future<List<MyProductionTaskDto>> getMyProductionTasks(String companyId) async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        ApiConstants.productionServiceBaseUrl,
        ApiConstants.productionTasksMyTasksEndpoint(companyId),
      );

      final data = response['data'] as List<dynamic>;
      return data.map((json) => MyProductionTaskDto.fromJson(json)).toList();
    } catch (e) {
      print('My production tasks endpoint error: $e');
      return [];
    }
  }

  static Future<MyProductionTaskDto> getProductionTask(String companyId, String taskId) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskByIdEndpoint(companyId, taskId),
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return MyProductionTaskDto.fromJson(response);
    }
  }

  // Production Task Actions
  static Future<MyProductionTaskDto> startProductionTask(String companyId, String taskId, StartTaskRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskStartEndpoint(companyId, taskId),
      data: request.toJson(),
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return MyProductionTaskDto.fromJson(response);
    }
  }

  static Future<MyProductionTaskDto> completeProductionTask(String companyId, String taskId, CompleteTaskRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskCompleteEndpoint(companyId, taskId),
      data: request.toJson(),
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return MyProductionTaskDto.fromJson(response);
    }
  }

  static Future<MyProductionTaskDto> cancelProductionTask(String companyId, String taskId, CancelTaskRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskCancelEndpoint(companyId, taskId),
      data: request.toJson(),
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return MyProductionTaskDto.fromJson(response);
    }
  }

  static Future<MyProductionTaskDto> updateProductionTaskProgress(String companyId, String taskId, UpdateTaskProgressRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskProgressEndpoint(companyId, taskId),
      data: request.toJson(),
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return MyProductionTaskDto.fromJson(response);
    }
  }

  // Production Task Comments
  static Future<List<ProductionTaskCommentDto>> getProductionTaskComments(String companyId, String taskId) async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        ApiConstants.productionServiceBaseUrl,
        ApiConstants.productionTaskCommentsEndpoint(companyId, taskId),
      );

      // Check if response has the wrapped structure
      if (response.containsKey('data')) {
        final data = response['data'] as List<dynamic>;
        return data.map((json) => ProductionTaskCommentDto.fromJson(json)).toList();
      } else {
        // Fallback for direct response
        final data = response as List<dynamic>;
        return data.map((json) => ProductionTaskCommentDto.fromJson(json)).toList();
      }
    } catch (e) {
      print('Production task comments endpoint error: $e');
      return [];
    }
  }

  static Future<ProductionTaskCommentDto> addProductionTaskComment(String companyId, String taskId, CreateProductionTaskCommentRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskCommentsEndpoint(companyId, taskId),
      data: request.toJson(),
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return ProductionTaskCommentDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return ProductionTaskCommentDto.fromJson(response);
    }
  }

  static Future<void> deleteProductionTaskComment(String companyId, String commentId) async {
    await ApiService.delete<void>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskCommentByIdEndpoint(companyId, commentId),
    );
  }

  // Production Task Attachments
  static Future<List<ProductionTaskAttachmentDto>> getProductionTaskAttachments(String companyId, String taskId) async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        ApiConstants.productionServiceBaseUrl,
        ApiConstants.productionTaskAttachmentsEndpoint(companyId, taskId),
      );

      // Check if response has the wrapped structure
      if (response.containsKey('data')) {
        final data = response['data'] as List<dynamic>;
        return data.map((json) => ProductionTaskAttachmentDto.fromJson(json)).toList();
      } else {
        // Fallback for direct response
        final data = response as List<dynamic>;
        return data.map((json) => ProductionTaskAttachmentDto.fromJson(json)).toList();
      }
    } catch (e) {
      print('Production task attachments endpoint error: $e');
      return [];
    }
  }

  static Future<ProductionTaskAttachmentDto> addProductionTaskAttachment(String companyId, String taskId, CreateProductionTaskAttachmentRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskAttachmentsEndpoint(companyId, taskId),
      data: request.toJson(),
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return ProductionTaskAttachmentDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return ProductionTaskAttachmentDto.fromJson(response);
    }
  }

  /// Upload file as multipart form data for production task attachment
  static Future<ProductionTaskAttachmentDto> uploadProductionTaskAttachment({
    required String companyId,
    required String taskId,
    required String filePath,
    String? description,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (description != null && description.isNotEmpty) 'description': description,
    });

    final response = await ApiService.postMultipart<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskAttachmentsEndpoint(companyId, taskId),
      formData: formData,
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return ProductionTaskAttachmentDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return ProductionTaskAttachmentDto.fromJson(response);
    }
  }

  /// Download production task attachment file as bytes
  static Future<List<int>> downloadProductionTaskAttachment(String companyId, String attachmentId) async {
    final dio = Dio();

    // Get current access token from secure storage
    final token = await StorageService.getSecure(AppConstants.accessTokenKey);
    if (token == null) {
      throw Exception('No access token available');
    }

    final response = await dio.get(
      '${ApiConstants.productionServiceBaseUrl}${ApiConstants.productionTaskAttachmentDownloadEndpoint(companyId, attachmentId)}',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.bytes,
      ),
    );

    return response.data as List<int>;
  }

  static Future<void> deleteProductionTaskAttachment(String companyId, String attachmentId) async {
    await ApiService.delete<void>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskAttachmentByIdEndpoint(companyId, attachmentId),
    );
  }

  // Production Task Assignment
  static Future<MyProductionTaskDto> assignTaskToSelf(String companyId, String taskId) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskAssignToSelfEndpoint(companyId, taskId),
      data: {},
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return MyProductionTaskDto.fromJson(response);
    }
  }

  static Future<MyProductionTaskDto> reassignTask(String companyId, String taskId, ReassignTaskRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskReassignEndpoint(companyId, taskId),
      data: request.toJson(),
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return MyProductionTaskDto.fromJson(response);
    }
  }

  static Future<MyProductionTaskDto> unassignTask(String companyId, String taskId) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskUnassignEndpoint(companyId, taskId),
      data: {},
    );

    // Check if response has the wrapped structure
    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      // Fallback for direct response
      return MyProductionTaskDto.fromJson(response);
    }
  }

  static Future<MyProductionTaskDto> updateTaskStatus(String companyId, UpdateTaskStatusRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskUpdateStatusEndpoint(companyId, request.taskId),
      data: request.toJson(),
    );

    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      return MyProductionTaskDto.fromJson(response);
    }
  }

  static Future<MyProductionTaskDto> updateTaskDueDate(String companyId, UpdateTaskDueDateRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskUpdateDueDateEndpoint(companyId, request.taskId),
      data: request.toJson(),
    );

    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      return MyProductionTaskDto.fromJson(response);
    }
  }

  static Future<MyProductionTaskDto> updateTaskProgress(String companyId, UpdateTaskProgressRequest request) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.productionServiceBaseUrl,
      ApiConstants.productionTaskUpdateProgressEndpoint(companyId, request.taskId),
      data: request.toJson(),
    );

    if (response.containsKey('data')) {
      return MyProductionTaskDto.fromJson(response['data']);
    } else {
      return MyProductionTaskDto.fromJson(response);
    }
  }
}