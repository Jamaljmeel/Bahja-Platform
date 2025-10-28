import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String? id;
  final String companyName;
  final String details;
  final String? email;
  final String? phone;
  final String? province;
  final String? region;
  final String? serviceType;
  final String? facebook;
  final String? instagram;
  final String? youtube;
  final String? videoUrl;
  final double? priceFrom;
  final double? priceTo;
  final double? finalPrice;
  final bool hasOffer;
  final double? discount;
  final String? offerDetails;
  final String? offerStartDate;
  final String? offerEndDate;
  final List<String> eventTypes;
  final List<String> serviceImages;
  final String companyLogo;
  final double? latitude;
  final double? longitude;

  ServiceModel({
    this.id,
    required this.companyName,
    required this.details,
    this.email,
    this.phone,
    this.province,
    this.region,
    this.serviceType,
    this.facebook,
    this.instagram,
    this.youtube,
    this.videoUrl,
    this.priceFrom,
    this.priceTo,
    this.finalPrice,
    this.hasOffer = false,
    this.discount,
    this.offerDetails,
    this.offerStartDate,
    this.offerEndDate,
    this.eventTypes = const [],
    this.serviceImages = const [],
    this.companyLogo = '',
    this.latitude,
    this.longitude,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      companyName: data['companyName'] ?? 'غير متوفر',
      details: data['details'] ?? '',
      email: data['email'],
      phone: data['phone'],
      province: data['province'],
      region: data['region'],
      serviceType: data['service'],
      facebook: data['facebook'],
      instagram: data['instagram'],
      youtube: data['youtube'],
      videoUrl: data['videoPath'],
      priceFrom: data['priceFrom']?.toDouble(),
      priceTo: data['priceTo']?.toDouble(),
      finalPrice: data['finalPrice']?.toDouble(),
      hasOffer: data['hasOffer'] ?? false,
      discount: data['discount']?.toDouble(),
      offerDetails: data['offerDetails'],
      offerStartDate: data['offerStartDate'],
      offerEndDate: data['offerEndDate'],
      eventTypes: List<String>.from(data['eventTypes'] ?? []),
      serviceImages: List<String>.from(data['serviceImages'] ?? []),
      companyLogo: data['companyLogo'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  String get fullLocation => '$province، $region';
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasImages => serviceImages.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  
  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'details': details,
      'email': email,
      'phone': phone,
      'province': province,
      'region': region,
      'service': serviceType,
      'facebook': facebook,
      'instagram': instagram,
      'youtube': youtube,
      'videoPath': videoUrl,
      'priceFrom': priceFrom,
      'priceTo': priceTo,
      'finalPrice': finalPrice,
      'hasOffer': hasOffer,
      'discount': discount,
      'offerDetails': offerDetails,
      'offerStartDate': offerStartDate,
      'offerEndDate': offerEndDate,
      'eventTypes': eventTypes,
      'serviceImages': serviceImages,
      'companyLogo': companyLogo,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}