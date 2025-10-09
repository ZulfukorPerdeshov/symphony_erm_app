enum ProductionStatus { planning, inProgress, qualityControl, completed, cancelled }
enum StageStatus { notStarted, inProgress, completed, onHold }
enum TaskStatus { notStarted, inProgress, onHold, completed, cancelled }
enum TaskPriority { low, medium, high, urgent }

class ProductionOrderDto {
  final String id;
  final String orderNumber;
  final String productId;
  final String productName;
  final int quantity;
  final ProductionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final List<ProductionStageDto> stages;

  ProductionOrderDto({
    required this.id,
    required this.orderNumber,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.startDate,
    this.endDate,
    this.dueDate,
    required this.stages,
  });

  String get statusDisplay {
    switch (status) {
      case ProductionStatus.planning:
        return 'Planning';
      case ProductionStatus.inProgress:
        return 'In Progress';
      case ProductionStatus.qualityControl:
        return 'Quality Control';
      case ProductionStatus.completed:
        return 'Completed';
      case ProductionStatus.cancelled:
        return 'Cancelled';
    }
  }

  double get progressPercentage {
    if (stages.isEmpty) return 0.0;
    final completedStages = stages.where((stage) => stage.status == StageStatus.completed).length;
    return completedStages / stages.length;
  }

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && status != ProductionStatus.completed;
  bool get isStarted => status != ProductionStatus.planning;
  bool get isCompleted => status == ProductionStatus.completed;

  factory ProductionOrderDto.fromJson(Map<String, dynamic> json) => ProductionOrderDto(
        id: json['id'],
        orderNumber: json['orderNumber'],
        productId: json['productId'],
        productName: json['productName'],
        quantity: json['quantity'],
        status: ProductionStatus.values.firstWhere((e) => e.name == json['status']),
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        stages: (json['stages'] as List).map((e) => ProductionStageDto.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'status': status.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'stages': stages.map((e) => e.toJson()).toList(),
      };

  ProductionOrderDto copyWith({
    String? id,
    String? orderNumber,
    String? productId,
    String? productName,
    int? quantity,
    ProductionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDate,
    List<ProductionStageDto>? stages,
  }) {
    return ProductionOrderDto(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dueDate: dueDate ?? this.dueDate,
      stages: stages ?? this.stages,
    );
  }
}

class ProductionStageDto {
  final String id;
  final String name;
  final String description;
  final int order;
  final StageStatus status;
  final DateTime? startTime;
  final DateTime? endTime;

  ProductionStageDto({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.status,
    this.startTime,
    this.endTime,
  });

  String get statusDisplay {
    switch (status) {
      case StageStatus.notStarted:
        return 'Not Started';
      case StageStatus.inProgress:
        return 'In Progress';
      case StageStatus.completed:
        return 'Completed';
      case StageStatus.onHold:
        return 'On Hold';
    }
  }

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  bool get isActive => status == StageStatus.inProgress;
  bool get isCompleted => status == StageStatus.completed;

  factory ProductionStageDto.fromJson(Map<String, dynamic> json) => ProductionStageDto(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        order: json['order'],
        status: StageStatus.values.firstWhere((e) => e.name == json['status']),
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'order': order,
        'status': status.name,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };
}

class ProductionTaskDto {
  final String id;
  final String name;
  final String description;
  final String productionOrderId;
  final String? assignedTo;
  final String? assignedToName;
  final TaskStatus status;
  final TaskPriority priority;
  final int progressPercentage;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? dueDate;
  final List<String> requirements;

  ProductionTaskDto({
    required this.id,
    required this.name,
    required this.description,
    required this.productionOrderId,
    this.assignedTo,
    this.assignedToName,
    required this.status,
    required this.priority,
    required this.progressPercentage,
    this.startTime,
    this.endTime,
    this.dueDate,
    required this.requirements,
  });

  String get statusDisplay {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.onHold:
        return 'On Hold';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && status != TaskStatus.completed;
  bool get isStarted => status != TaskStatus.notStarted;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isActive => status == TaskStatus.inProgress;

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  factory ProductionTaskDto.fromJson(Map<String, dynamic> json) => ProductionTaskDto(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        productionOrderId: json['productionOrderId'],
        assignedTo: json['assignedTo'],
        assignedToName: json['assignedToName'],
        status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
        priority: TaskPriority.values.firstWhere((e) => e.name == json['priority']),
        progressPercentage: json['progressPercentage'],
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        requirements: List<String>.from(json['requirements'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'productionOrderId': productionOrderId,
        'assignedTo': assignedTo,
        'assignedToName': assignedToName,
        'status': status.name,
        'priority': priority.name,
        'progressPercentage': progressPercentage,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'requirements': requirements,
      };

  ProductionTaskDto copyWith({
    String? id,
    String? name,
    String? description,
    String? productionOrderId,
    String? assignedTo,
    String? assignedToName,
    TaskStatus? status,
    TaskPriority? priority,
    int? progressPercentage,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? dueDate,
    List<String>? requirements,
  }) {
    return ProductionTaskDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dueDate: dueDate ?? this.dueDate,
      requirements: requirements ?? this.requirements,
    );
  }
}

class CreateProductionOrderRequest {
  final String productId;
  final int quantity;
  final DateTime? dueDate;
  final List<String> stageIds;

  CreateProductionOrderRequest({
    required this.productId,
    required this.quantity,
    this.dueDate,
    required this.stageIds,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'dueDate': dueDate?.toIso8601String(),
        'stageIds': stageIds,
      };
}

class UpdateStageRequest {
  final String? notes;
  final Map<String, dynamic>? data;

  UpdateStageRequest({this.notes, this.data});

  Map<String, dynamic> toJson() => {
        'notes': notes,
        'data': data,
      };
}

class CreateTaskRequest {
  final String name;
  final String description;
  final String productionOrderId;
  final String? assignedTo;
  final TaskPriority priority;
  final DateTime? dueDate;
  final List<String> requirements;

  CreateTaskRequest({
    required this.name,
    required this.description,
    required this.productionOrderId,
    this.assignedTo,
    required this.priority,
    this.dueDate,
    required this.requirements,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'productionOrderId': productionOrderId,
        'assignedTo': assignedTo,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
        'requirements': requirements,
      };
}

// New API-compatible Production Task models
class MyProductionTaskDto {
  final String id;
  final String companyId;
  final String productionStageId;
  final String name;
  final String description;
  final int status;
  final int priority;
  final String? assignedToUserId;
  final String? assignedToUserName;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;
  final double estimatedHours;
  final double? actualHours;
  final int progressPercentage;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductionTaskCommentDto> comments;
  final List<ProductionTaskAttachmentDto> attachments;
  final bool isOverdue;
  final String? duration;
  final String? productionStageName;
  final ProductionStageBasicDto? productionStage;
  final ProductionBatchBasicDto? productionBatch;
  final ProductBasicDto? product;

  MyProductionTaskDto({
    required this.id,
    required this.companyId,
    required this.productionStageId,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    this.assignedToUserId,
    this.assignedToUserName,
    this.plannedStartDate,
    this.plannedEndDate,
    this.actualStartDate,
    this.actualEndDate,
    required this.estimatedHours,
    this.actualHours,
    required this.progressPercentage,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
    required this.attachments,
    required this.isOverdue,
    this.duration,
    this.productionStageName,
    this.productionStage,
    this.productionBatch,
    this.product,
  });

  factory MyProductionTaskDto.fromJson(Map<String, dynamic> json) {
    return MyProductionTaskDto(
      id: json['id'],
      companyId: json['companyId'],
      productionStageId: json['productionStageId'],
      name: json['name'],
      description: json['description'] ?? '',
      status: (json['status'] as num).toInt(),
      priority: (json['priority'] as num).toInt(),
      assignedToUserId: json['assignedToUserId'],
      assignedToUserName: json['assignedToUserName'],
      plannedStartDate: json['plannedStartDate'] != null
          ? DateTime.parse(json['plannedStartDate'])
          : null,
      plannedEndDate: json['plannedEndDate'] != null
          ? DateTime.parse(json['plannedEndDate'])
          : null,
      actualStartDate: json['actualStartDate'] != null
          ? DateTime.parse(json['actualStartDate'])
          : null,
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.parse(json['actualEndDate'])
          : null,
      estimatedHours: (json['estimatedHours'] ?? 0).toDouble(),
      actualHours: json['actualHours'] != null ? (json['actualHours'] as num).toDouble() : null,
      progressPercentage: ((json['progressPercentage'] ?? 0) as num).toInt(),
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => ProductionTaskCommentDto.fromJson(e))
          .toList(),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((e) => ProductionTaskAttachmentDto.fromJson(e))
          .toList(),
      isOverdue: json['isOverdue'] ?? false,
      duration: json['duration'],
      productionStageName: json['productionStageName'],
      productionStage: json['productionStage'] != null
          ? ProductionStageBasicDto.fromJson(json['productionStage'])
          : null,
      productionBatch: json['productionBatch'] != null
          ? ProductionBatchBasicDto.fromJson(json['productionBatch'])
          : null,
      product: json['product'] != null
          ? ProductBasicDto.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'productionStageId': productionStageId,
      'name': name,
      'description': description,
      'status': status,
      'priority': priority,
      'assignedToUserId': assignedToUserId,
      'assignedToUserName': assignedToUserName,
      'plannedStartDate': plannedStartDate?.toIso8601String(),
      'plannedEndDate': plannedEndDate?.toIso8601String(),
      'actualStartDate': actualStartDate?.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'progressPercentage': progressPercentage,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'isOverdue': isOverdue,
      'duration': duration,
      'productionStageName': productionStageName,
      'productionStage': productionStage?.toJson(),
      'productionBatch': productionBatch?.toJson(),
      'product': product?.toJson(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 0:
        return 'Not Started';
      case 1:
        return 'In Progress';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
      case 4:
        return 'On Hold';
      default:
        return 'Unknown';
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      case 3:
        return 'Urgent';
      default:
        return 'Unknown';
    }
  }
}

class ProductionTaskCommentDto {
  final String id;
  final String companyId;
  final String productionTaskId;
  final String comment;
  final String userId;
  final String? userName;
  final bool isInternal;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductionTaskCommentDto({
    required this.id,
    required this.companyId,
    required this.productionTaskId,
    required this.comment,
    required this.userId,
    this.userName,
    required this.isInternal,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductionTaskCommentDto.fromJson(Map<String, dynamic> json) {
    return ProductionTaskCommentDto(
      id: json['id'],
      companyId: json['companyId'],
      productionTaskId: json['productionTaskId'],
      comment: json['comment'],
      userId: json['userId'],
      userName: json['userName'],
      isInternal: json['isInternal'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'productionTaskId': productionTaskId,
      'comment': comment,
      'userId': userId,
      'userName': userName,
      'isInternal': isInternal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ProductionTaskAttachmentDto {
  final String id;
  final String companyId;
  final String productionTaskId;
  final String fileName;
  final String filePath;
  final String contentType;
  final int fileSize;
  final String? description;
  final String uploadedBy;
  final String? uploadedByName;
  final DateTime uploadedAt;

  ProductionTaskAttachmentDto({
    required this.id,
    required this.companyId,
    required this.productionTaskId,
    required this.fileName,
    required this.filePath,
    required this.contentType,
    required this.fileSize,
    this.description,
    required this.uploadedBy,
    this.uploadedByName,
    required this.uploadedAt,
  });

  factory ProductionTaskAttachmentDto.fromJson(Map<String, dynamic> json) {
    return ProductionTaskAttachmentDto(
      id: json['id'],
      companyId: json['companyId'],
      productionTaskId: json['productionTaskId'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      contentType: json['contentType'],
      fileSize: json['fileSize'],
      description: json['description'],
      uploadedBy: json['uploadedBy'],
      uploadedByName: json['uploadedByName'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'productionTaskId': productionTaskId,
      'fileName': fileName,
      'filePath': filePath,
      'contentType': contentType,
      'fileSize': fileSize,
      'description': description,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

// Nested DTOs for Production Task
class ProductionStageBasicDto {
  final String id;
  final String name;
  final String description;
  final int orderSequence;
  final int status;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;

  ProductionStageBasicDto({
    required this.id,
    required this.name,
    required this.description,
    required this.orderSequence,
    required this.status,
    this.plannedStartDate,
    this.plannedEndDate,
    this.actualStartDate,
    this.actualEndDate,
  });

  factory ProductionStageBasicDto.fromJson(Map<String, dynamic> json) {
    return ProductionStageBasicDto(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      orderSequence: (json['orderSequence'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      plannedStartDate: json['plannedStartDate'] != null
          ? DateTime.parse(json['plannedStartDate'])
          : null,
      plannedEndDate: json['plannedEndDate'] != null
          ? DateTime.parse(json['plannedEndDate'])
          : null,
      actualStartDate: json['actualStartDate'] != null
          ? DateTime.parse(json['actualStartDate'])
          : null,
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.parse(json['actualEndDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'orderSequence': orderSequence,
      'status': status,
      'plannedStartDate': plannedStartDate?.toIso8601String(),
      'plannedEndDate': plannedEndDate?.toIso8601String(),
      'actualStartDate': actualStartDate?.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
    };
  }
}

class ProductionBatchBasicDto {
  final String id;
  final String batchNumber;
  final int plannedQuantity;
  final int? actualQuantity;
  final int status;
  final DateTime? plannedStartDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;

  ProductionBatchBasicDto({
    required this.id,
    required this.batchNumber,
    required this.plannedQuantity,
    this.actualQuantity,
    required this.status,
    this.plannedStartDate,
    this.actualStartDate,
    this.actualEndDate,
  });

  factory ProductionBatchBasicDto.fromJson(Map<String, dynamic> json) {
    return ProductionBatchBasicDto(
      id: json['id'],
      batchNumber: json['batchNumber'],
      plannedQuantity: (json['plannedQuantity'] as num).toInt(),
      actualQuantity: json['actualQuantity'] != null ? (json['actualQuantity'] as num).toInt() : null,
      status: (json['status'] as num).toInt(),
      plannedStartDate: json['plannedStartDate'] != null
          ? DateTime.parse(json['plannedStartDate'])
          : null,
      actualStartDate: json['actualStartDate'] != null
          ? DateTime.parse(json['actualStartDate'])
          : null,
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.parse(json['actualEndDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'plannedQuantity': plannedQuantity,
      'actualQuantity': actualQuantity,
      'status': status,
      'plannedStartDate': plannedStartDate?.toIso8601String(),
      'actualStartDate': actualStartDate?.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
    };
  }
}

class ProductBasicDto {
  final String id;
  final String name;
  final String? sku;
  final String? barcode;

  ProductBasicDto({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
  });

  factory ProductBasicDto.fromJson(Map<String, dynamic> json) {
    return ProductBasicDto(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      barcode: json['barcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
    };
  }
}

// Request DTOs for Production Task Management
class StartTaskRequest {
  final DateTime startDate;
  final String? notes;

  StartTaskRequest({
    required this.startDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'notes': notes,
      };
}

class CompleteTaskRequest {
  final DateTime completionDate;
  final int? actualHours;
  final String? notes;

  CompleteTaskRequest({
    required this.completionDate,
    this.actualHours,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'completionDate': completionDate.toIso8601String(),
        'actualHours': actualHours,
        'notes': notes,
      };
}

class CancelTaskRequest {
  final String reason;

  CancelTaskRequest({
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'reason': reason,
      };
}

class UpdateTaskProgressRequest {
  final String taskId;
  final int progressPercentage;
  final String? notes;

  UpdateTaskProgressRequest({
    required this.taskId,
    required this.progressPercentage,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'progressPercentage': progressPercentage,
        'notes': notes,
      };
}

class UpdateTaskStatusRequest {
  final String taskId;
  final int status;
  final String? notes;

  UpdateTaskStatusRequest({
    required this.taskId,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'status': status,
        if (notes != null) 'notes': notes,
      };
}

class UpdateTaskDueDateRequest {
  final String taskId;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final String? notes;

  UpdateTaskDueDateRequest({
    required this.taskId,
    this.plannedStartDate,
    this.plannedEndDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (plannedStartDate != null) {
      map['plannedStartDate'] = plannedStartDate!.toIso8601String();
    }
    if (plannedEndDate != null) {
      map['plannedEndDate'] = plannedEndDate!.toIso8601String();
    }
    if (notes != null) {
      map['notes'] = notes;
    }
    return map;
  }
}

class CreateProductionTaskCommentRequest {
  final String comment;
  final bool isInternal;

  CreateProductionTaskCommentRequest({
    required this.comment,
    this.isInternal = false,
  });

  Map<String, dynamic> toJson() => {
        'comment': comment,
        'isInternal': isInternal,
      };
}

class CreateProductionTaskAttachmentRequest {
  final String fileName;
  final String filePath;
  final String contentType;
  final int fileSize;
  final String? description;

  CreateProductionTaskAttachmentRequest({
    required this.fileName,
    required this.filePath,
    required this.contentType,
    required this.fileSize,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'filePath': filePath,
        'contentType': contentType,
        'fileSize': fileSize,
        'description': description,
      };
}

class ReassignTaskRequest {
  final String? assignedToUserId;

  ReassignTaskRequest({
    this.assignedToUserId
  });

  Map<String, dynamic> toJson() => {
        'assignedToUserId': assignedToUserId,
      };
}

class ProductionTaskListRequest {
  final String? productionStageId;
  final String? assignedToUserId;
  final String? assignedToRoleId;
  final TaskStatus? status;
  final TaskPriority? priority;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool? isOverdue;
  final int skip;
  final int take;
  final String? orderBy;
  final bool orderDescending;

  ProductionTaskListRequest({
    this.productionStageId,
    this.assignedToUserId,
    this.assignedToRoleId,
    this.status,
    this.priority,
    this.fromDate,
    this.toDate,
    this.isOverdue,
    this.skip = 0,
    this.take = 50,
    this.orderBy = 'CreatedAt',
    this.orderDescending = true,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'skip': skip,
      'take': take,
      'orderDescending': orderDescending,
    };

    if (productionStageId != null) map['productionStageId'] = productionStageId;
    if (assignedToUserId != null) map['assignedToUserId'] = assignedToUserId;
    if (assignedToRoleId != null) map['assignedToRoleId'] = assignedToRoleId;
    if (status != null) map['status'] = status!.index;
    if (priority != null) map['priority'] = priority!.index;
    if (fromDate != null) map['fromDate'] = fromDate!.toIso8601String();
    if (toDate != null) map['toDate'] = toDate!.toIso8601String();
    if (isOverdue != null) map['isOverdue'] = isOverdue;
    if (orderBy != null) map['orderBy'] = orderBy;

    return map;
  }
}