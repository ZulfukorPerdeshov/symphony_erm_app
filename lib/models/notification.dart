enum NotificationType { order, production, inventory, system, task }

class NotificationDto {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  String get typeDisplay {
    switch (type) {
      case NotificationType.order:
        return 'Order';
      case NotificationType.production:
        return 'Production';
      case NotificationType.inventory:
        return 'Inventory';
      case NotificationType.system:
        return 'System';
      case NotificationType.task:
        return 'Task';
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.order:
        return '📦';
      case NotificationType.production:
        return '🏭';
      case NotificationType.inventory:
        return '📊';
      case NotificationType.system:
        return '⚙️';
      case NotificationType.task:
        return '✅';
    }
  }

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  factory NotificationDto.fromJson(Map<String, dynamic> json) => NotificationDto(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        type: NotificationType.values.firstWhere((e) => e.name == json['type']),
        isRead: json['isRead'],
        createdAt: DateTime.parse(json['createdAt']),
        data: json['data'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.name,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        'data': data,
      };

  NotificationDto copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationDto(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}

class NotificationPreferences {
  final bool orderNotifications;
  final bool productionNotifications;
  final bool inventoryNotifications;
  final bool systemNotifications;
  final bool taskNotifications;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationPreferences({
    required this.orderNotifications,
    required this.productionNotifications,
    required this.inventoryNotifications,
    required this.systemNotifications,
    required this.taskNotifications,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) => NotificationPreferences(
        orderNotifications: json['orderNotifications'] ?? true,
        productionNotifications: json['productionNotifications'] ?? true,
        inventoryNotifications: json['inventoryNotifications'] ?? true,
        systemNotifications: json['systemNotifications'] ?? true,
        taskNotifications: json['taskNotifications'] ?? true,
        pushNotifications: json['pushNotifications'] ?? true,
        emailNotifications: json['emailNotifications'] ?? true,
        soundEnabled: json['soundEnabled'] ?? true,
        vibrationEnabled: json['vibrationEnabled'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'orderNotifications': orderNotifications,
        'productionNotifications': productionNotifications,
        'inventoryNotifications': inventoryNotifications,
        'systemNotifications': systemNotifications,
        'taskNotifications': taskNotifications,
        'pushNotifications': pushNotifications,
        'emailNotifications': emailNotifications,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
      };

  NotificationPreferences copyWith({
    bool? orderNotifications,
    bool? productionNotifications,
    bool? inventoryNotifications,
    bool? systemNotifications,
    bool? taskNotifications,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      orderNotifications: orderNotifications ?? this.orderNotifications,
      productionNotifications: productionNotifications ?? this.productionNotifications,
      inventoryNotifications: inventoryNotifications ?? this.inventoryNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      taskNotifications: taskNotifications ?? this.taskNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class UpdateNotificationPreferencesRequest {
  final bool? orderNotifications;
  final bool? productionNotifications;
  final bool? inventoryNotifications;
  final bool? systemNotifications;
  final bool? taskNotifications;
  final bool? pushNotifications;
  final bool? emailNotifications;
  final bool? soundEnabled;
  final bool? vibrationEnabled;

  UpdateNotificationPreferencesRequest({
    this.orderNotifications,
    this.productionNotifications,
    this.inventoryNotifications,
    this.systemNotifications,
    this.taskNotifications,
    this.pushNotifications,
    this.emailNotifications,
    this.soundEnabled,
    this.vibrationEnabled,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (orderNotifications != null) data['orderNotifications'] = orderNotifications;
    if (productionNotifications != null) data['productionNotifications'] = productionNotifications;
    if (inventoryNotifications != null) data['inventoryNotifications'] = inventoryNotifications;
    if (systemNotifications != null) data['systemNotifications'] = systemNotifications;
    if (taskNotifications != null) data['taskNotifications'] = taskNotifications;
    if (pushNotifications != null) data['pushNotifications'] = pushNotifications;
    if (emailNotifications != null) data['emailNotifications'] = emailNotifications;
    if (soundEnabled != null) data['soundEnabled'] = soundEnabled;
    if (vibrationEnabled != null) data['vibrationEnabled'] = vibrationEnabled;
    return data;
  }
}

class NotificationSummary {
  final int totalNotifications;
  final int unreadNotifications;
  final int orderNotifications;
  final int productionNotifications;
  final int inventoryNotifications;
  final int systemNotifications;
  final int taskNotifications;

  NotificationSummary({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.orderNotifications,
    required this.productionNotifications,
    required this.inventoryNotifications,
    required this.systemNotifications,
    required this.taskNotifications,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) => NotificationSummary(
        totalNotifications: json['totalNotifications'],
        unreadNotifications: json['unreadNotifications'],
        orderNotifications: json['orderNotifications'],
        productionNotifications: json['productionNotifications'],
        inventoryNotifications: json['inventoryNotifications'],
        systemNotifications: json['systemNotifications'],
        taskNotifications: json['taskNotifications'],
      );
}