import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceDetailsViewModel {
  static Future<DocumentSnapshot> getServiceDetails(String providerId) {
    return FirebaseFirestore.instance.collection('service_providers').doc(providerId).get();
  }
}
