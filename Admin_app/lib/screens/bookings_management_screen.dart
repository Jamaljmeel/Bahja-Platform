import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Admin_app/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingsManagementScreen extends StatelessWidget {
  const BookingsManagementScreen({super.key});

  final Map<String, String> statusMap = const {
    'pending': 'معلق',
    'completed': 'مكتمل',
    'rejected': 'مرفوض',
    'cancelled': 'ملغي',
  };

  final Map<String, Color> statusColors = const {
    'pending': Colors.orange,
    'completed': Colors.green,
    'rejected': Colors.red,
    'cancelled': Colors.grey,
  };

  Future<String> _getUserNameById(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      return data['username'] ?? 'غير معروف';
    }
    return 'غير معروف';
  }

  Future<String> _getProviderNameById(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('service_providers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      return data['email'] ?? 'غير معروف';
    }
    return 'غير معروف';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: kBgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'إدارة الحجوزات',
            style: GoogleFonts.elMessiri(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ في تحميل البيانات',
                  style: GoogleFonts.elMessiri(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 80,
                      color: kPrimaryColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد حجوزات مسجلة',
                      style: GoogleFonts.elMessiri(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(16),
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  var booking = snapshot.data!.docs[index];
                  var data = booking.data() as Map<String, dynamic>;
                  String dbStatus = data['status'] ?? 'pending';
                  String uiStatus = statusMap[dbStatus] ?? 'غير معروف';
                  Color statusColor = statusColors[dbStatus] ?? Colors.grey;

                  return FutureBuilder<List<String>>(
                    future: Future.wait([
                      _getUserNameById(data['userId'] ?? ''),
                      _getProviderNameById(data['providerId'] ?? '')
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final clientName = snapshot.data![0];
                      final providerName = snapshot.data![1];

                      return _buildBookingCard(data, uiStatus, statusColor,
                          providerName, clientName);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
    String status,
    Color statusColor,
    String providerName,
    String clientName,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(
                //   'حجز #${booking['bookingNumber'] ?? 'غير معروف'}',
                //   style: GoogleFonts.elMessiri(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: kBgColor,
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.elMessiri(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 12),
            _buildInfoRow('الخدمة:', booking['serviceName'] ?? 'غير معروف'),
            _buildInfoRow('نوع الخدمة:', booking['serviceType'] ?? 'غير معروف'),
            // _buildInfoRow('مقدم الخدمة:', providerName),
            _buildInfoRow('العميل:', clientName),
            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المبلغ الإجمالي:',
                  style: GoogleFonts.elMessiri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${booking['finalPrice']?.toString() ?? '0'} ر.ي',
                  style: GoogleFonts.elMessiri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kBgColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.elMessiri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.elMessiri(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
