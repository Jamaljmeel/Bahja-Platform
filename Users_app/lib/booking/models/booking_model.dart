// lib/features/bookings/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String providerId;
  final Map<String, dynamic> serviceData;
  final DateTime selectedDate;
  final String selectedTime;
  final String paymentMethod;
  final String notes;
  final double price;
  final DateTime createdAt;
  final String status;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceData,
    required this.selectedDate,
    required this.selectedTime,
    required this.paymentMethod,
    required this.notes,
    required this.price,
    required this.createdAt,
    this.status = 'pending',
  });

  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      userId: data['userId'],
      providerId: data['providerId'],
      serviceData: data['serviceData'],
      selectedDate: (data['selectedDate'] as Timestamp).toDate(),
      selectedTime: data['selectedTime'],
      paymentMethod: data['paymentMethod'],
      notes: data['notes'],
      price: (data['price'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }
}