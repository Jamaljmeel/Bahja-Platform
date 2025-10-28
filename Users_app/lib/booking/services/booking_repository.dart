import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/wallet_service.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WalletService _walletService = WalletService();

  // جلب الحجوزات الخاصة بالمستخدم
  Stream<QuerySnapshot> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots();
  }

  // فلترة الحجوزات حسب الحالة
  List<QueryDocumentSnapshot> filterBookingsByStatus(
    List<QueryDocumentSnapshot> bookings,
    String selectedFilter,
  ) {
    if (selectedFilter == 'all') return bookings;

    return bookings.where((booking) {
      final status = (booking.data() as Map<String, dynamic>)['status'] ?? 'pending';
      return status == selectedFilter;
    }).toList();
  }



  // إلغاء الحجز مع إرجاع المبلغ المحجوز
  Future<void> cancelBooking(String bookingId) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      
      if (!bookingDoc.exists) {
        throw Exception('الحجز غير موجود');
      }
      
      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final userId = bookingData['userId'];
      final reservedAmount = bookingData['reservedAmount'].toDouble();
      final paymentMethod = bookingData['paymentMethod'] ?? '';
      
      // تحديث حالة الحجز
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // إرجاع المبلغ المحجوز إذا كان الدفع من المحفظة
    
        await _walletService.returnReservedAmount(
          userId: userId,
          amount: reservedAmount,
          bookingId: bookingId,
          description: 'إرجاع مبلغ الحجز الملغى',
        );
        
      
    } catch (e) {
      throw Exception('فشل في إلغاء الحجز: $e');
    }
  }

  // التحقق من حالة تسجيل الدخول
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // الحصول على معلومات الحجز
  Map<String, dynamic> getBookingDetails(Map<String, dynamic> booking) {
    return {
      'bookingDate': (booking['bookingDate'] as Timestamp).toDate(),
      'eventDate': booking['eventDate'] != null 
          ? (booking['eventDate'] as Timestamp).toDate() 
          : null,
      'status': booking['status'] ?? 'pending',
      'serviceName': booking['serviceName'] ?? 'خدمة غير معروفة',
      'serviceType': booking['serviceType'] ?? 'غير محدد',
      'finalPrice': booking['finalPrice'] ?? 0,
      'paymentMethod': booking['paymentMethod'] ?? 'غير محدد',
      'notes': booking['notes'] ?? '',
    };
  }

  // الحصول على لون ونص الحالة
  Map<String, dynamic> getStatusInfo(String status) {
    switch (status) {
      case 'completed':
        return {
          'text': 'تم الموافقة على الحجز',
          'icon': 'check_circle',
          'colors': ['#4CAF50', '#388E3C'],
        };
      case 'rejected':
        return {
          'text': 'تم رفض الحجز',
          'icon': 'cancel',
          'colors': ['#F44336', '#D32F2F'],
        };
      case 'cancelled':
        return {
          'text': 'تم إلغاء الحجز',
          'icon': 'delete',
          'colors': ['#FF9800', '#F57C00'],
        };
      default:
        return {
          'text': 'قيد الانتظار',
          'icon': 'hourglass_empty',
          'colors': ['#2196F3', '#1976D2'],
        };
    }
  }
}