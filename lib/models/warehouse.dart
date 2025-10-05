class RawMaterialStockItem {
  final String id;
  final String companyId;
  final String warehouseId;
  final String rawMaterialId;
  final String name;
  final String description;
  final String unit;
  final double quantity;
  final double reservedQuantity;
  final double availableQuantity;
  final double unitCost;
  final double totalValue;
  final DateTime? lastUpdated;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? supplierName;

  RawMaterialStockItem({
    required this.id,
    required this.companyId,
    required this.warehouseId,
    required this.rawMaterialId,
    required this.name,
    required this.description,
    required this.unit,
    required this.quantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.unitCost,
    required this.totalValue,
    this.lastUpdated,
    this.expiryDate,
    this.batchNumber,
    this.supplierName,
  });

  factory RawMaterialStockItem.fromJson(Map<String, dynamic> json) =>
      RawMaterialStockItem(
        id: json['id'] ?? '',
        companyId: json['companyId'] ?? '',
        warehouseId: json['warehouseId'] ?? '',
        rawMaterialId: json['rawMaterialId'] ?? '',
        name: json['rawMaterialName'] ?? 'Unknown Raw Material',
        description: json['description'] ?? '',
        unit: json['unit'] ?? 'kg',
        quantity: (json['quantity']?.toDouble() ?? 0.0),
        reservedQuantity: (json['reservedQuantity']?.toDouble() ?? 0.0),
        availableQuantity: (json['availableQuantity']?.toDouble() ?? 0.0),
        unitCost: (json['unitCost']?.toDouble() ?? 0.0),
        totalValue: (json['totalValue']?.toDouble() ?? 0.0),
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'])
            : null,
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        batchNumber: json['batchNumber'],
        supplierName: json['supplierName'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'warehouseId': warehouseId,
        'rawMaterialId': rawMaterialId,
        'name': name,
        'description': description,
        'unit': unit,
        'quantity': quantity,
        'reservedQuantity': reservedQuantity,
        'availableQuantity': availableQuantity,
        'unitCost': unitCost,
        'totalValue': totalValue,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'batchNumber': batchNumber,
        'supplierName': supplierName,
      };
}

class StockItem {
  final String id;
  final String companyId;
  final String warehouseId;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final int reservedQuantity;
  final int availableQuantity;
  final double unitCost;
  final double totalValue;
  final DateTime? lastUpdated;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? location;
  final String? warehouseName;

  StockItem({
    required this.id,
    required this.companyId,
    required this.warehouseId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.unitCost,
    required this.totalValue,
    this.lastUpdated,
    this.expiryDate,
    this.batchNumber,
    this.location,
    this.warehouseName,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        id: json['id'] ?? '',
        companyId: json['companyId'] ?? '',
        warehouseId: json['warehouseId'] ?? '',
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? 'Unknown Product',
        sku: json['sku'] ?? '',
        quantity: json['quantity'] ?? 0,
        reservedQuantity: json['reservedQuantity'] ?? 0,
        availableQuantity: json['availableQuantity'] ?? 0,
        unitCost: (json['unitCost']?.toDouble() ?? 0.0),
        totalValue: (json['totalValue']?.toDouble() ?? 0.0),
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'])
            : null,
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        batchNumber: json['batchNumber'],
        location: json['location'],
        warehouseName: json['warehouseName'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'warehouseId': warehouseId,
        'productId': productId,
        'productName': productName,
        'sku': sku,
        'quantity': quantity,
        'reservedQuantity': reservedQuantity,
        'availableQuantity': availableQuantity,
        'unitCost': unitCost,
        'totalValue': totalValue,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'batchNumber': batchNumber,
        'location': location,
      };
}

class RawMaterialAdjustRequest {
  final String rawMaterialId;
  final double quantityChange;
  final String reason;
  final String? notes;

  RawMaterialAdjustRequest({
    required this.rawMaterialId,
    required this.quantityChange,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'rawMaterialId': rawMaterialId,
        'quantityChange': quantityChange,
        'reason': reason,
        'notes': notes,
      };
}

class RawMaterialReserveRequest {
  final String rawMaterialId;
  final double quantity;
  final String purpose;
  final String? notes;

  RawMaterialReserveRequest({
    required this.rawMaterialId,
    required this.quantity,
    required this.purpose,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'rawMaterialId': rawMaterialId,
        'quantity': quantity,
        'purpose': purpose,
        'notes': notes,
      };
}

class StockItemAdjustRequest {
  final String stockItemId;
  final int quantityChange;
  final String reason;
  final String? notes;

  StockItemAdjustRequest({
    required this.stockItemId,
    required this.quantityChange,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'stockItemId': stockItemId,
        'quantityChange': quantityChange,
        'reason': reason,
        'notes': notes,
      };
}

class StockItemReserveRequest {
  final String stockItemId;
  final int quantity;
  final String purpose;
  final String? notes;

  StockItemReserveRequest({
    required this.stockItemId,
    required this.quantity,
    required this.purpose,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'stockItemId': stockItemId,
        'quantity': quantity,
        'purpose': purpose,
        'notes': notes,
      };
}

class StockItemReleaseRequest {
  final String stockItemId;
  final int quantity;
  final String reason;
  final String? notes;

  StockItemReleaseRequest({
    required this.stockItemId,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'stockItemId': stockItemId,
        'quantity': quantity,
        'reason': reason,
        'notes': notes,
      };
}

class StockItemTransferRequest {
  final String stockItemId;
  final String toWarehouseId;
  final int quantity;
  final String reason;
  final String? notes;

  StockItemTransferRequest({
    required this.stockItemId,
    required this.toWarehouseId,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'stockItemId': stockItemId,
        'toWarehouseId': toWarehouseId,
        'quantity': quantity,
        'reason': reason,
        'notes': notes,
      };
}

class RawMaterialReleaseRequest {
  final String rawMaterialId;
  final double quantity;
  final String reason;
  final String? notes;

  RawMaterialReleaseRequest({
    required this.rawMaterialId,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'rawMaterialId': rawMaterialId,
        'quantity': quantity,
        'reason': reason,
        'notes': notes,
      };
}

class RawMaterialTransferRequest {
  final String rawMaterialId;
  final String toWarehouseId;
  final double quantity;
  final String reason;
  final String? notes;

  RawMaterialTransferRequest({
    required this.rawMaterialId,
    required this.toWarehouseId,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'rawMaterialId': rawMaterialId,
        'toWarehouseId': toWarehouseId,
        'quantity': quantity,
        'reason': reason,
        'notes': notes,
      };
}

// Stock Items - Create/Update Request Models
class CreateStockItemRequest {
  final String productId;
  final String warehouseId;
  final int quantity;
  final int minStockLevel;
  final int? maxStockLevel;
  final int? reorderPoint;
  final int? reorderQuantity;
  final int reservedQuantity;
  final double? averageCost;
  final double? lastCost;
  final String? location;
  final String? lotNumber;
  final DateTime? expirationDate;
  final DateTime? lastCountDate;
  final String? notes;

  CreateStockItemRequest({
    required this.productId,
    required this.warehouseId,
    this.quantity = 0,
    this.minStockLevel = 0,
    this.maxStockLevel,
    this.reorderPoint,
    this.reorderQuantity,
    this.reservedQuantity = 0,
    this.averageCost,
    this.lastCost,
    this.location,
    this.lotNumber,
    this.expirationDate,
    this.lastCountDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'warehouseId': warehouseId,
        'quantity': quantity,
        'minStockLevel': minStockLevel,
        'maxStockLevel': maxStockLevel,
        'reorderPoint': reorderPoint,
        'reorderQuantity': reorderQuantity,
        'reservedQuantity': reservedQuantity,
        'averageCost': averageCost,
        'lastCost': lastCost,
        'location': location,
        'lotNumber': lotNumber,
        'expirationDate': expirationDate?.toIso8601String(),
        'lastCountDate': lastCountDate?.toIso8601String(),
        'notes': notes,
      };
}

class UpdateStockItemRequest {
  final int quantity;
  final int minStockLevel;
  final int? maxStockLevel;
  final int? reorderPoint;
  final int? reorderQuantity;
  final int reservedQuantity;
  final double? averageCost;
  final double? lastCost;
  final String? location;
  final String? lotNumber;
  final DateTime? expirationDate;
  final DateTime? lastCountDate;
  final String? notes;
  final bool isActive;

  UpdateStockItemRequest({
    required this.quantity,
    required this.minStockLevel,
    this.maxStockLevel,
    this.reorderPoint,
    this.reorderQuantity,
    this.reservedQuantity = 0,
    this.averageCost,
    this.lastCost,
    this.location,
    this.lotNumber,
    this.expirationDate,
    this.lastCountDate,
    this.notes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'minStockLevel': minStockLevel,
        'maxStockLevel': maxStockLevel,
        'reorderPoint': reorderPoint,
        'reorderQuantity': reorderQuantity,
        'reservedQuantity': reservedQuantity,
        'averageCost': averageCost,
        'lastCost': lastCost,
        'location': location,
        'lotNumber': lotNumber,
        'expirationDate': expirationDate?.toIso8601String(),
        'lastCountDate': lastCountDate?.toIso8601String(),
        'notes': notes,
        'isActive': isActive,
      };
}

// Stock Items - Action Request Models
class StockItemAdjustmentRequest {
  final String stockItemId;
  final int adjustmentQuantity;
  final String reason;
  final String? notes;
  final double? cost;

  StockItemAdjustmentRequest({
    required this.stockItemId,
    required this.adjustmentQuantity,
    required this.reason,
    this.notes,
    this.cost,
  });

  Map<String, dynamic> toJson() => {
        'stockItemId': stockItemId,
        'adjustmentQuantity': adjustmentQuantity,
        'reason': reason,
        'notes': notes,
        'cost': cost,
      };
}

class ReserveStockRequest {
  final String stockItemId;
  final int quantity;
  final String? reason;
  final String? notes;

  ReserveStockRequest({
    required this.stockItemId,
    required this.quantity,
    this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'stockItemId': stockItemId,
        'quantity': quantity,
        'reason': reason,
        'notes': notes,
      };
}

class ReleaseStockRequest {
  final int quantity;
  final String? reason;

  ReleaseStockRequest({
    required this.quantity,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'reason': reason,
      };
}

class TransferStockRequest {
  final String toWarehouseId;
  final int quantity;
  final String? reason;

  TransferStockRequest({
    required this.toWarehouseId,
    required this.quantity,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'toWarehouseId': toWarehouseId,
        'quantity': quantity,
        'reason': reason,
      };
}

// Stock Items - Search Models
class StockItemSearchRequest {
  final String? searchTerm;
  final String? productId;
  final String? warehouseId;
  final int? minQuantity;
  final int? maxQuantity;
  final bool? lowStock;
  final bool? expiringSoon;
  final bool? isActive;
  final DateTime? expirationDateFrom;
  final DateTime? expirationDateTo;
  final String? location;
  final String? lotNumber;
  final int page;
  final int pageSize;
  final String? sortBy;
  final String? sortOrder;

  StockItemSearchRequest({
    this.searchTerm,
    this.productId,
    this.warehouseId,
    this.minQuantity,
    this.maxQuantity,
    this.lowStock,
    this.expiringSoon,
    this.isActive,
    this.expirationDateFrom,
    this.expirationDateTo,
    this.location,
    this.lotNumber,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
        'searchTerm': searchTerm,
        'productId': productId,
        'warehouseId': warehouseId,
        'minQuantity': minQuantity,
        'maxQuantity': maxQuantity,
        'lowStock': lowStock,
        'expiringSoon': expiringSoon,
        'isActive': isActive,
        'expirationDateFrom': expirationDateFrom?.toIso8601String(),
        'expirationDateTo': expirationDateTo?.toIso8601String(),
        'location': location,
        'lotNumber': lotNumber,
        'page': page,
        'pageSize': pageSize,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };
}

class StockItemSearchResult {
  final List<StockItem> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  StockItemSearchResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory StockItemSearchResult.fromJson(Map<String, dynamic> json) =>
      StockItemSearchResult(
        items: (json['items'] as List<dynamic>?)
                ?.map((item) => StockItem.fromJson(item))
                .toList() ??
            [],
        totalCount: json['totalCount'] ?? 0,
        page: json['page'] ?? 1,
        pageSize: json['pageSize'] ?? 20,
        totalPages: json['totalPages'] ?? 0,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPreviousPage: json['hasPreviousPage'] ?? false,
      );
}

// Stock Items - Summary Models
class StockItemSummary {
  final String productId;
  final String? productName;
  final String? productSKU;
  final int totalQuantity;
  final int totalAvailableQuantity;
  final int totalReservedQuantity;
  final int warehouseCount;
  final double? averageUnitCost;
  final List<StockItem>? warehouseStocks;

  StockItemSummary({
    required this.productId,
    this.productName,
    this.productSKU,
    required this.totalQuantity,
    required this.totalAvailableQuantity,
    required this.totalReservedQuantity,
    required this.warehouseCount,
    this.averageUnitCost,
    this.warehouseStocks,
  });

  factory StockItemSummary.fromJson(Map<String, dynamic> json) =>
      StockItemSummary(
        productId: json['productId'] ?? '',
        productName: json['productName'],
        productSKU: json['productSKU'],
        totalQuantity: json['totalQuantity'] ?? 0,
        totalAvailableQuantity: json['totalAvailableQuantity'] ?? 0,
        totalReservedQuantity: json['totalReservedQuantity'] ?? 0,
        warehouseCount: json['warehouseCount'] ?? 0,
        averageUnitCost: json['averageUnitCost']?.toDouble(),
        warehouseStocks: (json['warehouseStocks'] as List<dynamic>?)
            ?.map((item) => StockItem.fromJson(item))
            .toList(),
      );
}

// Stock Items - Report Models
class LowStockReport {
  final List<StockItem>? lowStockItems;
  final List<StockItem>? outOfStockItems;
  final List<StockItem>? reorderSuggestedItems;
  final int totalLowStockCount;
  final int totalOutOfStockCount;
  final DateTime generatedAt;

  LowStockReport({
    this.lowStockItems,
    this.outOfStockItems,
    this.reorderSuggestedItems,
    required this.totalLowStockCount,
    required this.totalOutOfStockCount,
    required this.generatedAt,
  });

  factory LowStockReport.fromJson(Map<String, dynamic> json) => LowStockReport(
        lowStockItems: (json['lowStockItems'] as List<dynamic>?)
            ?.map((item) => StockItem.fromJson(item))
            .toList(),
        outOfStockItems: (json['outOfStockItems'] as List<dynamic>?)
            ?.map((item) => StockItem.fromJson(item))
            .toList(),
        reorderSuggestedItems: (json['reorderSuggestedItems'] as List<dynamic>?)
            ?.map((item) => StockItem.fromJson(item))
            .toList(),
        totalLowStockCount: json['totalLowStockCount'] ?? 0,
        totalOutOfStockCount: json['totalOutOfStockCount'] ?? 0,
        generatedAt: DateTime.parse(json['generatedAt']),
      );
}

class ExpiringStockReport {
  final List<StockItem>? expiringItems;
  final List<StockItem>? expiredItems;
  final int totalExpiringCount;
  final int totalExpiredCount;
  final DateTime generatedAt;

  ExpiringStockReport({
    this.expiringItems,
    this.expiredItems,
    required this.totalExpiringCount,
    required this.totalExpiredCount,
    required this.generatedAt,
  });

  factory ExpiringStockReport.fromJson(Map<String, dynamic> json) =>
      ExpiringStockReport(
        expiringItems: (json['expiringItems'] as List<dynamic>?)
            ?.map((item) => StockItem.fromJson(item))
            .toList(),
        expiredItems: (json['expiredItems'] as List<dynamic>?)
            ?.map((item) => StockItem.fromJson(item))
            .toList(),
        totalExpiringCount: json['totalExpiringCount'] ?? 0,
        totalExpiredCount: json['totalExpiredCount'] ?? 0,
        generatedAt: DateTime.parse(json['generatedAt']),
      );
}