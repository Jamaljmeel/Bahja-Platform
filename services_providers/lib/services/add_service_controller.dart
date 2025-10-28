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

class AddServiceController {
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
  // متغيرات الموقع الجديدة
  LatLng? selectedLocation;
  String? locationAddress;

  final ImagePicker picker = ImagePicker();
  DateTime? offerStartDate;
  DateTime? offerEndDate;
  bool hasOffer = false;
  bool isPaused = false;
  double? priceAfterDiscount;
  List<String> selectedEventTypes = [];
  Set<DateTime> bookedDays = {};
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

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
    if (finalPriceController.text.isNotEmpty && discountController.text.isNotEmpty) {
      double finalPrice = double.parse(finalPriceController.text);
      double discount = double.parse(discountController.text);
      priceAfterDiscount = finalPrice - (finalPrice * discount / 100);
    } else {
      priceAfterDiscount = null;
    }
  }

  // Add service
  Future<void> addService(BuildContext context) async {
    
    try {
  
            // تحقق من رفع الشعار
      if (companyLogo == null) {
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

            // تحقق من رفع السجل التجاري
      if (businessLicense == null) {
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

      final bookedDaysStr = bookedDays.map((day) => DateFormat('yyyy-MM-dd').format(day)).toList();

      final service = Service(
        id: '',
        service: selectedService!,
        province: selectedProvince!,
        companyName: companyNameController.text,
        companyLogo: companyLogo?.path,
        phone: phoneController.text,
        region: regionController.text,
        email: emailController.text,
        details: detailsController.text,
        facebook: facebookController.text.isNotEmpty ? facebookController.text : null,
        instagram: instagramController.text.isNotEmpty ? instagramController.text : null,
        youtube: youtubeController.text.isNotEmpty ? youtubeController.text : null,
        priceFrom: priceFromController.text.isNotEmpty ? double.parse(priceFromController.text) : null,
        priceTo: priceToController.text.isNotEmpty ? double.parse(priceToController.text) : null,
        finalPrice: finalPriceController.text.isNotEmpty ? double.parse(finalPriceController.text) : null,
        serviceImages: [],
        timestamp: DateTime.now(),
        hasOffer: hasOffer,
        isPaused: isPaused,
        discount: hasOffer && discountController.text.isNotEmpty ? double.parse(discountController.text) : null,
        offerDetails: hasOffer ? offerDetailsController.text : null,
        offerStartDate: hasOffer ? offerStartDate : null,
        offerEndDate: hasOffer ? offerEndDate : null,
        eventTypes: selectedEventTypes,
        videoPath: serviceVideo?.path,
        // إضافة بيانات الموقع
        latitude: selectedLocation?.latitude,
        longitude: selectedLocation?.longitude,
        locationAddress: locationAddress,
        bookedDays: bookedDaysStr,
        businessLicenseUrl: null,
      );

      await ServiceProvider().addService(service, serviceImages, bookedDaysStr, businessLicense);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم اضافة الخدمة بنجاح سيتم اعلامك عندما توافق عليها الادارة',
            style: GoogleFonts.elMessiri(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.blue[800],
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  // Handle day selection in calendar
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    this.selectedDay = selectedDay;
    this.focusedDay = focusedDay;
    if (bookedDays.contains(selectedDay)) {
      bookedDays.remove(selectedDay);
    } else {
      bookedDays.add(selectedDay);
    }
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