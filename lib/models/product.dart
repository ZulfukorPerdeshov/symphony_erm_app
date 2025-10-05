import 'product_extensions.dart';

class ProductDto {
  final String id;
  final String companyId;
  final String? categoryId;
  final ProductCategoryDto? category;
  final String name;
  final String description;
  final String sku;
  final String? barcode;
  final double price;
  final double wholesalePrice;
  final double weight;
  final ProductDimensions? dimensions;
  final String? tagsJson;
  final String? unitId;
  final bool isActive;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductUnitDto? unitEntity;
  final List<ProductImageDto> images;
  final List<ProductAttributeDto> attributes;

  // Legacy properties for backward compatibility
  final int stockQuantity;
  final int minimumStockLevel;
  final List<String> imageUrls;

  ProductDto({
    required this.id,
    required this.companyId,
    this.categoryId,
    this.category,
    required this.name,
    required this.description,
    required this.sku,
    this.barcode,
    required this.price,
    this.wholesalePrice = 0.0,
    this.weight = 0.0,
    this.dimensions,
    this.tagsJson,
    this.unitId,
    required this.isActive,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.unitEntity,
    this.images = const [],
    this.attributes = const [],
    // Legacy properties
    this.stockQuantity = 0,
    this.minimumStockLevel = 0,
    this.imageUrls = const [],
  });

  bool get isLowStock => stockQuantity <= minimumStockLevel;
  bool get isOutOfStock => stockQuantity <= 0;

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  String get mainImageUrl {
    if (images.isNotEmpty) {
      final mainImage = images.where((img) => img.isMain).firstOrNull;
      return mainImage?.url ?? images.first.url;
    }
    return imageUrls.isNotEmpty ? imageUrls.first : '';
  }

  String get unit => unitEntity?.name ?? 'pcs';
  String get categoryName => category?.name ?? 'Unknown Category';

  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
        id: json['id'] ?? '',
        companyId: json['companyId'] ?? '',
        categoryId: json['categoryId'],
        category: json['category'] != null ? ProductCategoryDto.fromJson(json['category']) : null,
        name: json['name'] ?? 'Unknown Product',
        description: json['description'] ?? '',
        sku: json['sku'] ?? '',
        barcode: json['barcode'],
        price: (json['price']?.toDouble() ?? 0.0),
        wholesalePrice: (json['wholesalePrice']?.toDouble() ?? 0.0),
        weight: (json['weight']?.toDouble() ?? 0.0),
        dimensions: json['dimensions'] != null ? ProductDimensions.fromJson(json['dimensions']) : null,
        tagsJson: json['tagsJson'],
        unitId: json['unitId'],
        isActive: json['isActive'] ?? true,
        isAvailable: json['isAvailable'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
        unitEntity: json['unitEntity'] != null ? ProductUnitDto.fromJson(json['unitEntity']) : null,
        images: (json['images'] as List? ?? [])
            .map((img) => ProductImageDto.fromJson(img))
            .toList(),
        attributes: (json['attributes'] as List? ?? [])
            .map((attr) => ProductAttributeDto.fromJson(attr))
            .toList(),
        // Legacy properties for backward compatibility
        stockQuantity: json['stockQuantity'] ?? 0,
        minimumStockLevel: json['minimumStockLevel'] ?? 0,
        imageUrls: List<String>.from(json['imageUrls'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'categoryId': categoryId,
        'category': category?.toJson(),
        'name': name,
        'description': description,
        'sku': sku,
        'barcode': barcode,
        'price': price,
        'wholesalePrice': wholesalePrice,
        'weight': weight,
        'dimensions': dimensions?.toJson(),
        'tagsJson': tagsJson,
        'unitId': unitId,
        'isActive': isActive,
        'isAvailable': isAvailable,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'unitEntity': unitEntity?.toJson(),
        'images': images.map((img) => img.toJson()).toList(),
        'attributes': attributes.map((attr) => attr.toJson()).toList(),
        // Legacy properties
        'stockQuantity': stockQuantity,
        'minimumStockLevel': minimumStockLevel,
        'imageUrls': imageUrls,
      };

  ProductDto copyWith({
    String? id,
    String? companyId,
    String? categoryId,
    ProductCategoryDto? category,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    double? price,
    double? wholesalePrice,
    double? weight,
    ProductDimensions? dimensions,
    String? tagsJson,
    String? unitId,
    bool? isActive,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductUnitDto? unitEntity,
    List<ProductImageDto>? images,
    List<ProductAttributeDto>? attributes,
    int? stockQuantity,
    int? minimumStockLevel,
    List<String>? imageUrls,
  }) {
    return ProductDto(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      tagsJson: tagsJson ?? this.tagsJson,
      unitId: unitId ?? this.unitId,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unitEntity: unitEntity ?? this.unitEntity,
      images: images ?? this.images,
      attributes: attributes ?? this.attributes,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minimumStockLevel: minimumStockLevel ?? this.minimumStockLevel,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

class CreateProductRequest {
  final String name;
  final String description;
  final String sku;
  final String category;
  final double price;
  final int stockQuantity;
  final int minimumStockLevel;
  final String unit;
  final List<String> imageUrls;

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.sku,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.minimumStockLevel,
    required this.unit,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'sku': sku,
        'category': category,
        'price': price,
        'stockQuantity': stockQuantity,
        'minimumStockLevel': minimumStockLevel,
        'unit': unit,
        'imageUrls': imageUrls,
      };
}

class UpdateProductRequest {
  final String? name;
  final String? description;
  final String? sku;
  final String? category;
  final double? price;
  final int? stockQuantity;
  final int? minimumStockLevel;
  final String? unit;
  final List<String>? imageUrls;
  final bool? isActive;

  UpdateProductRequest({
    this.name,
    this.description,
    this.sku,
    this.category,
    this.price,
    this.stockQuantity,
    this.minimumStockLevel,
    this.unit,
    this.imageUrls,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (sku != null) data['sku'] = sku;
    if (category != null) data['category'] = category;
    if (price != null) data['price'] = price;
    if (stockQuantity != null) data['stockQuantity'] = stockQuantity;
    if (minimumStockLevel != null) data['minimumStockLevel'] = minimumStockLevel;
    if (unit != null) data['unit'] = unit;
    if (imageUrls != null) data['imageUrls'] = imageUrls;
    if (isActive != null) data['isActive'] = isActive;
    return data;
  }
}

class StockAdjustmentRequest {
  final String productId;
  final int quantityChange;
  final String reason;
  final String? notes;

  StockAdjustmentRequest({
    required this.productId,
    required this.quantityChange,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantityChange': quantityChange,
        'reason': reason,
        'notes': notes,
      };
}

class StockMovementDto {
  final String id;
  final String productId;
  final String productName;
  final int quantityChange;
  final int previousQuantity;
  final int newQuantity;
  final String type;
  final String reason;
  final String? notes;
  final DateTime createdAt;

  StockMovementDto({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantityChange,
    required this.previousQuantity,
    required this.newQuantity,
    required this.type,
    required this.reason,
    this.notes,
    required this.createdAt,
  });

  factory StockMovementDto.fromJson(Map<String, dynamic> json) =>
      StockMovementDto(
        id: json['id'] ?? '',
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? 'Unknown Product',
        quantityChange: json['quantityChange'] ?? 0,
        previousQuantity: json['previousQuantity'] ?? 0,
        newQuantity: json['newQuantity'] ?? 0,
        type: json['type'] ?? 'unknown',
        reason: json['reason'] ?? '',
        notes: json['notes'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}

class ProductCategory {
  final String id;
  final String name;
  final String description;
  final int productCount;

  ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.productCount,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Unknown Category',
        description: json['description'] ?? '',
        productCount: json['productCount'] ?? 0,
      );
}

class StockTransferRequest {
  final String productId;
  final String fromLocation;
  final String toLocation;
  final int quantity;
  final String reason;
  final String? notes;

  StockTransferRequest({
    required this.productId,
    required this.fromLocation,
    required this.toLocation,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'quantity': quantity,
        'reason': reason,
        'notes': notes,
      };
}

class StockTransferDto {
  final String id;
  final String productId;
  final String productName;
  final String fromLocation;
  final String toLocation;
  final int quantity;
  final String reason;
  final String? notes;
  final TransferStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  StockTransferDto({
    required this.id,
    required this.productId,
    required this.productName,
    required this.fromLocation,
    required this.toLocation,
    required this.quantity,
    required this.reason,
    this.notes,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory StockTransferDto.fromJson(Map<String, dynamic> json) =>
      StockTransferDto(
        id: json['id'] ?? '',
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? 'Unknown Product',
        fromLocation: json['fromLocation'] ?? '',
        toLocation: json['toLocation'] ?? '',
        quantity: json['quantity'] ?? 0,
        reason: json['reason'] ?? '',
        notes: json['notes'],
        status: TransferStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransferStatus.pending,
        ),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      );
}

enum TransferStatus { pending, inProgress, completed, cancelled }

class BulkStockUpdateRequest {
  final String productId;
  final int newQuantity;
  final String reason;

  BulkStockUpdateRequest({
    required this.productId,
    required this.newQuantity,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'newQuantity': newQuantity,
        'reason': reason,
      };
}

class InventoryLocation {
  final String id;
  final String companyId;
  final String name;
  final String description;
  final String type;
  final String? address;
  final String? phone;
  final String? managerId;
  final String? managerName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InventoryLocation({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.type,
    this.address,
    this.phone,
    this.managerId,
    this.managerName,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryLocation.fromJson(Map<String, dynamic> json) =>
      InventoryLocation(
        id: json['id'] ?? '',
        companyId: json['companyId'] ?? '',
        name: json['name'] ?? 'Unknown Location',
        description: json['description'] ?? '',
        type: _convertTypeToString(json['type']),
        address: json['address'],
        phone: json['phone'],
        managerId: json['managerId'],
        managerName: json['managerName'],
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );

  static String _convertTypeToString(dynamic type) {
    if (type is int) {
      switch (type) {
        case 1:
          return 'Raw Material Warehouse';
        case 2:
          return 'Production Warehouse';
        case 3:
          return 'Product Warehouse';
        case 4:
          return 'Distribution Center';
        default:
          return 'Warehouse';
      }
    }
    return type?.toString() ?? 'Warehouse';
  }
}

class StockTakingRequest {
  final String locationId;
  final List<StockCountItem> items;
  final String? notes;

  StockTakingRequest({
    required this.locationId,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'locationId': locationId,
        'items': items.map((item) => item.toJson()).toList(),
        'notes': notes,
      };
}

class StockCountItem {
  final String productId;
  final int countedQuantity;
  final String? notes;

  StockCountItem({
    required this.productId,
    required this.countedQuantity,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'countedQuantity': countedQuantity,
        'notes': notes,
      };
}

class StockTakingDto {
  final String id;
  final String locationId;
  final String locationName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final StockTakingStatus status;
  final List<StockDiscrepancyItem> discrepancies;
  final String? notes;

  StockTakingDto({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.createdAt,
    this.completedAt,
    required this.status,
    required this.discrepancies,
    this.notes,
  });

  factory StockTakingDto.fromJson(Map<String, dynamic> json) =>
      StockTakingDto(
        id: json['id'] ?? '',
        locationId: json['locationId'] ?? '',
        locationName: json['locationName'] ?? 'Unknown Location',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        status: StockTakingStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => StockTakingStatus.inProgress,
        ),
        discrepancies: (json['discrepancies'] as List? ?? [])
            .map((item) => StockDiscrepancyItem.fromJson(item))
            .toList(),
        notes: json['notes'],
      );
}

enum StockTakingStatus { inProgress, completed, cancelled }

class StockDiscrepancyItem {
  final String productId;
  final String productName;
  final int systemQuantity;
  final int countedQuantity;
  final int difference;
  final String? notes;

  StockDiscrepancyItem({
    required this.productId,
    required this.productName,
    required this.systemQuantity,
    required this.countedQuantity,
    required this.difference,
    this.notes,
  });

  factory StockDiscrepancyItem.fromJson(Map<String, dynamic> json) =>
      StockDiscrepancyItem(
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? 'Unknown Product',
        systemQuantity: json['systemQuantity'] ?? 0,
        countedQuantity: json['countedQuantity'] ?? 0,
        difference: json['difference'] ?? 0,
        notes: json['notes'],
      );
}