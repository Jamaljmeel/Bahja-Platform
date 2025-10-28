// qr_scanner_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/qr_scanner_model.dart';

class QrScannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QrCodeData?> parseQrCodeWithData(String code) async {
    try {
      final Map<String, dynamic> decodedData = jsonDecode(code);
      
      // جلب البيانات الحالية من قاعدة البيانات
      final inviteeDocRef = _firestore
          .collection('invitations')
          .doc(decodedData['invitationId'])
          .collection('invitees')
          .where('uuid', isEqualTo: decodedData['inviteeId']);

      final querySnapshot = await inviteeDocRef.get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final inviteeDoc = querySnapshot.docs.first;
        final inviteeData = inviteeDoc.data();
        
        return QrCodeData(
          invitationId: decodedData['invitationId'],
          inviteeId: decodedData['inviteeId'],
          eventName: decodedData['eventName'] ?? 'غير معروف',
          inviteeName: decodedData['inviteeName'] ?? 'غير معروف',
          numberOfPeople: decodedData['numberOfPeople'] ?? 1,
          checkedInCount: inviteeData['checkedInCount'] ?? 0,
        );
      }
      
      return QrCodeData.fromJson(decodedData);
    } catch (e) {
      print('Error decoding QR code: $e');
      return null;
    }
  }

  QrCodeData? parseQrCode(String code) {
    try {
      final Map<String, dynamic> decodedData = jsonDecode(code);
      return QrCodeData.fromJson(decodedData);
    } catch (e) {
      print('Error decoding QR code: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateInviteeStatus(QrCodeData qrData) async {
    if (!qrData.isValid) {
      throw Exception('بيانات الباركود غير صالحة');
    }

    try {
      final inviteeDocRef = _firestore
          .collection('invitations')
          .doc(qrData.invitationId)
          .collection('invitees')
          .where('uuid', isEqualTo: qrData.inviteeId);

      final querySnapshot = await inviteeDocRef.get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('لم يتم العثور على المدعو المطابق');
      }

      final inviteeDoc = querySnapshot.docs.first;
      final Map<String, dynamic>? inviteeData = inviteeDoc.data() as Map<String, dynamic>?;
      final int currentCheckedInCount = inviteeData?['checkedInCount'] as int? ?? 0;
      final int numberOfPeople = inviteeData?['numberOfPeople'] as int? ?? 1;

      if (currentCheckedInCount >= numberOfPeople) {
        return {
          'status': 'fully_checked_in',
          'message': 'تم تسجيل حضور جميع الأشخاص مسبقاً',
          'checkedInCount': currentCheckedInCount,
          'totalPeople': numberOfPeople,
        };
      }

      final newCheckedInCount = currentCheckedInCount + 1;
      String newStatus;
      String message;

      if (newCheckedInCount >= numberOfPeople) {
        newStatus = InviteeStatus.fullyCheckedIn;
        message = 'تم تسجيل حضور جميع الأشخاص بنجاح!';
      } else {
        newStatus = InviteeStatus.partiallyCheckedIn;
        message = 'تم تسجيل حضور شخص واحد. المتبقي: ${numberOfPeople - newCheckedInCount}';
      }

      await inviteeDoc.reference.update({
        'responseStatus': newStatus,
        'checkedInCount': newCheckedInCount,
        'lastCheckedInAt': FieldValue.serverTimestamp(),
        if (newCheckedInCount == 1) 'respondedAt': FieldValue.serverTimestamp(),
      });

      return {
        'status': 'success',
        'message': message,
        'checkedInCount': newCheckedInCount,
        'totalPeople': numberOfPeople,
        'isFullyCheckedIn': newCheckedInCount >= numberOfPeople,
      };
    } catch (e) {
      print('Error updating invitee status: $e');
      rethrow;
    }
  }
}