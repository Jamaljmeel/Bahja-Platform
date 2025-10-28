import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Admin_app/providers/admin_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Admin_app/constants.dart';

class ApprovedServicesScreen extends StatefulWidget {
  const ApprovedServicesScreen({super.key});

  @override
  State<ApprovedServicesScreen> createState() => _ApprovedServicesScreenState();
}

class _ApprovedServicesScreenState extends State<ApprovedServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: kBgColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'الخدمات المقبولة',
            style: GoogleFonts.elMessiri().copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_providers')
              .where('hasOffer', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
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
                      Icons.assignment_turned_in,
                      size: 80,
                      color: kPrimaryColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد خدمات مقبولة حالياً',
                      style: GoogleFonts.elMessiri().copyWith(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'سيتم عرض الخدمات هنا بعد قبولها',
                      style: GoogleFonts.elMessiri().copyWith(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  var service = snapshot.data!.docs[index];
                  var data = service.data() as Map<String, dynamic>;
                  bool isPaused = data['isPaused'] ?? false;

                  return _buildServiceCard(
                    context,
                    service.id,
                    data,
                    isPaused: isPaused,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, String serviceId, Map<String, dynamic> data,
      {required bool isPaused}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isPaused ? Colors.grey[100] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isPaused
                          ? Colors.grey[300]
                          : kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business,
                      color: isPaused ? Colors.grey : kBgColor,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data['companyName'] ?? 'اسم غير معروف',
                              style: GoogleFonts.elMessiri().copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isPaused ? Colors.grey : Colors.black87,
                              ),
                            ),
                            if (isPaused) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kSecondaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'موقف',
                                  style: GoogleFonts.elMessiri().copyWith(
                                    color: kSecondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          data['service'] ?? 'نوع الخدمة غير محدد',
                          style: GoogleFonts.elMessiri().copyWith(
                            fontSize: 14,
                            color:
                                isPaused ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'تفاصيل الخدمة:',
                style: GoogleFonts.elMessiri().copyWith(
                  fontSize: 16,
                  color: isPaused ? Colors.grey : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                data['details'] ?? 'لا يوجد وصف متاح',
                style: GoogleFonts.elMessiri().copyWith(
                  fontSize: 14,
                  color: isPaused ? Colors.grey[500] : Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      icon: isPaused
                          ? Icons.play_circle_filled
                          : Icons.pause_circle_filled,
                      text: isPaused ? "إلغاء التوقيف" : "إيقاف مؤقت",
                      color: isPaused ? Colors.green : kBgColor,
                      onPressed: () =>
                          _togglePauseService(context, serviceId, isPaused),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      icon: Icons.delete,
                      text: "حذف الخدمة",
                      color: Colors.red[500]!,
                      onPressed: () => _deleteService(context, serviceId),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePauseService(
      BuildContext context, String serviceId, bool isCurrentlyPaused) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('service_providers')
          .doc(serviceId);
      final serviceDoc = await docRef.get();
      final serviceData = serviceDoc.data()!;
      final String userId = serviceData['userId'];

      await docRef.update({'isPaused': !isCurrentlyPaused});

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final String? token = userDoc['fcmToken'];

      final title = 'تنبيه بخصوص خدمتك';
      final body = isCurrentlyPaused
          ? 'تم تفعيل خدمتك مرة أخرى'
          : 'تم إيقاف خدمتك مؤقتًا من قبل الإدارة';

      if (token != null && token.isNotEmpty) {
        await sendPushNotification(token: token, title: title, body: body);
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyPaused
                ? 'تم استئناف الخدمة بنجاح'
                : 'تم إيقاف الخدمة مؤقتاً',
            style: GoogleFonts.elMessiri().copyWith(color: Colors.white),
          ),
          backgroundColor: isCurrentlyPaused ? Colors.green : kBgColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء محاولة التعديل',
            style: GoogleFonts.elMessiri().copyWith(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteService(BuildContext context, String serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          textAlign: TextAlign.right,
          'تأكيد الحذف',
          style: GoogleFonts.elMessiri().copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          textAlign: TextAlign.right,
          'هل أنت متأكد أنك تريد حذف هذه الخدمة؟ لا يمكن التراجع عن هذا الإجراء.',
          style: GoogleFonts.elMessiri().copyWith(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Text('إلغاء', style: GoogleFonts.elMessiri().copyWith()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('حذف', style: GoogleFonts.elMessiri().copyWith()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('service_providers')
            .doc(serviceId);
        final serviceDoc = await docRef.get();
        final serviceData = serviceDoc.data()!;
        final String userId = serviceData['userId'];

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final String? token = userDoc['fcmToken'];

        const title = 'تنبيه بخصوص خدمتك';
        const body = 'تم حذف خدمتك من قبل الإدارة';

        if (token != null && token.isNotEmpty) {
          await sendPushNotification(token: token, title: title, body: body);
        }

        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': userId,
          'title': title,
          'body': body,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        await docRef.delete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الخدمة بنجاح',
                style: GoogleFonts.elMessiri().copyWith()),
            backgroundColor: Colors.red[400],
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء محاولة الحذف',
                style: GoogleFonts.elMessiri().copyWith()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
