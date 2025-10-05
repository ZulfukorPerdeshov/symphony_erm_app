enum OrderStatus { draft, pending, confirmed, processing, ready, shipped, delivered, cancelled, returned }

enum DeliveryType { pickup, delivery }

enum DeliveryStatus { notRequired, pending, inTransit, delivered }

class OrderDto {
  final String id;
  final String companyId;
  final String? branchId;
  final String customerId;
  final String orderNumber;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? dueDate;
  final double subTotalAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final String? currencyId;
  final String? notes;
  final DeliveryType deliveryType;
  final DeliveryStatus deliveryStatus;
  final double deliveryPrice;
  final String? salesPointId;
  final int? deliveryCountyId;
  final int? deliveryRegionId;
  final int? deliveryDistrictId;
  final String? deliveryAddress;
  final String? parcelReceiverContactName;
  final String? parcelReceiverPhone;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CustomerDto? customer;
  final List<OrderItemDto> items;

  OrderDto({
    required this.id,
    required this.companyId,
    this.branchId,
    required this.customerId,
    required this.orderNumber,
    required this.status,
    required this.orderDate,
    this.dueDate,
    required this.subTotalAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    this.currencyId,
    this.notes,
    required this.deliveryType,
    required this.deliveryStatus,
    required this.deliveryPrice,
    this.salesPointId,
    this.deliveryCountyId,
    this.deliveryRegionId,
    this.deliveryDistrictId,
    this.deliveryAddress,
    this.parcelReceiverContactName,
    this.parcelReceiverPhone,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.customer,
    required this.items,
  });

  String get statusDisplay {
    switch (status) {
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  String get customerName => customer?.name ?? 'Unknown Customer';

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedSubTotalAmount {
    final amount = subTotalAmount / 100;
    return amount.toStringAsFixed(2);
  }

  String get formattedDiscountAmount {
    final amount = discountAmount / 100;
    return amount.toStringAsFixed(2);
  }

  String get formattedTotalAmount {
    final amount = totalAmount / 100;
    return amount.toStringAsFixed(2);
  }

  String get formattedPaidAmount {
    final amount = paidAmount / 100;
    return amount.toStringAsFixed(2);
  }

  String get formattedDeliveryPrice {
    final amount = deliveryPrice / 100;
    return amount.toStringAsFixed(2);
  }

  bool get canProcess => status == OrderStatus.draft || status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get canShip => status == OrderStatus.ready;
  bool get canCancel => status != OrderStatus.shipped &&
                       status != OrderStatus.delivered &&
                       status != OrderStatus.cancelled &&
                       status != OrderStatus.returned;

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    print('OrderDto.fromJson called with keys: ${json.keys}');
    print('Has items key: ${json.containsKey('items')}');
    if (json.containsKey('items')) {
      print('Items type: ${json['items'].runtimeType}');
      if (json['items'] is List) {
        print('Items list length: ${(json['items'] as List).length}');
      }
    }

    return OrderDto(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      branchId: json['branchId'],
      customerId: json['customerId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: _parseOrderStatus(json['status']),
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'])
          : DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      subTotalAmount: (json['subTotalAmount']?.toDouble() ?? 0.0),
      discountAmount: (json['discountAmount']?.toDouble() ?? 0.0),
      totalAmount: (json['totalAmount']?.toDouble() ?? 0.0),
      paidAmount: (json['paidAmount']?.toDouble() ?? 0.0),
      currencyId: json['currencyId'],
      notes: json['notes'],
      deliveryType: _parseDeliveryType(json['deliveryType']),
      deliveryStatus: _parseDeliveryStatus(json['deliveryStatus']),
      deliveryPrice: (json['deliveryPrice']?.toDouble() ?? 0.0),
      salesPointId: json['salesPointId'],
      deliveryCountyId: json['deliveryCountyId'],
      deliveryRegionId: json['deliveryRegionId'],
      deliveryDistrictId: json['deliveryDistrictId'],
      deliveryAddress: json['deliveryAddress'],
      parcelReceiverContactName: json['parcelReceiverContactName'],
      parcelReceiverPhone: json['parcelReceiverPhone'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      customer: json['customer'] != null
          ? CustomerDto.fromJson(json['customer'])
          : null,
      items: _extractOrderItems(json),
    );
  }


  static OrderStatus _parseOrderStatus(dynamic status) {
    if (status == null) return OrderStatus.draft;

    try {
      // Convert status to lowercase and match with enum values
      final statusStr = status.toString().toLowerCase();
      return OrderStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == statusStr,
        orElse: () => OrderStatus.draft,
      );
    } catch (e) {
      return OrderStatus.draft;
    }
  }

  static DeliveryType _parseDeliveryType(dynamic type) {
    if (type == null) return DeliveryType.pickup;

    try {
      final typeStr = type.toString().toLowerCase();
      return DeliveryType.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr,
        orElse: () => DeliveryType.pickup,
      );
    } catch (e) {
      return DeliveryType.pickup;
    }
  }

  static DeliveryStatus _parseDeliveryStatus(dynamic status) {
    if (status == null) return DeliveryStatus.notRequired;

    try {
      final statusStr = status.toString().toLowerCase();
      switch (statusStr) {
        case 'notrequired':
          return DeliveryStatus.notRequired;
        case 'intransit':
          return DeliveryStatus.inTransit;
        default:
          return DeliveryStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == statusStr,
            orElse: () => DeliveryStatus.notRequired,
          );
      }
    } catch (e) {
      return DeliveryStatus.notRequired;
    }
  }

  static List<OrderItemDto> _extractOrderItems(Map<String, dynamic> json) {
    // Check if items exist in the response
    if (json['items'] is List) {
      try {
        final itemsList = json['items'] as List;
        print('Parsing ${itemsList.length} order items');

        final result = <OrderItemDto>[];
        for (int i = 0; i < itemsList.length; i++) {
          try {
            final item = OrderItemDto.fromJson(itemsList[i]);
            result.add(item);
            print('Successfully parsed item $i: ${item.productId}');
          } catch (e) {
            print('Error parsing item $i: $e');
            print('Item JSON: ${itemsList[i]}');
            // Continue with other items instead of failing completely
          }
        }

        print('Successfully parsed ${result.length} out of ${itemsList.length} order items');
        return result;
      } catch (e) {
        print('Error parsing order items: $e');
        return [];
      }
    }
    print('No items found in JSON or items is not a List');
    return [];
  }


  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'branchId': branchId,
        'customerId': customerId,
        'orderNumber': orderNumber,
        'status': status.name,
        'orderDate': orderDate.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'subTotalAmount': subTotalAmount,
        'discountAmount': discountAmount,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'currencyId': currencyId,
        'notes': notes,
        'deliveryType': deliveryType.name,
        'deliveryStatus': deliveryStatus.name,
        'deliveryPrice': deliveryPrice,
        'salesPointId': salesPointId,
        'deliveryCountyId': deliveryCountyId,
        'deliveryRegionId': deliveryRegionId,
        'deliveryDistrictId': deliveryDistrictId,
        'deliveryAddress': deliveryAddress,
        'parcelReceiverContactName': parcelReceiverContactName,
        'parcelReceiverPhone': parcelReceiverPhone,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'customer': customer?.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
      };

  OrderDto copyWith({
    String? id,
    String? companyId,
    String? branchId,
    String? customerId,
    String? orderNumber,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? dueDate,
    double? subTotalAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    String? currencyId,
    String? notes,
    DeliveryType? deliveryType,
    DeliveryStatus? deliveryStatus,
    double? deliveryPrice,
    String? salesPointId,
    int? deliveryCountyId,
    int? deliveryRegionId,
    int? deliveryDistrictId,
    String? deliveryAddress,
    String? parcelReceiverContactName,
    String? parcelReceiverPhone,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    CustomerDto? customer,
    List<OrderItemDto>? items,
  }) {
    return OrderDto(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      dueDate: dueDate ?? this.dueDate,
      subTotalAmount: subTotalAmount ?? this.subTotalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      currencyId: currencyId ?? this.currencyId,
      notes: notes ?? this.notes,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      salesPointId: salesPointId ?? this.salesPointId,
      deliveryCountyId: deliveryCountyId ?? this.deliveryCountyId,
      deliveryRegionId: deliveryRegionId ?? this.deliveryRegionId,
      deliveryDistrictId: deliveryDistrictId ?? this.deliveryDistrictId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      parcelReceiverContactName: parcelReceiverContactName ?? this.parcelReceiverContactName,
      parcelReceiverPhone: parcelReceiverPhone ?? this.parcelReceiverPhone,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      items: items ?? this.items,
    );
  }
}

class OrderItemDto {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int reservedQuantity;
  final int producedQuantity;

  OrderItemDto({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.reservedQuantity,
    required this.producedQuantity,
  });

  String get productName {
    // Extract a more readable product name from the productId
    final parts = productId.split('-');
    if (parts.isNotEmpty) {
      return 'Product ${parts.first}';
    }
    return 'Product $productId';
  }

  String get formattedUnitPrice {
    // Convert from cents/kopecks to main currency units
    final price = unitPrice / 100;
    return price.toStringAsFixed(2);
  }

  String get formattedTotalPrice {
    // Convert from cents/kopecks to main currency units
    final price = totalPrice / 100;
    return price.toStringAsFixed(2);
  }

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    print('Parsing OrderItemDto from JSON: ${json.keys}');
    try {
      return OrderItemDto(
        id: json['id'] ?? '',
        orderId: json['orderId'] ?? '',
        productId: json['productId'] ?? '',
        quantity: (json['quantity'] ?? 0).toInt(),
        unitPrice: (json['unitPrice']?.toDouble() ?? 0.0),
        totalPrice: (json['totalPrice']?.toDouble() ?? 0.0),
        reservedQuantity: (json['reservedQuantity'] ?? 0).toInt(),
        producedQuantity: (json['producedQuantity'] ?? 0).toInt(),
      );
    } catch (e) {
      print('Error parsing OrderItemDto: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'reservedQuantity': reservedQuantity,
        'producedQuantity': producedQuantity,
      };
}

class CustomerDto {
  final String id;
  final String companyId;
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;

  CustomerDto({
    required this.id,
    required this.companyId,
    required this.name,
    this.contactName,
    this.phone,
    this.email,
    this.address,
  });

  factory CustomerDto.fromJson(Map<String, dynamic> json) => CustomerDto(
        id: json['id'] ?? '',
        companyId: json['companyId'] ?? '',
        name: json['name'] ?? 'Unknown Customer',
        contactName: json['contactName'],
        phone: json['phone'],
        email: json['email'],
        address: json['address'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'name': name,
        'contactName': contactName,
        'phone': phone,
        'email': email,
        'address': address,
      };
}

class ShippingAddressDto {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  ShippingAddressDto({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  String get fullAddress => '$street, $city, $state $zipCode, $country';

  factory ShippingAddressDto.fromJson(Map<String, dynamic> json) =>
      ShippingAddressDto(
        street: json['street'],
        city: json['city'],
        state: json['state'],
        zipCode: json['zipCode'],
        country: json['country'],
      );

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'country': country,
      };
}

class UpdateOrderStatusRequest {
  final OrderStatus status;
  final String? notes;
  final String? trackingNumber;

  UpdateOrderStatusRequest({
    required this.status,
    this.notes,
    this.trackingNumber,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'notes': notes,
        'trackingNumber': trackingNumber,
      };
}

class CreateOrderRequest {
  final String customerId;
  final List<CreateOrderItemRequest> items;
  final ShippingAddressDto shippingAddress;
  final String? notes;

  CreateOrderRequest({
    required this.customerId,
    required this.items,
    required this.shippingAddress,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'items': items.map((e) => e.toJson()).toList(),
        'shippingAddress': shippingAddress.toJson(),
        'notes': notes,
      };
}

class CreateOrderItemRequest {
  final String productId;
  final int quantity;
  final double unitPrice;

  CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

class OrderSummary {
  final int totalOrders;
  final int pendingOrders;
  final int processingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final double totalRevenue;

  OrderSummary({
    required this.totalOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.totalRevenue,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) => OrderSummary(
        totalOrders: json['totalOrders'],
        pendingOrders: json['pendingOrders'],
        processingOrders: json['processingOrders'],
        shippedOrders: json['shippedOrders'],
        deliveredOrders: json['deliveredOrders'],
        totalRevenue: json['totalRevenue'].toDouble(),
      );
}

class OrderStatusHistoryDto {
  final String id;
  final String orderId;
  final OrderStatus status;
  final OrderStatus? previousStatus;
  final DateTime changedAt;
  final String? changedBy;
  final String? notes;
  final String? trackingNumber;

  OrderStatusHistoryDto({
    required this.id,
    required this.orderId,
    required this.status,
    this.previousStatus,
    required this.changedAt,
    this.changedBy,
    this.notes,
    this.trackingNumber,
  });

  factory OrderStatusHistoryDto.fromJson(Map<String, dynamic> json) =>
      OrderStatusHistoryDto(
        id: json['id'],
        orderId: json['orderId'],
        status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
        previousStatus: json['previousStatus'] != null
            ? OrderStatus.values.firstWhere((e) => e.name == json['previousStatus'])
            : null,
        changedAt: DateTime.parse(json['changedAt']),
        changedBy: json['changedBy'],
        notes: json['notes'],
        trackingNumber: json['trackingNumber'],
      );
}

class CancelOrderRequest {
  final String reason;
  final String? notes;

  CancelOrderRequest({
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'notes': notes,
      };
}

class ReturnOrderRequest {
  final String reason;
  final String? notes;
  final List<String>? affectedItems;

  ReturnOrderRequest({
    required this.reason,
    this.notes,
    this.affectedItems,
  });

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'notes': notes,
        'affectedItems': affectedItems,
      };
}

class ShipOrderRequest {
  final String? trackingNumber;
  final String? carrier;
  final String? notes;
  final DateTime? estimatedDeliveryDate;

  ShipOrderRequest({
    this.trackingNumber,
    this.carrier,
    this.notes,
    this.estimatedDeliveryDate,
  });

  Map<String, dynamic> toJson() => {
        'trackingNumber': trackingNumber,
        'carrier': carrier,
        'notes': notes,
        'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      };
}