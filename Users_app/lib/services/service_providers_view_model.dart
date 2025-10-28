import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvidersViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getServiceProviders(String serviceName) {
    return _firestore
        .collection('service_providers')
        .where('hasOffer', isEqualTo: true)
        .where('isPaused', isEqualTo: false)
        .where('service', isEqualTo: serviceName)
        .snapshots();
  }

  // جلب قائمة المحافظات
  Future<List<String>> getProvinces() async {
    try {
      final querySnapshot = await _firestore.collection('provinces').get();
      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print('خطأ في جلب المحافظات: $e');
      return [];
    }
  }

  // جلب قائمة أنواع الحفلات
  Future<List<String>> getEventTypes() async {
    try {
      final querySnapshot = await _firestore.collection('event_types').get();
      return querySnapshot.docs.map((doc) => doc['eventType'] as String).toList();
    } catch (e) {
      print('خطأ في جلب أنواع الحفلات: $e');
      return [];
    }
  }
}