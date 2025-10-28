import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String service;
  final String province;
  final String companyName;
  final String? companyLogo;
  final String? businessLicenseUrl;
  final String phone;
  final String region;
  final String email;
  final String details;
  final String? facebook;
  final String? instagram;
  final String? youtube;
  final double? priceFrom;
  final double? priceTo;
  final double? finalPrice;
  final List<String> serviceImages;
  final DateTime timestamp;
  final bool hasOffer;
  final bool isPaused;
  final double? discount;
  final String? offerDetails;
  final DateTime? offerStartDate;
  final DateTime? offerEndDate;
  final List<String> eventTypes; // حقل جديد لأنواع الحفلات
  final String? videoPath; // حقل جديد لفيديو الخدمة
  // الحقول الجديدة للموقع
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final List<String> bookedDays; // حقل جديد للأيام المحجوزة

  Service({
    required this.id,
    required this.service,
    required this.province,
    required this.companyName,
    this.companyLogo,
    this.businessLicenseUrl,
    required this.phone,
    required this.region,
    required this.email,
    required this.details,
    this.facebook,
    this.instagram,
    this.youtube,
    this.priceFrom,
    this.priceTo,
    this.finalPrice,
    required this.serviceImages,
    required this.timestamp,
    this.hasOffer = false,
    this.isPaused = false,
    this.discount,
    this.offerDetails,
    this.offerStartDate,
    this.offerEndDate,
    this.eventTypes = const [], // القيمة الافتراضية هي قائمة فارغة
    this.videoPath, // إضافة الحقل الجديد
    // إضافة المعاملات الجديدة
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.bookedDays = const [], // القيمة الافتراضية هي قائمة فارغة
  });

  // تحويل الخدمة إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service': service,
      'province': province,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'businessLicenseUrl': businessLicenseUrl,
      'phone': phone,
      'region': region,
      'email': email,
      'details': details,
      'facebook': facebook,
      'instagram': instagram,
      'youtube': youtube,
      'priceFrom': priceFrom,
      'priceTo': priceTo,
      'finalPrice': finalPrice,
      'serviceImages': serviceImages,
      'timestamp': timestamp,
      'hasOffer': hasOffer,
      'isPaused': isPaused,
      'discount': discount,
      'offerDetails': offerDetails,
      'offerStartDate': offerStartDate?.toIso8601String(),
      'offerEndDate': offerEndDate?.toIso8601String(),
      'eventTypes': eventTypes,
      'videoPath': videoPath, // إضافة الحقل الجديد
      // إضافة الحقول الجديدة
      'latitude': latitude,
      'longitude':longitude,
      'locationAddress':locationAddress,
      'bookedDays': bookedDays, // إضافة الحقل الجديد
    };
  }

  // إنشاء خدمة من Map
  factory Service.fromMap(Map<String, dynamic> map, String id) {
    return Service(
      id: id,
      service: map['service'],
      province: map['province'],
      companyName: map['companyName'],
      companyLogo: map['companyLogo'],
      businessLicenseUrl: map['businessLicenseUrl'],
      phone: map['phone'],
      region: map['region'],
      email: map['email'],
      details: map['details'],
      facebook: map['facebook'],
      instagram: map['instagram'],
      youtube: map['youtube'],
      priceFrom: map['priceFrom'],
      priceTo: map['priceTo'],
      finalPrice: map['finalPrice'],
      serviceImages: List<String>.from(map['serviceImages']),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      hasOffer: map['hasOffer'],
       isPaused: map['isPaused'],
      discount: map['discount'],
      offerDetails: map['offerDetails'],
      offerStartDate: map['offerStartDate'] != null ? DateTime.parse(map['offerStartDate']) : null,
      offerEndDate: map['offerEndDate'] != null ? DateTime.parse(map['offerEndDate']) : null,
      eventTypes: List<String>.from(map['eventTypes'] ?? []),
      videoPath: map['videoPath'], // إضافة الحقل الجديد
      // إضافة الحقول الجديدة
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      locationAddress: map['locationAddress'],
      bookedDays: map['bookedDays'] != null ? List<String>.from(map['bookedDays']) : [], // إضافة الحقل الجديد
    );
  }
}