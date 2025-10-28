import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/service_model.dart';
import 'package:uuid/uuid.dart'; // استيراد مكتبة UUID

class ServiceProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // دالة مساعدة لرفع الملفات إلى Firebase Storage باستخدام UUID
  Future<String> _uploadFile(File file, String folderName) async {
    try {
      if (!file.existsSync()) {
        throw Exception('❌ الملف غير موجود: ${file.path}');
      }

      final String uniqueFileName = const Uuid().v4();
      final ref = _storage.ref().child('$folderName/$uniqueFileName');

      print('🚀 رفع الملف إلى: $folderName/$uniqueFileName');

      final uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() => null);

      final url = await ref.getDownloadURL();
      print('✅ تم رفع الملف بنجاح: $url');
      return url;
    } catch (e) {
      print('❌ خطأ أثناء رفع الملف: $e');
      throw Exception('حدث خطأ أثناء رفع الملف: $e');
    }
  }

  // إضافة خدمة جديدة
  Future<void> addService(Service service, List<File> images, List<String> bookedDays, File? businessLicense) async {
    try {
      String? logoUrl;
      if (service.companyLogo != null) {
        final logoFile = File(service.companyLogo!);
        logoUrl = await _uploadFile(logoFile, 'company_logos');
      }

      List<String> imageUrls = [];
      for (final image in images) {
        final url = await _uploadFile(image, 'service_images');
        imageUrls.add(url);
      }

      String? videoUrl;
      if (service.videoPath != null) {
        final videoFile = File(service.videoPath!);
        videoUrl = await _uploadFile(videoFile, 'service_videos');
      }

            // رفع السجل التجاري
      String? businessLicenseUrl;
      if (businessLicense != null) {
        businessLicenseUrl = await _uploadFile(businessLicense, 'business_licenses');
      }


      final userId = FirebaseAuth.instance.currentUser!.uid;

      await _firestore.collection('service_providers').add({
        'userId': userId,
        'service': service.service,
        'province': service.province,
        'companyName': service.companyName,
        'companyLogo': logoUrl,
        'phone': service.phone,
        'region': service.region,
        'email': service.email,
        'details': service.details,
        'facebook': service.facebook,
        'instagram': service.instagram,
        'youtube': service.youtube,
        'priceFrom': service.priceFrom,
        'priceTo': service.priceTo,
        'finalPrice': service.finalPrice,
        'serviceImages': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'hasOffer': service.hasOffer,
        'isPaused': service.isPaused,
        'discount': service.discount,
        'offerDetails': service.offerDetails,
        'offerStartDate': service.offerStartDate?.toIso8601String(),
        'offerEndDate': service.offerEndDate?.toIso8601String(),
        'eventTypes': service.eventTypes,
        'videoPath': videoUrl,
        // إضافة بيانات الموقع الجديدة
        'latitude': service.latitude,
        'longitude': service.longitude,
        'locationAddress': service.locationAddress,
        'bookedDays': bookedDays, // إضافة الأيام المحجوزة
        'businessLicenseUrl': businessLicenseUrl, // إضافة السجل التجاري
      });
    } catch (e) {
      throw Exception('❌ حدث خطأ أثناء إضافة الخدمة: $e');
    }
  }

  // تحديث خدمة
  Future<void> updateService(Service service, List<File> images, List<String> bookedDays, File? businessLicense) async {
    try {
      String? logoUrl = service.companyLogo; // الاحتفاظ بالرابط الأصلي افتراضياً
    
    // فقط إذا كان companyLogo يحتوي على مسار ملف محلي (ليس رابط URL)
    if (service.companyLogo != null && !service.companyLogo!.startsWith('http')) {
      final logoFile = File(service.companyLogo!);
      logoUrl = await _uploadFile(logoFile, 'company_logos');
    }

    List<String> imageUrls = [];
    // إذا كانت images تحتوي على ملفات جديدة فقط
    for (final image in images) {
      final url = await _uploadFile(image, 'service_images');
      imageUrls.add(url);
    }
    
    // إذا لم تكن هناك صور جديدة، استخدم الروابط الأصلية
    if (imageUrls.isEmpty && service.serviceImages.isNotEmpty) {
      imageUrls = List<String>.from(service.serviceImages);
    }

    String? videoUrl = service.videoPath;
    // فقط إذا كان videoPath يحتوي على مسار ملف محلي (ليس رابط URL)
    if (service.videoPath != null && !service.videoPath!.startsWith('http')) {
      final videoFile = File(service.videoPath!);
      videoUrl = await _uploadFile(videoFile, 'service_videos');
    }

        // تحديث السجل التجاري
    String? businessLicenseUrl = service.businessLicenseUrl;
    if (businessLicense != null) {
      businessLicenseUrl = await _uploadFile(businessLicense, 'business_licenses');
    }

      await _firestore.collection('service_providers').doc(service.id).update({
        'service': service.service,
        'province': service.province,
        'companyName': service.companyName,
        'companyLogo': logoUrl,
        'phone': service.phone,
        'region': service.region,
        'email': service.email,
        'details': service.details,
        'facebook': service.facebook,
        'instagram': service.instagram,
        'youtube': service.youtube,
        'priceFrom': service.priceFrom,
        'priceTo': service.priceTo,
        'finalPrice': service.finalPrice,
        'serviceImages': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'hasOffer': service.hasOffer,
        'isPaused': service.isPaused,
        'discount': service.discount,
        'offerDetails': service.offerDetails,
        'offerStartDate': service.offerStartDate?.toIso8601String(),
        'offerEndDate': service.offerEndDate?.toIso8601String(),
        'eventTypes': service.eventTypes,
        'videoPath': videoUrl,
        // تحديث بيانات الموقع
        'latitude': service.latitude,
        'longitude': service.longitude,
        'locationAddress': service.locationAddress,
        'bookedDays': bookedDays, // إضافة الأيام المحجوزة
        'businessLicenseUrl': businessLicenseUrl, // إضافة السجل التجاري
      });
    } catch (e) {
      throw Exception('❌ حدث خطأ أثناء تحديث الخدمة: $e');
    }
  }

  // جلب جميع الخدمات
  Stream<List<Service>> getServicesByUserId(String userId) {
    return _firestore
        .collection('service_providers') // الوصول إلى مجموعة الخدمات
        .where('userId', isEqualTo: userId) // تصفية الخدمات حسب معرف المستخدم
        .orderBy('timestamp', descending: true) // ترتيب الخدمات حسب التاريخ (الأحدث أولاً)
        .snapshots() // استماع للتغيرات في الوقت الفعلي
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Service.fromMap(doc.data() as Map<String, dynamic>, doc.id); // تحويل البيانات إلى نموذج الخدمة
      }).toList();
    });
  }
  // حذف خدمة
  Future<void> deleteService(String id) async {
    try {
      final doc = await _firestore.collection('service_providers').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        final logoUrl = data['companyLogo'] as String?;
        if (logoUrl != null) {
          await _storage.refFromURL(logoUrl).delete();
        }

        if (data.containsKey('serviceImages')) {
          final imageUrls = List<String>.from(data['serviceImages'] ?? []);
          for (final url in imageUrls) {
            await _storage.refFromURL(url).delete();
          }
        }

        final videoUrl = data['videoPath'] as String?;
        if (videoUrl != null) {
          await _storage.refFromURL(videoUrl).delete();
        }

        // حذف السجل التجاري
        final businessLicenseUrl = data['businessLicenseUrl'] as String?;
        if (businessLicenseUrl != null) {
          await _storage.refFromURL(businessLicenseUrl).delete();
        }
      }

      await _firestore.collection('service_providers').doc(id).delete();
    } catch (e) {
      throw Exception('❌ حدث خطأ أثناء حذف الخدمة: $e');
    }
  }
}
