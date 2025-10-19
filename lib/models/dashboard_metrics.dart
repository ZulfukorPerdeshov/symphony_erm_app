enum DatePeriod { day, week, month, year }

class DashboardMetrics {
  final TaskMetrics tasks;
  final OrderMetrics orders;
  final ProductMetrics products;
  final List<TimeSeriesData> tasksTrend;
  final List<TimeSeriesData> ordersTrend;
  final List<TimeSeriesData> productsTrend;
  final DatePeriod period;
  final DateTime startDate;
  final DateTime endDate;

  DashboardMetrics({
    required this.tasks,
    required this.orders,
    required this.products,
    required this.tasksTrend,
    required this.ordersTrend,
    required this.productsTrend,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  factory DashboardMetrics.empty() {
    final now = DateTime.now();
    return DashboardMetrics(
      tasks: TaskMetrics.empty(),
      orders: OrderMetrics.empty(),
      products: ProductMetrics.empty(),
      tasksTrend: [],
      ordersTrend: [],
      productsTrend: [],
      period: DatePeriod.day,
      startDate: now,
      endDate: now,
    );
  }
}

class TaskMetrics {
  final int total;
  final int completed;
  final int inProgress;
  final int notStarted;
  final int cancelled;
  final int overdue;
  final double completionRate;
  final double averageCompletionTime; // in hours

  TaskMetrics({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.notStarted,
    required this.cancelled,
    required this.overdue,
    required this.completionRate,
    required this.averageCompletionTime,
  });

  factory TaskMetrics.empty() {
    return TaskMetrics(
      total: 0,
      completed: 0,
      inProgress: 0,
      notStarted: 0,
      cancelled: 0,
      overdue: 0,
      completionRate: 0.0,
      averageCompletionTime: 0.0,
    );
  }

  factory TaskMetrics.fromJson(Map<String, dynamic> json) {
    return TaskMetrics(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      notStarted: json['notStarted'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      overdue: json['overdue'] ?? 0,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      averageCompletionTime: (json['averageCompletionTime'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'completed': completed,
      'inProgress': inProgress,
      'notStarted': notStarted,
      'cancelled': cancelled,
      'overdue': overdue,
      'completionRate': completionRate,
      'averageCompletionTime': averageCompletionTime,
    };
  }
}

class OrderMetrics {
  final int total;
  final int pending;
  final int confirmed;
  final int processing;
  final int completed;
  final int cancelled;
  final double totalRevenue;
  final double averageOrderValue;
  final int totalItems;

  OrderMetrics({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.processing,
    required this.completed,
    required this.cancelled,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.totalItems,
  });

  factory OrderMetrics.empty() {
    return OrderMetrics(
      total: 0,
      pending: 0,
      confirmed: 0,
      processing: 0,
      completed: 0,
      cancelled: 0,
      totalRevenue: 0.0,
      averageOrderValue: 0.0,
      totalItems: 0,
    );
  }

  factory OrderMetrics.fromJson(Map<String, dynamic> json) {
    return OrderMetrics(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      processing: json['processing'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0.0).toDouble(),
      totalItems: json['totalItems'] ?? 0,
    );
  }

  String get formattedTotalRevenue {
    final amount = totalRevenue / 100;
    return amount.toStringAsFixed(2);
  }

  String get formattedAverageOrderValue {
    final amount = averageOrderValue / 100;
    return amount.toStringAsFixed(2);
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'confirmed': confirmed,
      'processing': processing,
      'completed': completed,
      'cancelled': cancelled,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'totalItems': totalItems,
    };
  }
}

class ProductMetrics {
  final int totalProducts;
  final int activeProducts;
  final int inactiveProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final int totalProduced;
  final double productionEfficiency;

  ProductMetrics({
    required this.totalProducts,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalProduced,
    required this.productionEfficiency,
  });

  factory ProductMetrics.empty() {
    return ProductMetrics(
      totalProducts: 0,
      activeProducts: 0,
      inactiveProducts: 0,
      lowStockProducts: 0,
      outOfStockProducts: 0,
      totalProduced: 0,
      productionEfficiency: 0.0,
    );
  }

  factory ProductMetrics.fromJson(Map<String, dynamic> json) {
    return ProductMetrics(
      totalProducts: json['totalProducts'] ?? 0,
      activeProducts: json['activeProducts'] ?? 0,
      inactiveProducts: json['inactiveProducts'] ?? 0,
      lowStockProducts: json['lowStockProducts'] ?? 0,
      outOfStockProducts: json['outOfStockProducts'] ?? 0,
      totalProduced: json['totalProduced'] ?? 0,
      productionEfficiency: (json['productionEfficiency'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'activeProducts': activeProducts,
      'inactiveProducts': inactiveProducts,
      'lowStockProducts': lowStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'totalProduced': totalProduced,
      'productionEfficiency': productionEfficiency,
    };
  }
}

class TimeSeriesData {
  final DateTime date;
  final double value;
  final String? label;

  TimeSeriesData({
    required this.date,
    required this.value,
    this.label,
  });

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) {
    return TimeSeriesData(
      date: DateTime.parse(json['date']),
      value: (json['value'] ?? 0.0).toDouble(),
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
    };
  }
}
