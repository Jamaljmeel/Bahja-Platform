import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Admin_app/constants.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  final Map<String, double> revenueData;

  const RevenueChart({super.key, required this.revenueData});

  @override
  Widget build(BuildContext context) {
    final fullMonthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    final sortedData = {
      for (int i = 1; i <= 12; i++)
        i.toString().padLeft(2, '0'):
            revenueData[i.toString().padLeft(2, '0')] ?? 0.0
    };
    final entries = sortedData.entries.toList();

    final maxRevenue =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = (maxRevenue / 1000) * 1.2;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 360,
        child: Stack(
          children: [
            /// ✅ الرسم البياني
            BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= fullMonthNames.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              fullMonthNames[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calculateInterval(maxY),
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}k',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black87),
                      ),
                      reservedSize: 30,
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: _calculateInterval(maxY),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(entries.length, (index) {
                  final value = entries[index].value / 1000;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: Colors.blueGrey,
                        width: 18,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.grey.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            // ///  النصوص فوق الأعمدة
            // Positioned.fill(
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 40),
            //     child: LayoutBuilder(
            //       builder: (context, constraints) {
            //         final barCount = entries.length;
            //         final barWidth = constraints.maxWidth / (barCount + 1);
            //         return Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceAround,
            //           children: List.generate(barCount, (index) {
            //             final revenue = entries[index].value;
            //             final kValue = (revenue / 1000).toStringAsFixed(1);
            //             return SizedBox(
            //               width: barWidth,
            //               child: revenue > 0
            //                   ? Align(
            //                       alignment: Alignment.topCenter,
            //                       child: Text(
            //                         '${kValue}k',
            //                         style: const TextStyle(
            //                           fontSize: 10,
            //                           fontWeight: FontWeight.bold,
            //                           color: Colors.black87,
            //                         ),
            //                       ),
            //                     )
            //                   : const SizedBox.shrink(),
            //             );
            //           }),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  double _calculateInterval(double maxY) {
    if (maxY <= 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    if (maxY <= 200) return 20;
    if (maxY <= 500) return 50;
    return 100;
  }
}

double _getMaxY(Map<String, double> data) {
  final max =
      data.values.isEmpty ? 100.0 : data.values.reduce((a, b) => a > b ? a : b);
  return (max * 1.2).ceilToDouble(); // لإعطاء مساحة فوق أعلى عمود
}

double _getYAxisInterval(Map<String, double> data) {
  final max =
      data.values.isEmpty ? 100.0 : data.values.reduce((a, b) => a > b ? a : b);
  return (max / 5).ceilToDouble(); // تقسيم المحور لـ 5 فواصل
}
