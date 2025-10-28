import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bookingsscreen extends StatelessWidget {
  const Bookingsscreen({super.key});

  // خريطة ترجمة من الإنجليزي إلى العربي
  static const Map<String, String> statusMap = {
    'pending': 'معلق',
    'completed': 'مكتمل',
    'rejected': 'مرفوض',
  };

  // دالة لمعالجة البيانات من snapshot
  Map<String, int> _processSnapshot(QuerySnapshot snapshot) {
    Map<String, int> bookingsData = {
      'مكتمل': 0,
      'معلق': 0,
      'مرفوض': 0,
    };

    for (var doc in snapshot.docs) {
      final statusInDb = doc['status'] as String?;
      final translatedStatus = statusMap[statusInDb];
      if (translatedStatus != null &&
          bookingsData.containsKey(translatedStatus)) {
        bookingsData[translatedStatus] = bookingsData[translatedStatus]! + 1;
      }
    }

    return bookingsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد بيانات متاحة'));
          }

          final bookingsData = _processSnapshot(snapshot.data!);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: bookingsData.entries.map((entry) {
                              // تحديد نصف قطر أدنى للشرائح الصغيرة
                              final radius = entry.value > 0 ? 60.0 : 0.0;
                              // إخفاء النص إذا كانت القيمة صغيرة جدًا
                              final showTitle = entry.value > 1;
                              return PieChartSectionData(
                                color: _getColor(entry.key),
                                value: entry.value.toDouble(),
                                title: showTitle
                                    ? '${entry.key}\n${entry.value}'
                                    : '',
                                radius: radius,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // عرض القيم الصغيرة في قائمة أسفل المخطط
                      ...bookingsData.entries
                          .where((entry) => entry.value <= 1 && entry.value > 0)
                          .map(
                            (entry) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _getColor(entry.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${entry.key}: ${entry.value}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Color _getColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'معلق':
        return Colors.orange;
      case 'مرفوض':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
