import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/dashboard_metrics.dart';
import '../../services/dashboard_service.dart';
import '../../services/company_service.dart';
import '../../utils/constants.dart';
import '../../widgets/circular_back_button.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  DatePeriod _selectedPeriod = DatePeriod.day;
  DashboardMetrics? _metrics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);

    try {
      final companyId = CompanyService.getCurrentCompanyIdOrThrow();
      final metrics = await DashboardService.getDashboardMetrics(
        companyId: companyId,
        period: _selectedPeriod,
      );

      setState(() {
        _metrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingData}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        leading: const CircularBackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMetrics,
        child: _isLoading && _metrics == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period Selector
                      _buildPeriodSelector(l10n),
                      const SizedBox(height: 20),

                      if (_metrics != null) ...[
                        // Date Range Info
                        _buildDateRangeInfo(l10n, _metrics!),
                        const SizedBox(height: 20),

                        // Task Metrics Section
                        _buildSectionHeader(l10n.tasks, theme),
                        const SizedBox(height: 12),
                        _buildTaskMetricsCard(_metrics!.tasks, l10n),
                        const SizedBox(height: 16),
                        _buildTasksChart(_metrics!.tasksTrend, l10n, theme),
                        const SizedBox(height: 24),

                        // Order Metrics Section
                        _buildSectionHeader(l10n.orders, theme),
                        const SizedBox(height: 12),
                        _buildOrderMetricsCard(_metrics!.orders, l10n),
                        const SizedBox(height: 16),
                        _buildOrdersChart(_metrics!.ordersTrend, l10n, theme),
                        const SizedBox(height: 24),

                        // Product Metrics Section
                        _buildSectionHeader(l10n.products, theme),
                        const SizedBox(height: 12),
                        _buildProductMetricsCard(_metrics!.products, l10n),
                        const SizedBox(height: 16),
                        _buildProductsChart(_metrics!.productsTrend, l10n, theme),
                        const SizedBox(height: 24),
                      ] else
                        Center(
                          child: Text(
                            l10n.noDataAvailable,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(child: _buildPeriodButton('Day', DatePeriod.day)),
            const SizedBox(width: 8),
            Expanded(child: _buildPeriodButton('Week', DatePeriod.week)),
            const SizedBox(width: 8),
            Expanded(child: _buildPeriodButton('Month', DatePeriod.month)),
            const SizedBox(width: 8),
            Expanded(child: _buildPeriodButton('Year', DatePeriod.year)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, DatePeriod period) {
    final isSelected = _selectedPeriod == period;
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedPeriod = period);
        _loadMetrics();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(AppColors.primaryIndigo) : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDateRangeInfo(AppLocalizations l10n, DashboardMetrics metrics) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppColors.primaryIndigo).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(AppColors.primaryIndigo).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Color(AppColors.primaryIndigo)),
          const SizedBox(width: 8),
          Text(
            '${dateFormat.format(metrics.startDate)} - ${dateFormat.format(metrics.endDate)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(AppColors.primaryIndigo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryIndigo),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskMetricsCard(TaskMetrics metrics, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    l10n.total,
                    metrics.total.toString(),
                    Icons.assignment_outlined,
                    const Color(AppColors.primaryIndigo),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    l10n.completed,
                    metrics.completed.toString(),
                    Icons.check_circle_outline,
                    const Color(AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    l10n.inProgress,
                    metrics.inProgress.toString(),
                    Icons.hourglass_bottom,
                    const Color(AppColors.info),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Overdue',
                    metrics.overdue.toString(),
                    Icons.warning_amber_outlined,
                    const Color(AppColors.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatInfo(
                  'Completion Rate',
                  '${metrics.completionRate.toStringAsFixed(1)}%',
                  const Color(AppColors.success),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                _buildStatInfo(
                  'Avg. Time',
                  '${metrics.averageCompletionTime.toStringAsFixed(1)}h',
                  const Color(AppColors.info),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderMetricsCard(OrderMetrics metrics, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    l10n.total,
                    metrics.total.toString(),
                    Icons.shopping_cart_outlined,
                    const Color(AppColors.primaryIndigo),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Completed',
                    metrics.completed.toString(),
                    Icons.check_circle_outline,
                    const Color(AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Processing',
                    metrics.processing.toString(),
                    Icons.sync,
                    const Color(AppColors.info),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Pending',
                    metrics.pending.toString(),
                    Icons.pending_outlined,
                    const Color(AppColors.warning),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatInfo(
                  'Total Revenue',
                  metrics.formattedTotalRevenue,
                  const Color(AppColors.success),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                _buildStatInfo(
                  'Avg. Order',
                  metrics.formattedAverageOrderValue,
                  const Color(AppColors.info),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductMetricsCard(ProductMetrics metrics, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    l10n.total,
                    metrics.totalProducts.toString(),
                    Icons.inventory_2_outlined,
                    const Color(AppColors.primaryIndigo),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Active',
                    metrics.activeProducts.toString(),
                    Icons.check_circle_outline,
                    const Color(AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Low Stock',
                    metrics.lowStockProducts.toString(),
                    Icons.warning_amber_outlined,
                    const Color(AppColors.warning),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Out of Stock',
                    metrics.outOfStockProducts.toString(),
                    Icons.error_outline,
                    const Color(AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTasksChart(List<TimeSeriesData> data, AppLocalizations l10n, ThemeData theme) {
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        child: Container(
          height: 250,
          alignment: Alignment.center,
          child: Text(l10n.noDataAvailable),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks Trend',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 10 ? (data.length / 7).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _formatChartDate(data[index].date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: const Color(AppColors.primaryIndigo),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: data.length <= 10,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: const Color(AppColors.primaryIndigo),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(AppColors.primaryIndigo).withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersChart(List<TimeSeriesData> data, AppLocalizations l10n, ThemeData theme) {
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        child: Container(
          height: 250,
          alignment: Alignment.center,
          child: Text(l10n.noDataAvailable),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders Trend',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(data) * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _formatChartDate(data[index].date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: const Color(AppColors.accentCyan),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsChart(List<TimeSeriesData> data, AppLocalizations l10n, ThemeData theme) {
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        child: Container(
          height: 250,
          alignment: Alignment.center,
          child: Text(l10n.noDataAvailable),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Production Trend',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 10 ? (data.length / 7).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _formatChartDate(data[index].date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: const Color(AppColors.success),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: data.length <= 10,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: const Color(AppColors.success),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(AppColors.success).withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatChartDate(DateTime date) {
    switch (_selectedPeriod) {
      case DatePeriod.day:
        return DateFormat('HH:mm').format(date);
      case DatePeriod.week:
        return DateFormat('EEE').format(date);
      case DatePeriod.month:
        return DateFormat('dd').format(date);
      case DatePeriod.year:
        return DateFormat('MMM').format(date);
    }
  }

  double _getMaxValue(List<TimeSeriesData> data) {
    if (data.isEmpty) return 10.0;
    return data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }
}
