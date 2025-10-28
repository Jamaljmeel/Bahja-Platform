import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import '../../services/wallet_service.dart';

class BookingDialogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WalletService _walletService = WalletService();
  final String serviceAccountPath = 'asset/config/service-account.json';

  // جلب userId الخاص بمقدم الخدمة
  Future<String?> getProviderUserId(String providerId) async {
    try {
      final providerDoc = await _firestore
          .collection('service_providers')
          .doc(providerId)
          .get();
      
      if (providerDoc.exists) {
        final data = providerDoc.data();
        return data?['userId'];
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في الحصول على بيانات مقدم الخدمة: $e');
    }
  }

  // جلب التواريخ المحجوزة
  Future<Set<DateTime>> getBookedDates(String providerId) async {
    try {
      final providerDoc = await _firestore
          .collection('service_providers')
          .doc(providerId)
          .get();

      Set<DateTime> bookedDates = {};
      if (providerDoc.exists) {
        final data = providerDoc.data();
        final bookedDays = data?['bookedDays'] as List<dynamic>?;
        
        if (bookedDays != null) {
          for (var dateString in bookedDays) {
            try {
              final date = DateTime.parse(dateString.toString());
              bookedDates.add(DateTime(date.year, date.month, date.day));
            } catch (e) {
              print('خطأ في تحليل التاريخ: $dateString');
            }
          }
        }
      }
      return bookedDates;
    } catch (e) {
      throw Exception('خطأ في جلب التواريخ المحجوزة: $e');
    }
  }

  // التحقق من إذا كان التاريخ محجوز
  bool isDateBooked(DateTime date, Set<DateTime> bookedDates) {
    return bookedDates.any((bookedDate) =>
        bookedDate.year == date.year &&
        bookedDate.month == date.month &&
        bookedDate.day == date.day);
  }

  // التحقق من الرصيد المتاح للمستخدم
  Future<bool> checkUserBalance(String userId, double amount) async {
    try {
      final availableBalance = await _walletService.getAvailableBalance(userId);
      return availableBalance >= amount;
    } catch (e) {
      print('خطأ في التحقق من الرصيد: $e');
      return false;
    }
  }

  // إنشاء الحجز مع حجز المبلغ
  Future<Map<String, dynamic>> createBooking({
    required String providerId,
    required Map<String, dynamic> serviceData,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String paymentMethod,
    required String notes,
    required double reservedAmount, // المبلغ المراد حجزه (كامل أو جزئي)
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('يرجى تسجيل الدخول أولاً');
      }

      final providerUserId = await getProviderUserId(providerId);
      if (providerUserId == null) {
        throw Exception('خطأ في العثور على بيانات مقدم الخدمة');
      }

      final totalPrice = (serviceData['finalPrice'] ?? serviceData['priceFrom'] ?? 0).toDouble();

      // التحقق من الرصيد
      final hasEnoughBalance = await checkUserBalance(user.uid, reservedAmount);
      if (!hasEnoughBalance) {
        return {
          'success': false,
          'message': 'رصيد المحفظة غير كافي. يرجى شحن المحفظة أولاً.',
          'type': 'insufficient_balance'
        };
      }

      // 1. إنشاء مستند الحجز أولاً
      final bookingRef = _firestore.collection('bookings').doc();
      
      final bookingData = {
        'userId': user.uid,
        'providerId': providerUserId,
        'serviceName': serviceData['companyName'],
        'serviceType': serviceData['service'],
        'totalPrice': totalPrice,
        'reservedAmount': reservedAmount,
        'remainingAmount': totalPrice - reservedAmount,
        'paymentMethod': paymentMethod,
        'isPartialPayment': paymentMethod == 'partial_wallet',
        'bookingDate': Timestamp.now(),
        'eventDate': Timestamp.fromDate(DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        )),
        'status': 'pending',
        'notes': notes,
        'providerImage': serviceData['companyLogo'],
        'createdAt': Timestamp.now(),
      };

      await bookingRef.set(bookingData);

      // 2. حجز المبلغ في المحفظة
      if (reservedAmount > 0) {
        try {
          final description = paymentMethod == 'partial_wallet'
              ? 'حجز قسط من مبلغ خدمة ${serviceData['companyName']}'
              : 'حجز مبلغ خدمة ${serviceData['companyName']}';
              
          await _walletService.reserveAmountForBooking(
            userId: user.uid,
            amount: reservedAmount,
            bookingId: bookingRef.id,
            description: description,
          );
        } catch (walletError) {
          // إذا فشل حجز المبلغ، احذف الحجز المُنشأ
          await bookingRef.delete();
          throw Exception('فشل في حجز المبلغ: $walletError');
        }
      }

      // 3. إرسال إشعار لمقدم الخدمة
      try {
        await _sendNotificationToProvider(
          providerUserId: providerUserId,
          serviceName: serviceData['companyName'],
          bookingId: bookingRef.id,
          totalAmount: totalPrice,
          reservedAmount: reservedAmount,
          isPartialPayment: paymentMethod == 'partial_wallet',
        );
      } catch (notificationError) {
        print('فشل في إرسال الإشعار: $notificationError');
        // لا نلغي الحجز إذا فشل الإشعار
      }

      // رسالة النجاح حسب نوع الدفع
      String successMessage;
      if (paymentMethod == 'partial_wallet') {
        final remainingAmount = totalPrice - reservedAmount;
        successMessage = 'تم إنشاء الحجز بنجاح وحجز قسط ${reservedAmount.toStringAsFixed(0)} ريال من إجمالي ${totalPrice.toStringAsFixed(0)} ريال';
      } else {
        successMessage = 'تم إنشاء الحجز بنجاح وحجز المبلغ كاملاً ${reservedAmount.toStringAsFixed(0)} ريال';
      }

      return {
        'success': true,
        'message': successMessage,
        'bookingId': bookingRef.id,
        'type': 'success'
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الحجز: $e',
        'type': 'error'
      };
    }
  }

  // إرسال إشعار لمقدم الخدمة
  Future<void> _sendNotificationToProvider({
    required String providerUserId,
    required String serviceName,
    required String bookingId,
    required double totalAmount,
    required double reservedAmount,
    required bool isPartialPayment,
  }) async {
    try {
      // جلب FCM token لمقدم الخدمة
      final userDoc = await _firestore.collection('users').doc(providerUserId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        final fcmToken = userData?['fcmToken'];
        
        if (fcmToken != null) {
          String notificationBody;
          if (isPartialPayment) {
            final remainingAmount = totalAmount - reservedAmount;
            notificationBody = 'لديك طلب حجز جديد لخدمة $serviceName - تم حجز قسط ${reservedAmount.toStringAsFixed(0)} ريال من إجمالي ${totalAmount.toStringAsFixed(0)} ريال المتبقي ${remainingAmount.toStringAsFixed(0)} ر.س';
          } else {
            notificationBody = 'لديك طلب حجز جديد لخدمة $serviceName وتم حجز المبلغ كاملاً ${reservedAmount.toStringAsFixed(0)} ريال وسيتم تحويله لمحفظتك عند الموافقة على الحجز';
          }
          
          await sendPushNotification(
            token: fcmToken,
            title: 'طلب حجز جديد',
            body: notificationBody,
            bookingId: bookingId,
          );
        }
      }
    } catch (e) {
      print('خطأ في إرسال إشعار لمقدم الخدمة: $e');
      throw e;
    }
  }

  // حساب السعر بعد الخصم
  double calculateDiscountedPrice(Map<String, dynamic> serviceData) {
    final price = (serviceData['finalPrice'] ?? 
                 serviceData['priceFrom'] ?? 
                 0).toDouble();
    final discount = (serviceData['discount'] ?? 0).toDouble();
    return discount > 0 ? price * (1 - discount / 100) : price;
  }

  // الحصول على معلومات الخدمة للعرض
  Map<String, dynamic> getServiceDisplayInfo(Map<String, dynamic> serviceData) {
    final price = (serviceData['finalPrice'] ?? 
                 serviceData['priceFrom'] ?? 
                 0).toDouble();
    final discount = (serviceData['discount'] ?? 0).toDouble();
    
    return {
      'serviceName': serviceData['companyName'] ?? 'غير محدد',
      'serviceType': serviceData['service'] ?? 'غير محدد',
      'location': '${serviceData['region'] ?? ''}, ${serviceData['province'] ?? ''}',
      'originalPrice': price,
      'discount': discount,
      'finalPrice': calculateDiscountedPrice(serviceData),
    };
  }

  // التحقق من صحة بيانات الحجز
  Map<String, dynamic> validateBookingData({
    required DateTime? selectedDate,
    required Set<DateTime> bookedDates,
    required String notes,
  }) {
    if (selectedDate == null) {
      return {
        'isValid': false,
        'message': 'يرجى اختيار تاريخ ووقت المناسبة',
        'color': 'orange',
      };
    }

    if (isDateBooked(selectedDate, bookedDates)) {
      return {
        'isValid': false,
        'message': 'هذا التاريخ محجوز مسبقاً، يرجى اختيار تاريخ آخر',
        'color': 'red',
      };
    }

    return {'isValid': true};
  }

  // التحقق من صحة طريقة الدفع مع الرصيد
  Future<Map<String, dynamic>> validatePaymentMethod({
    required String paymentMethod,
    required String userId,
    required double amount,
  }) async {
    if (paymentMethod == 'wallet' || paymentMethod == 'partial_wallet') {
      try {
        final hasEnoughBalance = await checkUserBalance(userId, amount);
        if (!hasEnoughBalance) {
          final currentBalance = await _walletService.getAvailableBalance(userId);
          return {
            'isValid': false,
            'message': 'رصيد المحفظة غير كافي. الرصيد المتاح: ${currentBalance.toStringAsFixed(0)} ريال',
            'color': 'red',
            'type': 'insufficient_balance'
          };
        }
      } catch (e) {
        return {
          'isValid': false,
          'message': 'خطأ في التحقق من رصيد المحفظة',
          'color': 'red',
          'type': 'wallet_error'
        };
      }
    }

    return {'isValid': true};
  }

  // جلب الرصيد المتاح للعرض في واجهة المستخدم
  Future<double> getUserAvailableBalance(String userId) async {
    try {
      return await _walletService.getAvailableBalance(userId);
    } catch (e) {
      print('خطأ في جلب الرصيد المتاح: $e');
      return 0.0;
    }
  }

  // جلب الرصيد المحجوز للعرض في واجهة المستخدم
  Future<double> getUserReservedBalance(String userId) async {
    try {
      return await _walletService.getReservedBalance(userId);
    } catch (e) {
      print('خطأ في جلب الرصيد المحجوز: $e');
      return 0.0;
    }
  }

  Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
    String? bookingId,
  }) async {
    try {
      // 1. تحميل بيانات Service Account
      final jsonString = await rootBundle.loadString(serviceAccountPath);
      final serviceAccountJson = json.decode(jsonString) as Map<String, dynamic>;
      
      // 2. إنشاء مصادقة
      final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final authClient = await clientViaServiceAccount(accountCredentials, scopes);

      // 3. إعداد رسالة FCM
      final projectId = serviceAccountJson['project_id'];
      final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
      
      final message = {
        "message": {
          "token": token,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "type": "booking_update",
            if (bookingId != null) "booking_id": bookingId,
          }
        }
      };

      // 4. إرسال الطلب
      final response = await authClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message),
      );

      // 5. التحقق من الاستجابة
      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.statusCode}');
      }

      print('تم إرسال الإشعار بنجاح إلى $token');
    } catch (e) {
      print('حدث خطأ أثناء إرسال الإشعار: $e');
      throw Exception('فشل في إرسال الإشعار: $e');
    }
  }
}