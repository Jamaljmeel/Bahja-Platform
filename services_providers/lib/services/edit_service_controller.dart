import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/service_model.dart';
import '../services/service_provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class EditServiceController {
  // Controllers
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController priceFromController = TextEditingController();
  final TextEditingController priceToController = TextEditingController();
  final TextEditingController finalPriceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController offerDetailsController = TextEditingController();

  // Variables
  String? selectedService;
  String? selectedProvince;
  File? companyLogo;
  List<File> serviceImages = [];
  File? serviceVideo;
  File? businessLicense;

  // متغيرات لحفظ URLs الأصلية
  String? originalCompanyLogoUrl;
  List<String> originalServiceImageUrls = [];
  String? originalVideoUrl;
  String? originalBusinessLicenseUrl;

  LatLng? selectedLocation;
  String? locationAddress;
  String? originalLocationAddress;

  final ImagePicker picker = ImagePicker();
  DateTime? offerStartDate;
  DateTime? offerEndDate;
  bool hasOffer = true;
  bool isPaused = false;
  double? priceAfterDiscount;
  List<String> selectedEventTypes = [];
  Set<DateTime> bookedDays = {};
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  // Initialize data from existing service
  void initializeData(Service service) {
    print("الأيام المحجوزة من Firestore: ${service.bookedDays}");
    
    // ✅ إصلاح تحويل الأيام المحجوزة
    bookedDays.clear(); // تنظيف المجموعة أولاً
    
    for (String dateString in service.bookedDays) {
      try {
        DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);
        // ✅ تطبيع التاريخ - إزالة الوقت تماماً
        DateTime normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        bookedDays.add(normalizedDate);
        print("تم إضافة التاريخ: $normalizedDate");
      } catch (e) {
        print("خطأ في تحويل التاريخ: $dateString - $e");
      }
    }
    
    print("الأيام المحجوزة بعد التحويل: $bookedDays");
    print("عدد الأيام المحجوزة: ${bookedDays.length}");

    companyNameController.text = service.companyName;
    phoneController.text = service.phone;
    regionController.text = service.region;
    emailController.text = service.email;
    detailsController.text = service.details;
    facebookController.text = service.facebook ?? '';
    instagramController.text = service.instagram ?? '';
    youtubeController.text = service.youtube ?? '';
    priceFromController.text = service.priceFrom?.toString() ?? '';
    priceToController.text = service.priceTo?.toString() ?? '';
    finalPriceController.text = service.finalPrice?.toString() ?? '';
    selectedService = service.service;
    selectedProvince = service.province;
    hasOffer = service.hasOffer;
    isPaused = service.isPaused;
    discountController.text = service.discount?.toString() ?? '';
    offerDetailsController.text = service.offerDetails ?? '';
    offerStartDate = service.offerStartDate;
    offerEndDate = service.offerEndDate;
    priceAfterDiscount = service.finalPrice;
    selectedEventTypes = List<String>.from(service.eventTypes);

    // حفظ URLs الأصلية بدلاً من إنشاء File objects
    originalCompanyLogoUrl = service.companyLogo;
    originalServiceImageUrls = List<String>.from(service.serviceImages);
    originalVideoUrl = service.videoPath;
    originalBusinessLicenseUrl = service.businessLicenseUrl;

    // إضافة استرجاع بيانات الموقع
    if (service.latitude != null && service.longitude != null) {
      selectedLocation = LatLng(service.latitude!, service.longitude!);
      locationAddress = service.locationAddress;
      originalLocationAddress = service.locationAddress;
    }
  }

  // Pick company logo
  Future<void> pickCompanyLogo() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      companyLogo = File(pickedFile.path);
    }
  }

  // Pick service images
  Future<void> pickServiceImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      serviceImages = pickedFiles.map((file) => File(file.path)).toList();
    }
  }

  // Pick service video
  Future<void> pickServiceVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      serviceVideo = File(pickedFile.path);
    }
  }

  // Pick business license PDF - إضافة دالة اختيار السجل التجاري
  Future<void> pickBusinessLicense() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      businessLicense = File(result.files.single.path!);
    }
  }


  // Calculate price after discount - تعديل الحساب ليكون اختياري
  void calculatePriceAfterDiscount() {
    if (finalPriceController.text.isNotEmpty &&
        discountController.text.isNotEmpty) {
      double finalPrice = double.parse(finalPriceController.text);
      double discount = double.parse(discountController.text);
      priceAfterDiscount = finalPrice - (finalPrice * discount / 100);
    } else {
      priceAfterDiscount = null;
    }
  }

  // Update service
  Future<void> updateService(
      BuildContext context, Service originalService) async {
    try {
      if (companyLogo == null &&
          (originalCompanyLogoUrl == null || originalCompanyLogoUrl!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'الرجاء رفع شعار الشركة',
              style: GoogleFonts.elMessiri(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }

      // التحقق من السجل التجاري
      if (businessLicense == null &&
          (originalBusinessLicenseUrl == null ||
              originalBusinessLicenseUrl!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'الرجاء رفع السجل التجاري (ملف PDF)',
              style: GoogleFonts.elMessiri(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }

      final bookedDaysStr = bookedDays
          .map((day) => DateFormat('yyyy-MM-dd').format(day))
          .toList();

      final updatedService = Service(
        id: originalService.id,
        service: selectedService!,
        province: selectedProvince!,
        companyName: companyNameController.text,
        companyLogo: companyLogo?.path ?? originalCompanyLogoUrl,
        phone: phoneController.text,
        region: regionController.text,
        email: emailController.text,
        details: detailsController.text,
        facebook:
            facebookController.text.isNotEmpty ? facebookController.text : null,
        instagram: instagramController.text.isNotEmpty
            ? instagramController.text
            : null,
        youtube:
            youtubeController.text.isNotEmpty ? youtubeController.text : null,
        priceFrom: priceFromController.text.isNotEmpty
            ? double.parse(priceFromController.text)
            : null,
        priceTo: priceToController.text.isNotEmpty
            ? double.parse(priceToController.text)
            : null,
        finalPrice: finalPriceController.text.isNotEmpty
            ? double.parse(finalPriceController.text)
            : null,
        serviceImages: serviceImages.isNotEmpty
            ? serviceImages.map((file) => file.path).toList()
            : originalServiceImageUrls,
        timestamp: originalService.timestamp,
        hasOffer: hasOffer,
        isPaused: isPaused,
        discount: hasOffer && discountController.text.isNotEmpty
            ? double.parse(discountController.text)
            : null,
        offerDetails: hasOffer ? offerDetailsController.text : null,
        offerStartDate: hasOffer ? offerStartDate : null,
        offerEndDate: hasOffer ? offerEndDate : null,
        eventTypes: selectedEventTypes,
        videoPath: serviceVideo?.path ?? originalVideoUrl,
        latitude: selectedLocation?.latitude,
        longitude: selectedLocation?.longitude,
        locationAddress: locationAddress ?? originalLocationAddress,
        bookedDays: bookedDaysStr,
        businessLicenseUrl: originalBusinessLicenseUrl,
      );

      // تمرير الملفات الجديدة فقط للرفع
      List<File> newImages = serviceImages.isNotEmpty ? serviceImages : [];

      await ServiceProvider().updateService(
          updatedService, newImages, bookedDaysStr, businessLicense);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تعديل الخدمة بنجاح',
            style: GoogleFonts.elMessiri(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('خطأ في updateService: $e'); 
      throw e;
    }
  }

  // Handle day selection in calendar
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print("تم اختيار التاريخ: $selectedDay");
    
    this.selectedDay = selectedDay;
    this.focusedDay = focusedDay;
    
    // ✅ تطبيع التاريخ المحدد
    DateTime normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    print("التاريخ المطبع: $normalizedSelectedDay");
    
    if (bookedDays.contains(normalizedSelectedDay)) {
      bookedDays.remove(normalizedSelectedDay);
      print("تم إزالة التاريخ من المحجوزات: $normalizedSelectedDay");
    } else {
      bookedDays.add(normalizedSelectedDay);
      print("تم إضافة التاريخ للمحجوزات: $normalizedSelectedDay");
    }
    
    print("الأيام المحجوزة الحالية: $bookedDays");
  }

  // ✅ دالة مساعدة للتحقق من اليوم المحجوز
  bool isBookedDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    bool isBooked = bookedDays.contains(normalizedDay);
    print("التحقق من التاريخ $normalizedDay: محجوز = $isBooked");
    return isBooked;
  }

  // Dispose controllers
  void dispose() {
    companyNameController.dispose();
    phoneController.dispose();
    regionController.dispose();
    emailController.dispose();
    detailsController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    youtubeController.dispose();
    priceFromController.dispose();
    priceToController.dispose();
    finalPriceController.dispose();
    discountController.dispose();
    offerDetailsController.dispose();
  }
}
