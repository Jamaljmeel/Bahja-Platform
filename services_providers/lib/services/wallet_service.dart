import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String providerUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // إنشاء محفظة جديدة
  Future<void> createWallet(String userId, String pin) async {
    try {
      final hashedPin = _hashPin(pin);
      
      await _firestore.collection('wallets').doc(userId).set({
        'userId': userId,
        'pin': hashedPin,
        'balance': 0.0,
        'reservedBalance': 0.0,
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

  // إلغاء حجز المبلغ للعميل (عند الرفض)
  Future<void> releaseReservedAmount({
    required String userId,
    required double amount,
    required String bookingId,
    required String description,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final walletRef = _firestore.collection('wallets').doc(userId);
        final transactionRef = _firestore.collection('wallet_transactions').doc();

        final walletDoc = await transaction.get(walletRef);

        if (!walletDoc.exists) {
          throw Exception('المحفظة غير موجودة');
        }

        final data = walletDoc.data()!;
        final currentBalance = (data['balance'] ?? 0.0).toDouble();
        final currentReserved = (data['reservedBalance'] ?? 0.0).toDouble();

        if (currentReserved < amount) {
          throw Exception('المبلغ المحجوز أقل من المطلوب إلغاؤه');
        }

        final newReserved = currentReserved - amount;

        transaction.update(walletRef, {
          'reservedBalance': newReserved,
          'balance': currentBalance + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.set(transactionRef, {
          'userId': userId,
          'type': 'release_reserve',
          'amount': amount,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': currentBalance,
          'reservedAfter': newReserved,
          'relatedBookingId': bookingId,
        });
      });
    } catch (e) {
      throw Exception('خطأ في إلغاء حجز المبلغ: $e');
    }
  }

  // تأكيد الحجز وتحويل المبلغ من العميل إلى مقدم الخدمة
  Future<void> confirmBookingPayment({
    required String userId,
    required String providerId,
    required double amount,
    required String bookingId,
    required String description,
  }) async {
    try {

      await _firestore.runTransaction((transaction) async {
        final userWallet = _firestore.collection('wallets').doc(userId);
        final providerWallet = _firestore.collection('wallets').doc(providerUserId);
        final transactionRef = _firestore.collection('transactions').doc();
        final userTransactionRef = _firestore.collection('wallet_transactions').doc();
        final providerTransactionRef = _firestore.collection('wallet_transactions').doc();

        final userSnapshot = await transaction.get(userWallet);
        final providerSnapshot = await transaction.get(providerWallet);

        if (!userSnapshot.exists) throw Exception('محفظة العميل غير موجودة');

        // إنشاء محفظة المزود إذا لم تكن موجودة
        if (!providerSnapshot.exists) {
          transaction.set(providerWallet, {
            'userId': userId,
            'balance': 0.0,
            'reservedBalance': 0.0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        final userData = userSnapshot.data()!;
        final userBalance = (userData['balance'] ?? 0.0).toDouble();
        final userReserved = (userData['reservedBalance'] ?? 0.0).toDouble();
        final providerBalance = (providerSnapshot.exists)
            ? (providerSnapshot.data()!['balance'] ?? 0.0).toDouble()
            : 0.0;

        if (userReserved < amount) {
          throw Exception('المبلغ المحجوز غير كافي');
        }

        // تحديث محفظة العميل (خصم من الرصيد وإلغاء الحجز)
        transaction.update(userWallet, {
          // 'balance': userBalance - amount,
          'reservedBalance': userReserved - amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // تحديث محفظة المزود (إضافة المبلغ)
        transaction.update(providerWallet, {
          'balance': providerBalance + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // سجل التحويل العام
        transaction.set(transactionRef, {
          'fromUserId': userId,
          'toUserId': providerUserId,
          'amount': amount,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'payment_to_provider',
          'relatedBookingId': bookingId,
        });

        // سجل معاملة العميل
        transaction.set(userTransactionRef, {
          'userId': userId,
          'type': 'payment_confirmed',
          'amount': amount,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': userBalance - amount,
          'reservedAfter': userReserved - amount,
          'relatedBookingId': bookingId,
        });

        // سجل معاملة مقدم الخدمة
        transaction.set(providerTransactionRef, {
          'userId': providerUserId,
          'type': 'received_payment',
          'amount': amount,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': providerBalance + amount,
          'relatedBookingId': bookingId,
        });
      });
    } catch (e) {
      throw Exception('فشل تأكيد الدفع: $e');
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
  Stream<QuerySnapshot> getTransactionHistory(String userId) {
    return _firestore
        .collection('wallet_transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  // جلب معاملات مقدم الخدمة (المعاملات الواردة إليه)
  Stream<QuerySnapshot> getProviderTransactions(String providerId) {
    return _firestore
        .collection('transactions')
        .where('toUserId', isEqualTo: providerId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // حساب إجمالي أرباح مقدم الخدمة
  Future<double> getProviderTotalEarnings(String providerId) async {
    try {
      final QuerySnapshot transactions = await _firestore
          .collection('transactions')
          .where('toUserId', isEqualTo: providerId)
          .get();
      
      double totalEarnings = 0.0;
      for (var doc in transactions.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalEarnings += (data['amount'] ?? 0.0).toDouble();
      }
      
      return totalEarnings;
    } catch (e) {
      return 0.0;
    }
  }

  // جلب إحصائيات مقدم الخدمة
  Future<Map<String, dynamic>> getProviderStats(String providerId) async {
    try {
      final QuerySnapshot transactions = await _firestore
          .collection('transactions')
          .where('toUserId', isEqualTo: providerId)
          .get();
      
      double totalEarnings = 0.0;
      int totalTransactions = transactions.docs.length;
      Map<String, double> monthlyEarnings = {};
      
      for (var doc in transactions.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] ?? 0.0).toDouble();
        totalEarnings += amount;
        
        if (data['timestamp'] != null) {
          final date = (data['timestamp'] as Timestamp).toDate();
          final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlyEarnings[monthKey] = (monthlyEarnings[monthKey] ?? 0.0) + amount;
        }
      }
      
      return {
        'totalEarnings': totalEarnings,
        'totalTransactions': totalTransactions,
        'monthlyEarnings': monthlyEarnings,
        'currentBalance': await getBalance(providerId),
      };
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات مقدم الخدمة: $e');
    }
  }

  // تشفير الرمز التعريفي
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}