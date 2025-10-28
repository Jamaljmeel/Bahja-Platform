import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../../theme/app_theme.dart';
import '../models/invitation_model.dart';

class InvitationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> saveInvitationLocally({
    required String? invitationId,
    required String inviterName,
    required String eventName,
    required String eventType,
    required String location,
    required String eventDate,
    required String eventTime,
    required String maxGuests,
    required String personalMessage,
    required String additionalRequirements,
    LatLng? selectedLocation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser;
    if (user == null) return;

    await prefs.setString('current_invitation_id_${user.uid}', invitationId ?? '');
    await prefs.setString('inviterName_${user.uid}', inviterName);
    await prefs.setString('eventName_${user.uid}', eventName);
    await prefs.setString('eventType_${user.uid}', eventType);
    await prefs.setString('location_${user.uid}', location);
    await prefs.setString('eventDate_${user.uid}', eventDate);
    await prefs.setString('eventTime_${user.uid}', eventTime);
    await prefs.setString('maxGuests_${user.uid}', maxGuests);
    await prefs.setString('personalMessage_${user.uid}', personalMessage);
    await prefs.setString('additionalRequirements_${user.uid}', additionalRequirements);

    if (selectedLocation != null) {
      await prefs.setDouble('locationLat_${user.uid}', selectedLocation.latitude);
      await prefs.setDouble('locationLng_${user.uid}', selectedLocation.longitude);
    }
  }

  Future<void> saveInviteesLocally(String? invitationId, List<Invitee> invitees) async {
    if (invitationId == null) return;
    final user = _auth.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final inviteesJson = invitees.map((invitee) => invitee.toJson()).toList();
    await prefs.setString('invitees_${user.uid}_$invitationId', jsonEncode(inviteesJson));
  }

  Future<Map<String, dynamic>?> loadSavedInvitationData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final savedInvitationId = prefs.getString('current_invitation_id_${user.uid}');

    final data = <String, dynamic>{
      'invitationId': savedInvitationId,
      'inviterName': prefs.getString('inviterName_${user.uid}') ?? '',
      'eventName': prefs.getString('eventName_${user.uid}') ?? '',
      'eventType': prefs.getString('eventType_${user.uid}') ?? 'زفاف',
      'location': prefs.getString('location_${user.uid}') ?? '',
      'eventDate': prefs.getString('eventDate_${user.uid}') ?? '',
      'eventTime': prefs.getString('eventTime_${user.uid}') ?? '',
      'maxGuests': prefs.getString('maxGuests_${user.uid}') ?? '1',
      'personalMessage': prefs.getString('personalMessage_${user.uid}') ?? '',
      'additionalRequirements': prefs.getString('additionalRequirements_${user.uid}') ?? '',
    };

    final lat = prefs.getDouble('locationLat_${user.uid}');
    final lng = prefs.getDouble('locationLng_${user.uid}');
    if (lat != null && lng != null) {
      data['selectedLocation'] = LatLng(lat, lng);
    }

    // 🔽 تحميل المدعوين المرتبطين بالدعوة من الذاكرة المحلية مباشرة
    if (savedInvitationId != null && savedInvitationId.isNotEmpty) {
      final inviteesJson = prefs.getString('invitees_${user.uid}_$savedInvitationId');
      if (inviteesJson != null && inviteesJson.isNotEmpty) {
        try {
          final List<dynamic> inviteesList = jsonDecode(inviteesJson);
          data['invitees'] = inviteesList.map<Invitee>((item) => Invitee.fromJson(item)).toList();
        } catch (e) {
          debugPrint('Error parsing invitees from local storage: $e');
        }
      } else {
        data['invitees'] = [];
      }
    } else {
      data['invitees'] = [];
    }

    return data;
  }

  Future<Map<String, dynamic>?> loadInvitationFromFirestore(String invitationId) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('invitations').doc(invitationId).get();
      if (doc.exists && doc.data()?['userId'] == user.uid) {
        return doc.data();
      }
    } catch (e) {
      print('Error loading invitation from Firestore: $e');
    }
    return null;
  }

  Future<List<Invitee>> loadInvitees(String? invitationId) async {
    if (invitationId == null) return [];
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // أولًا: حاول تحميل المدعوين من Firestore
      final inviteesSnapshot = await _firestore
          .collection('invitations')
          .doc(invitationId)
          .collection('invitees')
          .where('userId', isEqualTo: user.uid)
          .orderBy('sentAt', descending: true)
          .get();

      final List<Invitee> invitees = inviteesSnapshot.docs.map((doc) {
        final data = doc.data();
        return Invitee(
          name: data['name'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          numberOfPeople: (data['numberOfPeople'] ?? 1).toString(),
          uuid: data['uuid'] ?? '',
          responseStatus: data['responseStatus'] ?? 'pending',
          sentAt: data['sentAt']?.toDate(),
          respondedAt: data['respondedAt']?.toDate(),
        );
      }).toList();

      // حفظهم محليًا للسرعة في المستقبل
      await saveInviteesLocally(invitationId, invitees);

      return invitees;
    } catch (e) {
      print('Error loading invitees from Firestore: $e');
      // إذا فشل Firestore، ارجع من الذاكرة المحلية
      return await _loadInviteesFromLocal(invitationId);
    }
  }

  Future<List<Invitee>> _loadInviteesFromLocal(String invitationId) async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final prefs = await SharedPreferences.getInstance();
    final inviteesJson = prefs.getString('invitees_${user.uid}_$invitationId');
    if (inviteesJson != null && inviteesJson.isNotEmpty) {
      try {
        final List<dynamic> inviteesList = jsonDecode(inviteesJson);
        return inviteesList.map<Invitee>((item) => Invitee.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Error parsing invitees from local storage: $e');
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> loadUserInvitations() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final querySnapshot = await _firestore
          .collection('invitations')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'eventName': data['eventName'] ?? 'مناسبة غير محددة',
          'eventType': data['eventType'] ?? 'نوع غير محدد',
          'eventDate': data['eventDate'] ?? 'تاريخ غير محدد',
          'eventTime': data['eventTime'] ?? 'وقت غير محدد',
          'location': data['location'] ?? 'مكان غير محدد',
          'inviterName': data['inviterName'] ?? 'داعي غير محدد',
          'maxGuests': data['maxGuests'] ?? 1,
          'personalMessage': data['personalMessage'] ?? '',
          'additionalRequirements': data['additionalRequirements'] ?? '',
          'createdAt': data['createdAt'],
          'imageUrl': data['imageUrl'] ?? '',
          'locationLatLng': data['locationLatLng'],
        };
      }).toList();
    } catch (e) {
      print('Error loading invitations: $e');
      throw e;
    }
  }

  Future<String?> saveInvitation({
    String? invitationId,
    required String inviterName,
    required String eventName,
    required String eventType,
    required String location,
    required String eventDate,
    required String eventTime,
    required String maxGuests,
    required String personalMessage,
    required String additionalRequirements,
    File? invitationImage,
    LatLng? selectedLocation,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    String imageUrl = '';
    if (invitationImage != null) {
      final storageRef = _storage
          .ref()
          .child('invitation_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(invitationImage);
      imageUrl = await storageRef.getDownloadURL();
    }

    final invitationData = {
      'userId': user.uid,
      'inviterName': inviterName,
      'eventName': eventName,
      'eventType': eventType,
      'location': location,
      'locationLatLng': selectedLocation != null
          ? GeoPoint(selectedLocation.latitude, selectedLocation.longitude)
          : null,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'maxGuests': int.tryParse(maxGuests) ?? 1,
      'personalMessage': personalMessage,
      'additionalRequirements': additionalRequirements,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    DocumentReference docRef;
    if (invitationId == null) {
      docRef = await _firestore.collection('invitations').add(invitationData);
      return docRef.id;
    } else {
      docRef = _firestore.collection('invitations').doc(invitationId);
      await docRef.update({
        ...invitationData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return invitationId;
    }
  }

  Future<void> saveInviteeToFirestore(String? invitationId, Invitee invitee) async {
    if (invitationId == null) return;
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('invitations')
        .doc(invitationId)
        .collection('invitees')
        .add({
      'name': invitee.name,
      'phoneNumber': invitee.phoneNumber,
      'numberOfPeople': int.tryParse(invitee.numberOfPeople) ?? 1,
      'uuid': invitee.uuid,
      'responseStatus': 'pending',
      'sentAt': FieldValue.serverTimestamp(),
      'respondedAt': null,
      'userId': user.uid,
    });
  }

  Future<void> deleteInvitee(String? invitationId, Invitee invitee) async {
    if (invitationId == null) return;
    final user = _auth.currentUser;
    if (user == null) return;

    final inviteesQuery = await _firestore
        .collection('invitations')
        .doc(invitationId)
        .collection('invitees')
        .where('uuid', isEqualTo: invitee.uuid)
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in inviteesQuery.docs) {
      await doc.reference.delete();
    }

    // تحديث القائمة المحلية
    final prefs = await SharedPreferences.getInstance();
    final savedInvitees = await _loadInviteesFromLocal(invitationId);
    final filtered = savedInvitees.where((i) => i.uuid != invitee.uuid).toList();
    await prefs.setString('invitees_${user.uid}_$invitationId', jsonEncode(filtered.map((i) => i.toJson()).toList()));
  }

  Future<void> deleteInvitation(String invitationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('invitations').doc(invitationId).delete();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_invitation_id_${user.uid}');
    await prefs.remove('invitees_${user.uid}_$invitationId');
  }

  Future<void> clearNewInvitationData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_invitation_id_${user.uid}');
      await prefs.remove('inviterName_${user.uid}');
      await prefs.remove('eventName_${user.uid}');
      await prefs.remove('eventType_${user.uid}');
      await prefs.remove('location_${user.uid}');
      await prefs.remove('eventDate_${user.uid}');
      await prefs.remove('eventTime_${user.uid}');
      await prefs.remove('maxGuests_${user.uid}');
      await prefs.remove('personalMessage_${user.uid}');
      await prefs.remove('additionalRequirements_${user.uid}');
      await prefs.remove('locationLat_${user.uid}');
      await prefs.remove('locationLng_${user.uid}');
      // لا نحذف قائمة المدعوين لكل دعوة هنا لأنها مرتبطة بـ ID
    }
  }

  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<List<Contact>> getContacts() async {
    bool permissionGranted = await FlutterContacts.requestPermission();
    if (!permissionGranted) {
      final permissionStatus = await Permission.contacts.status;
      if (permissionStatus.isPermanentlyDenied) {
        throw Exception('permission_permanently_denied');
      } else {
        throw Exception('permission_denied');
      }
    }
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    if (contacts.isEmpty) {
      throw Exception('no_contacts');
    }
    return contacts;
  }

  Future<void> generateAndShareQrCode({
    required String? invitationId,
    required Invitee invitee,
    required String eventName,
    required String eventDate,
    required String eventTime,
    required String location,
    required String personalMessage,
    File? invitationImage,
    required BuildContext context,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    List<XFile> filesToShare = [];

    final qrData = jsonEncode({
      'invitationId': invitationId,
      'inviteeId': invitee.uuid,
      'eventName': eventName,
      'inviteeName': invitee.name,
      'numberOfPeople': int.tryParse(invitee.numberOfPeople) ?? 1,
    });

    final qrCode = QrCode.fromData(
      data: qrData,
      errorCorrectLevel: QrErrorCorrectLevel.L,
    );

    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const ui.Color.fromARGB(255, 255, 255, 255),
      gapless: false,
    );

    final qrImageFile = File('${directory.path}/qr_${invitee.uuid}.png');
    final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
    await qrImageFile.writeAsBytes(picData!.buffer.asUint8List());
    filesToShare.add(XFile(qrImageFile.path));

    if (invitationImage != null) {
      final invitationImageFile = File('${directory.path}/invitation_${invitee.uuid}.jpg');
      await invitationImageFile.writeAsBytes(await invitationImage.readAsBytes());
      filesToShare.add(XFile(invitationImageFile.path));
    }

    final message = '''مرحباً بك،
أتشرف بدعوتك لحضور حفل تخرجي
📅 التاريخ: $eventDate
🕐 الوقت: $eventTime
📍 المكان: $location
👥 عدد الأشخاص: 1
${personalMessage.isNotEmpty ? '\n$personalMessage' : ''}
يرجى الاحتفاظ بالباركود المرفق لتسجيل الحضور.''';

    await Share.shareXFiles(
      filesToShare,
      text: message,
      subject: 'دعوة $eventName',
    );
  }

  Future<void> shareViaWhatsApp({
    required String? invitationId,
    required Invitee invitee,
    required String eventName,
    required String eventDate,
    required String eventTime,
    required String location,
    required String personalMessage,
    File? invitationImage,
    required String phoneNumber,
    required BuildContext context,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    List<XFile> filesToShare = [];

    final qrData = jsonEncode({
      'invitationId': invitationId,
      'inviteeId': invitee.uuid,
      'eventName': eventName,
      'inviteeName': invitee.name,
      'numberOfPeople': int.tryParse(invitee.numberOfPeople) ?? 1,
    });

    final qrCode = QrCode.fromData(
      data: qrData,
      errorCorrectLevel: QrErrorCorrectLevel.L,
    );

    final painter = QrPainter.withQr(
      qr: qrCode,
      color: AppColors.textColor(context),
      gapless: false,
    );

    final qrImageFile = File('${directory.path}/qr_${invitee.uuid}.png');
    final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
    await qrImageFile.writeAsBytes(picData!.buffer.asUint8List());
    filesToShare.add(XFile(qrImageFile.path));

    if (invitationImage != null) {
      final invitationImageFile = File('${directory.path}/invitation_${invitee.uuid}.jpg');
      await invitationImageFile.writeAsBytes(await invitationImage.readAsBytes());
      filesToShare.add(XFile(invitationImageFile.path));
    }

    final message = '''مرحباً بك،
أتشرف بدعوتك لحضور $eventName
📅 التاريخ: $eventDate
🕐 الوقت: $eventTime
📍 المكان: $location
👥 عدد الأشخاص: ${invitee.numberOfPeople}
${personalMessage.isNotEmpty ? '\n$personalMessage' : ''}
يرجى الاحتفاظ بالباركود المرفق لتسجيل الحضور.''';

    String cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanedPhoneNumber.startsWith('+')) {
      cleanedPhoneNumber = cleanedPhoneNumber.startsWith('0') ? '+967${cleanedPhoneNumber.substring(1)}' : '+967$cleanedPhoneNumber';
    }

    final whatsappUrl = 'https://wa.me/$cleanedPhoneNumber?text=${Uri.encodeComponent(message)}';
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
        if (filesToShare.isNotEmpty) {
          await Future.delayed(Duration(seconds: 1));
          await Share.shareXFiles(filesToShare);
        }
      } else {
        await Share.shareXFiles(filesToShare, text: message, subject: 'دعوة $eventName');
      }
    } catch (e) {
      await Share.shareXFiles(filesToShare, text: message, subject: 'دعوة $eventName');
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}