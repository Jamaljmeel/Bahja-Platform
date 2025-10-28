import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final DateTime bookingDate;
  final DateTime createdAt;
  final DateTime eventDate;
  final double finalPrice;
  final String notes;
  final String paymentMethod;
  final String providerId;
  final String? providerImage;
  final String serviceName;
  final String serviceType;
  final String status;
  final String userId;

  BookingModel({
    required this.id,
    required this.bookingDate,
    required this.createdAt,
    required this.eventDate,
    required this.finalPrice,
    required this.notes,
    required this.paymentMethod,
    required this.providerId,
    this.providerImage,
    required this.serviceName,
    required this.serviceType,
    required this.status,
    required this.userId,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      finalPrice: (data['finalPrice'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      providerId: data['providerId'] ?? '',
      providerImage: data['providerImage'],
      serviceName: data['serviceName'] ?? '',
      serviceType: data['serviceType'] ?? '',
      status: data['status'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  }
