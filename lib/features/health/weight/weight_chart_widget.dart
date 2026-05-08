import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/weight_record_model.dart';

class WeightChartWidget extends StatelessWidget {
  final List<WeightRecordModel> records;

  const WeightChartWidget({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.length < 2) {
      return const SizedBox.shrink();
    }

    final spots = records.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final minY = records.map((r) => r.weight).reduce((a, b) => a < b ? a : b);
    final maxY = records.map((r) => r.weight).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY) * 0.2 + 0.5;

    final dateFormat = DateFormat('dd/MM');

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yPadding > 1 ? null : 0.5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: records.length > 6 ? (records.length / 4).roundToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= records.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      dateFormat.format(records[index].recordDate),
                      style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: (minY - yPadding).clamp(0, double.infinity),
          maxY: maxY + yPadding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF2ECC71),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF2ECC71),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF2ECC71).withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => Colors.black87,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final record = records[spot.x.toInt()];
                  return LineTooltipItem(
                    '${record.weight} kg\n${dateFormat.format(record.recordDate)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
