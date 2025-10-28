import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RevenueProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _totalRevenue = 0.0;
  double get totalRevenue => _totalRevenue;

  // استدعِ هذه الدالة في initState أو بعد إنشاء الـ Provider
  // void startListening() {
  //   _firestore.collection('revenue').snapshots().listen((snapshot) {
  //     _totalRevenue = snapshot.docs.fold(0.0, (sum, doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       final commission =
  //           double.tryParse(data['commission'].toString()) ?? 0.0;
  //       return sum + commission;
  //     });

  //     notifyListeners();
  //   });
  // }
}
