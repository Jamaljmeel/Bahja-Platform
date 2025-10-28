import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Admin_app/widgets/stats_charts.dart';

class StatsProvider extends StatelessWidget {
  const StatsProvider({super.key});

  Map<String, double> _fetchMonthlyBookingsRevenue(QuerySnapshot snapshot) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    Map<String, double> revenueData = {};

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;

        // التحقق من حالة الحجز
        final status = data['status']?.toString().trim().toLowerCase() ?? '';
        if (!status.contains('completed')) continue;

        // تحويل السعر النهائي إلى double
        double fullPrice = 0.0;
        if (data['finalPrice'] != null) {
          if (data['finalPrice'] is num) {
            fullPrice = (data['finalPrice'] as num).toDouble();
          } else {
            fullPrice = double.tryParse(data['finalPrice'].toString()) ?? 0.0;
          }
        }

        // التحقق من تاريخ الإنشاء
        final timestamp = data['createdAt'] as Timestamp?;
        if (timestamp == null) continue;

        final date = timestamp.toDate();
        if (date.year != currentYear) continue;

        // إضافة الإيراد لشهره المحدد
        final monthKey = date.month.toString().padLeft(2, '0');
        revenueData[monthKey] =
            (revenueData[monthKey] ?? 0.0) + (fullPrice * 0.1);
      } catch (e) {
        debugPrint('Error processing document ${doc.id}: $e');
      }
    }

    // إضافة الأشهر الفارغة حتى الشهر الحالي
    for (int i = 1; i <= currentMonth; i++) {
      final monthKey = i.toString().padLeft(2, '0');
      revenueData.putIfAbsent(monthKey, () => 0.0);
    }

    return revenueData;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('لا توجد بيانات متاحة'));
        }

        final revenueData = _fetchMonthlyBookingsRevenue(snapshot.data!);
        return RevenueChart(revenueData: revenueData);
      },
    );
  }
}
