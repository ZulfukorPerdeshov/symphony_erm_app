import '../models/dashboard_metrics.dart';
import '../models/production.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class DashboardService {
  static Future<DashboardMetrics> getDashboardMetrics({
    required String companyId,
    required DatePeriod period,
  }) async {
    final dateRange = _getDateRange(period);

    try {
      // Получаем данные параллельно
      final results = await Future.wait([
        _getTaskMetrics(companyId, dateRange['start']!, dateRange['end']!),
        _getOrderMetrics(companyId, dateRange['start']!, dateRange['end']!),
        _getProductMetrics(companyId, dateRange['start']!, dateRange['end']!),
        _getTasksTrend(companyId, dateRange['start']!, dateRange['end']!, period),
        _getOrdersTrend(companyId, dateRange['start']!, dateRange['end']!, period),
        _getProductsTrend(companyId, dateRange['start']!, dateRange['end']!, period),
      ]);

      return DashboardMetrics(
        tasks: results[0] as TaskMetrics,
        orders: results[1] as OrderMetrics,
        products: results[2] as ProductMetrics,
        tasksTrend: results[3] as List<TimeSeriesData>,
        ordersTrend: results[4] as List<TimeSeriesData>,
        productsTrend: results[5] as List<TimeSeriesData>,
        period: period,
        startDate: dateRange['start']!,
        endDate: dateRange['end']!,
      );
    } catch (e) {
      print('Error fetching dashboard metrics: $e');
      return DashboardMetrics.empty();
    }
  }

  static Map<String, DateTime> _getDateRange(DatePeriod period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (period) {
      case DatePeriod.day:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        break;
      case DatePeriod.week:
        final weekday = now.weekday;
        start = DateTime(now.year, now.month, now.day - weekday + 1, 0, 0, 0);
        break;
      case DatePeriod.month:
        start = DateTime(now.year, now.month, 1, 0, 0, 0);
        break;
      case DatePeriod.year:
        start = DateTime(now.year, 1, 1, 0, 0, 0);
        break;
    }

    return {'start': start, 'end': end};
  }

  static Future<TaskMetrics> _getTaskMetrics(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await ApiService.get(
        ApiConstants.productionServiceBaseUrl,
        '/api/tasks/metrics',
        queryParameters: {
          'companyId': companyId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response != null && response['data'] != null) {
        return TaskMetrics.fromJson(response['data']);
      }

      // Fallback: calculate from task list if API endpoint doesn't exist
      return await _calculateTaskMetricsFromList(companyId, startDate, endDate);
    } catch (e) {
      print('Error fetching task metrics: $e');
      return await _calculateTaskMetricsFromList(companyId, startDate, endDate);
    }
  }

  static Future<TaskMetrics> _calculateTaskMetricsFromList(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await ApiService.get(
        ApiConstants.productionServiceBaseUrl,
        ApiConstants.productionTasksListEndpoint(companyId),
        queryParameters: {
          'skip': 0,
          'take': 1000,
        },
      );

      if (response == null || response['data'] == null) {
        return TaskMetrics.empty();
      }

      final tasks = (response['data'] as List)
          .map((json) => MyProductionTaskDto.fromJson(json))
          .where((task) {
            if (task.createdAt.isBefore(startDate) || task.createdAt.isAfter(endDate)) {
              return false;
            }
            return true;
          })
          .toList();

      final total = tasks.length;
      final completed = tasks.where((t) => t.status == 2).length;
      final inProgress = tasks.where((t) => t.status == 1).length;
      final notStarted = tasks.where((t) => t.status == 0).length;
      final cancelled = tasks.where((t) => t.status == 3).length;
      final overdue = tasks.where((t) => t.isOverdue).length;
      final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

      // Calculate average completion time
      double avgCompletionTime = 0.0;
      final completedTasks = tasks.where((t) => t.actualStartDate != null && t.actualEndDate != null).toList();
      if (completedTasks.isNotEmpty) {
        final totalHours = completedTasks.fold<double>(0.0, (sum, task) {
          final duration = task.actualEndDate!.difference(task.actualStartDate!);
          return sum + duration.inHours.toDouble();
        });
        avgCompletionTime = totalHours / completedTasks.length;
      }

      return TaskMetrics(
        total: total,
        completed: completed,
        inProgress: inProgress,
        notStarted: notStarted,
        cancelled: cancelled,
        overdue: overdue,
        completionRate: completionRate,
        averageCompletionTime: avgCompletionTime,
      );
    } catch (e) {
      print('Error calculating task metrics: $e');
      return TaskMetrics.empty();
    }
  }

  static Future<OrderMetrics> _getOrderMetrics(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await ApiService.get(
        ApiConstants.orderServiceBaseUrl,
        '/api/orders/metrics/daterange',
        queryParameters: {
          'companyId': companyId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response != null && response['data'] != null) {
        return OrderMetrics.fromJson(response['data']);
      }

      // Fallback: calculate from order list
      return await _calculateOrderMetricsFromList(companyId, startDate, endDate);
    } catch (e) {
      print('Error fetching order metrics: $e');
      return await _calculateOrderMetricsFromList(companyId, startDate, endDate);
    }
  }

  static Future<OrderMetrics> _calculateOrderMetricsFromList(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await ApiService.get(
        ApiConstants.orderServiceBaseUrl,
        '/api/orders/metrics',
        queryParameters: {
          'companyId': companyId,
          'skip': 0,
          'take': 1000,
        },
      );

      if (response == null || response['data'] == null) {
        return OrderMetrics.empty();
      }

      // The /api/orders/metrics endpoint returns metrics directly, not a list
      return OrderMetrics.fromJson(response['data']);
    } catch (e) {
      print('Error calculating order metrics: $e');
      return OrderMetrics.empty();
    }
  }

  static Future<ProductMetrics> _getProductMetrics(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await ApiService.get(
        ApiConstants.inventoryServiceBaseUrl,
        '/api/products/metrics',
        queryParameters: {
          'companyId': companyId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response != null && response['data'] != null) {
        return ProductMetrics.fromJson(response['data']);
      }

      // Fallback: return empty metrics
      return ProductMetrics.empty();
    } catch (e) {
      print('Error fetching product metrics: $e');
      return ProductMetrics.empty();
    }
  }

  static Future<List<TimeSeriesData>> _getTasksTrend(
    String companyId,
    DateTime startDate,
    DateTime endDate,
    DatePeriod period,
  ) async {
    try {
      final response = await ApiService.get(
        ApiConstants.productionServiceBaseUrl,
        '/api/tasks/trend',
        queryParameters: {
          'companyId': companyId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'period': period.name,
        },
      );

      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => TimeSeriesData.fromJson(json))
            .toList();
      }

      return _generateMockTrendData(startDate, endDate, period);
    } catch (e) {
      print('Error fetching tasks trend: $e');
      return _generateMockTrendData(startDate, endDate, period);
    }
  }

  static Future<List<TimeSeriesData>> _getOrdersTrend(
    String companyId,
    DateTime startDate,
    DateTime endDate,
    DatePeriod period,
  ) async {
    try {
      final response = await ApiService.get(
        ApiConstants.orderServiceBaseUrl,
        '/api/orders/trend',
        queryParameters: {
          'companyId': companyId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'period': period.name,
        },
      );

      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => TimeSeriesData.fromJson(json))
            .toList();
      }

      return _generateMockTrendData(startDate, endDate, period);
    } catch (e) {
      print('Error fetching orders trend: $e');
      return _generateMockTrendData(startDate, endDate, period);
    }
  }

  static Future<List<TimeSeriesData>> _getProductsTrend(
    String companyId,
    DateTime startDate,
    DateTime endDate,
    DatePeriod period,
  ) async {
    try {
      final response = await ApiService.get(
        ApiConstants.inventoryServiceBaseUrl,
        '/api/products/production-trend',
        queryParameters: {
          'companyId': companyId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'period': period.name,
        },
      );

      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => TimeSeriesData.fromJson(json))
            .toList();
      }

      return _generateMockTrendData(startDate, endDate, period);
    } catch (e) {
      print('Error fetching products trend: $e');
      return _generateMockTrendData(startDate, endDate, period);
    }
  }

  static List<TimeSeriesData> _generateMockTrendData(
    DateTime startDate,
    DateTime endDate,
    DatePeriod period,
  ) {
    final dataPoints = <TimeSeriesData>[];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dataPoints.add(TimeSeriesData(
        date: currentDate,
        value: 0.0,
      ));

      switch (period) {
        case DatePeriod.day:
          currentDate = currentDate.add(const Duration(hours: 1));
          break;
        case DatePeriod.week:
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case DatePeriod.month:
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case DatePeriod.year:
          // Add one month, handling year rollover properly
          int newMonth = currentDate.month + 1;
          int newYear = currentDate.year;
          if (newMonth > 12) {
            newMonth = 1;
            newYear++;
          }
          currentDate = DateTime(newYear, newMonth, 1);
          break;
      }

      if (dataPoints.length >= 30) break; // Limit data points
    }

    return dataPoints;
  }
}
