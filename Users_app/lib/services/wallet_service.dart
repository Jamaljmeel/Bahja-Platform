import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إنشاء محفظة جديدة
  Future<void> createWallet(String userId, String pin) async {
    try {
      final hashedPin = _hashPin(pin);

      await _firestore.collection('wallets').doc(userId).set({
        'userId': userId,
        'pin': hashedPin,
        'balance': 0.0,
        'reservedBalance': 0.0, // الرصيد المحجوز للحجوزات
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في إنشاء المحفظة: $e');
    }
  }

  // التحقق من وجود المحفظة
  Future<bool> checkWalletExists(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // التحقق من صحة الرمز التعريفي
  Future<bool> verifyPin(String userId, String pin) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final storedHashedPin = data['pin'];
      final hashedPin = _hashPin(pin);

      return storedHashedPin == hashedPin;
    } catch (e) {
      throw Exception('خطأ في التحقق من الرمز: $e');
    }
  }

  // جلب رصيد المحفظة
  Future<double> getBalance(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (!doc.exists) return 0.0;

      final data = doc.data() as Map<String, dynamic>;
      return (data['balance'] ?? 0.0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  // جلب الرصيد المحجوز
  Future<double> getReservedBalance(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (!doc.exists) return 0.0;

      final data = doc.data() as Map<String, dynamic>;
      return (data['reservedBalance'] ?? 0.0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  // جلب الرصيد المتاح (الرصيد - المحجوز)
  Future<double> getAvailableBalance(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (!doc.exists) return 0.0;

      final data = doc.data() as Map<String, dynamic>;
      final balance = (data['balance'] ?? 0.0).toDouble();
      final reserved = (data['reservedBalance'] ?? 0.0).toDouble();
      return balance - reserved;
    } catch (e) {
      return 0.0;
    }
  }

  // شحن المحفظة
  Future<void> chargeWallet(String userId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final walletRef = _firestore.collection('wallets').doc(userId);
        final walletDoc = await transaction.get(walletRef);

        if (!walletDoc.exists) {
          throw Exception('المحفظة غير موجودة');
        }

        final currentBalance = (walletDoc.data()!['balance'] ?? 0.0).toDouble();
        final newBalance = currentBalance + amount;

        transaction.update(walletRef, {
          'balance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final transactionRef =
            _firestore.collection('wallet_transactions').doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'type': 'charge',
          'amount': amount,
          'description': 'شحن المحفظة من بنك الكريمي',
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': newBalance,
        });
      });
    } catch (e) {
      throw Exception('خطأ في شحن المحفظة: $e');
    }
  }

  // حجز مبلغ للحجز
  Future<void> reserveAmountForBooking({
    required String userId,
    required double amount,
    required String bookingId,
    required String description,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final walletRef = _firestore.collection('wallets').doc(userId);
        final transactionRef =
            _firestore.collection('wallet_transactions').doc();

        final walletDoc = await transaction.get(walletRef);

        if (!walletDoc.exists) {
          throw Exception('المحفظة غير موجودة');
        }

        final data = walletDoc.data()!;
        final currentBalance = (data['balance'] ?? 0.0).toDouble();
        final currentReserved = (data['reservedBalance'] ?? 0.0).toDouble();
        final availableBalance = currentBalance - currentReserved;

        if (availableBalance < amount) {
          throw Exception('رصيد المحفظة غير كافي');
        }

        final newReserved = currentReserved + amount;

        transaction.update(walletRef, {
          'reservedBalance': newReserved,
          'balance': currentBalance - amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.set(transactionRef, {
          'userId': userId,
          'type': 'reserve',
          'amount': amount,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': currentBalance,
          'reservedAfter': newReserved,
          'relatedBookingId': bookingId,
        });
      });
    } catch (e) {
      throw Exception('خطأ في حجز المبلغ: $e');
    }
  }

  // إلغاء حجز المبلغ (عند الإلغاء أو الرفض)
Future<void> transferReservedAmountToProvider({
  required String fromUserId,
  required String toProviderId,
  required double amount,
  required String bookingId,
  required String description,
}) async {
  final batch = _firestore.batch();
  
  try {
    // 1. تقليل الرصيد المحجوز للمستخدم
    final userWalletRef = _firestore.collection('wallets').doc(fromUserId);
    batch.update(userWalletRef, {
      'reservedBalance': FieldValue.increment(-amount),
    });
    
    // 2. زيادة رصيد مقدم الخدمة
    final providerWalletRef = _firestore.collection('wallets').doc(toProviderId);
    batch.update(providerWalletRef, {
      'balance': FieldValue.increment(amount),
    });
    
    // 3. إضافة سجل للمعاملة
    final transactionRef = _firestore.collection('transactions').doc();
    batch.set(transactionRef, {
      'fromUserId': fromUserId,
      'toUserId': toProviderId,
      'amount': amount,
      'type': 'booking_transfer',
      'bookingId': bookingId,
      'description': description,
      'timestamp': Timestamp.now(),
    });
    
    await batch.commit();
  } catch (e) {
    throw Exception('فشل في تحويل المبلغ: $e');
  }
}

Future<void> returnReservedAmount({
  required String userId,
  required double amount,
  required String bookingId,
  required String description,
}) async {
  final batch = _firestore.batch();
  
  try {
    // 1. إرجاع المبلغ من المحجوز إلى المتاح
    final walletRef = _firestore.collection('wallets').doc(userId);
    batch.update(walletRef, {
      'balance': FieldValue.increment(amount),
      'reservedBalance': FieldValue.increment(-amount),
    });
    
    // 2. إضافة سجل للمعاملة
    final transactionRef = _firestore.collection('transactions').doc();
    batch.set(transactionRef, {
      'userId': userId,
      'amount': amount,
      'type': 'booking_refund',
      'bookingId': bookingId,
      'description': description,
      'timestamp': Timestamp.now(),
    });
    
    await batch.commit();
  } catch (e) {
    throw Exception('فشل في إرجاع المبلغ: $e');
  }
}

  // تغيير رمز المحفظة
  Future<void> changePin(String userId, String oldPin, String newPin) async {
    try {
      final isValidOldPin = await verifyPin(userId, oldPin);
      if (!isValidOldPin) {
        throw Exception('الرمز القديم غير صحيح');
      }

      final hashedNewPin = _hashPin(newPin);

      await _firestore.collection('wallets').doc(userId).update({
        'pin': hashedNewPin,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في تغيير الرمز: $e');
    }
  }

  // جلب سجل المعاملات
  Stream<List<Map<String, dynamic>>> getTransactionHistory(String userId) {
    return _firestore
        .collection('wallet_transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        // تأكد من وجود البيانات وتحويلها إلى Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        // إضافة معرف المستند إذا لزم الأمر
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // تشفير الرمز التعريفي
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
