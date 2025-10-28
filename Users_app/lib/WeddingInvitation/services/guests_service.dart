import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/guests_model.dart';


class GuestsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<List<EventModel>> loadUserEvents() async {
    final user = getCurrentUser();
    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

    final querySnapshot = await _firestore
        .collection('invitations')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      return EventModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<List<InviteeModel>> loadInviteesForEvent(String invitationId) async {
    final inviteesSnapshot = await _firestore
        .collection('invitations')
        .doc(invitationId)
        .collection('invitees')
        .orderBy('sentAt', descending: true)
        .get();

    return inviteesSnapshot.docs.map((doc) {
      return InviteeModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<void> addNewInvitee({
    required String invitationId,
    required String name,
    required String phoneNumber,
    required String numberOfPeople,
  }) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

    await _firestore
        .collection('invitations')
        .doc(invitationId)
        .collection('invitees')
        .add({
      'name': name,
      'phoneNumber': phoneNumber,
      'numberOfPeople': int.tryParse(numberOfPeople) ?? 1,
      'uuid': DateTime.now().millisecondsSinceEpoch.toString(),
      'responseStatus': InviteeStatus.pending,
      'sentAt': FieldValue.serverTimestamp(),
      'respondedAt': null,
      'userId': user.uid,
    });
  }

  Future<List<Contact>> getContacts() async {
    final permissionStatus = await Permission.contacts.request();
    
    if (permissionStatus.isDenied) {
      throw Exception('permission_denied');
    }

    if (permissionStatus.isPermanentlyDenied) {
      throw Exception('permission_permanently_denied');
    }

    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      
      if (contacts.isEmpty) {
        throw Exception('no_contacts');
      }
      
      return contacts;
    } else {
      throw Exception('permission_denied');
    }
  }

  List<InviteeModel> filterInviteesByStatus(List<InviteeModel> invitees, String status) {
    return invitees.where((invitee) => invitee.responseStatus == status).toList();
  }

  int getTotalAttendees(List<InviteeModel> checkedInInvitees) {
    return checkedInInvitees.fold(0, (sum, invitee) => sum + invitee.numberOfPeople);
  }
}