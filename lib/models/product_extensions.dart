// Supporting models for detailed product response

import 'product.dart';

class ProductCategoryDto {
  final String id;
  final String name;
  final String description;
  final int type;
  final String? parentId;
  final bool isActive;
  final int sortOrder;
  final String? iconUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parent;
  final List<String> children;

  ProductCategoryDto({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.parentId,
    required this.isActive,
    required this.sortOrder,
    this.iconUrl,
    required this.createdAt,
    required this.updatedAt,
    this.parent,
    required this.children,
  });

  factory ProductCategoryDto.fromJson(Map<String, dynamic> json) =>
      ProductCategoryDto(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        type: json['type'] ?? 0,
        parentId: json['parentId'],
        isActive: json['isActive'] ?? true,
        sortOrder: json['sortOrder'] ?? 0,
        iconUrl: json['iconUrl'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
        parent: json['parent'],
        children: List<String>.from(json['children'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type,
        'parentId': parentId,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'iconUrl': iconUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'parent': parent,
        'children': children,
      };
}

class ProductDimensions {
  final double length;
  final double width;
  final double height;

  ProductDimensions({
    required this.length,
    required this.width,
    required this.height,
  });

  factory ProductDimensions.fromJson(Map<String, dynamic> json) =>
      ProductDimensions(
        length: (json['length']?.toDouble() ?? 0.0),
        width: (json['width']?.toDouble() ?? 0.0),
        height: (json['height']?.toDouble() ?? 0.0),
      );

  Map<String, dynamic> toJson() => {
        'length': length,
        'width': width,
        'height': height,
      };
}

class ProductUnitDto {
  final String id;
  final String code;
  final String name;
  final bool isActive;
  final double conversionFactor;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductUnitDto({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.conversionFactor,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductUnitDto.fromJson(Map<String, dynamic> json) =>
      ProductUnitDto(
        id: json['id'] ?? '',
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        isActive: json['isActive'] ?? true,
        conversionFactor: (json['conversionFactor']?.toDouble() ?? 1.0),
        description: json['description'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'isActive': isActive,
        'conversionFactor': conversionFactor,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class ProductImageDto {
  final String id;
  final String productId;
  final String fileName;
  final String url;
  final String contentType;
  final int fileSize;
  final bool isMain;
  final int displayOrder;
  final DateTime uploadedAt;

  ProductImageDto({
    required this.id,
    required this.productId,
    required this.fileName,
    required this.url,
    required this.contentType,
    required this.fileSize,
    required this.isMain,
    required this.displayOrder,
    required this.uploadedAt,
  });

  factory ProductImageDto.fromJson(Map<String, dynamic> json) =>
      ProductImageDto(
        id: json['id'] ?? '',
        productId: json['productId'] ?? '',
        fileName: json['fileName'] ?? '',
        url: json['url'] ?? '',
        contentType: json['contentType'] ?? '',
        fileSize: json['fileSize'] ?? 0,
        isMain: json['isMain'] ?? false,
        displayOrder: json['displayOrder'] ?? 0,
        uploadedAt: json['uploadedAt'] != null
            ? DateTime.parse(json['uploadedAt'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'fileName': fileName,
        'url': url,
        'contentType': contentType,
        'fileSize': fileSize,
        'isMain': isMain,
        'displayOrder': displayOrder,
        'uploadedAt': uploadedAt.toIso8601String(),
      };
}

class ProductAttributeDto {
  final String id;
  final String productId;
  final String name;
  final String value;
  final String? unitId;
  final int displayOrder;

  ProductAttributeDto({
    required this.id,
    required this.productId,
    required this.name,
    required this.value,
    this.unitId,
    required this.displayOrder,
  });

  factory ProductAttributeDto.fromJson(Map<String, dynamic> json) =>
      ProductAttributeDto(
        id: json['id'] ?? '',
        productId: json['productId'] ?? '',
        name: json['name'] ?? '',
        value: json['value'] ?? '',
        unitId: json['unitId'],
        displayOrder: json['displayOrder'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'name': name,
        'value': value,
        'unitId': unitId,
        'displayOrder': displayOrder,
      };
}

extension ProductDtoExtensions on ProductDto {
  /// Returns the first available image URL
  String? get firstImageUrl {
    if (images.isNotEmpty) {
      return images.first.url;
    }
    return imageUrls.isNotEmpty ? imageUrls.first : null;
  }

  /// Returns the main image URL or first available
  String? get primaryImageUrl {
    if (images.isNotEmpty) {
      final mainImage = images.where((img) => img.isMain).firstOrNull;
      return mainImage?.url ?? images.first.url;
    }
    return imageUrls.isNotEmpty ? imageUrls.first : null;
  }
}