import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:services_providers/screens/map_page.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/service_model.dart';
import '../services/edit_service_controller.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_from_field.dart';
import '../utils/app_colors.dart';

class EditServicePage extends StatefulWidget {
  final Service service;

  EditServicePage({required this.service});

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  late EditServiceController _controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = EditServiceController();
    _controller.initializeData(widget.service);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(title: 'تعديل الخدمة'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // نوع الخدمة
              _buildServiceDropdown(isDark),
              SizedBox(height: 16),

              // المحافظة
              _buildProvinceDropdown(isDark),
              SizedBox(height: 16),

              // أنواع الحفلات
              _buildEventTypesSection(isDark),
              SizedBox(height: 16),

              // اسم الشركة
              CustomTextField(
                controller: _controller.companyNameController,
                hintText: 'اسم الشركة',
                prefixIcon: Icon(
                  Icons.business,
                  color:
                      isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الشركة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // شعار الشركة
              _buildCompanyLogoPicker(isDark),
              SizedBox(height: 16),

              // السجل التجاري (PDF)
              _buildBusinessLicensePicker(isDark),
              SizedBox(height: 16),

              // صور الخدمة
              _buildServiceImagesPicker(isDark),
              SizedBox(height: 16),

              // فيديو الخدمة
              _buildServiceVideoPicker(isDark),
              SizedBox(height: 16),

              _buildLocationPicker(isDark),
              SizedBox(height: 16),

              // بقية الحقول
              _buildTextFields(isDark),

              // التقويم
              _buildCalendar(isDark),
              SizedBox(height: 16),

              // زر العرض
              _buildOfferButton(isDark),
              SizedBox(height: 16),

              // حقول العرض
              if (_controller.hasOffer) _buildOfferFields(isDark),

              SizedBox(height: 20),
              // زر الحفظ
              _buildSaveButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDropdown(bool isDark) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('services').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          );
        }
        if (snapshot.hasError) {
          return Text(
            'حدث خطأ: ${snapshot.error}',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'لا توجد خدمات متاحة',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          );
        }
        final services = snapshot.data!.docs;
        return DropdownButtonFormField<dynamic>(
          value: _controller.selectedService,
          dropdownColor:
              isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          style: GoogleFonts.elMessiri(
            fontSize: 16,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            labelText: 'نوع الخدمة',
            prefixIcon: Icon(
              Icons.work,
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
            labelStyle: GoogleFonts.elMessiri(
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
            filled: true,
            fillColor:
                isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                width: 2,
              ),
            ),
          ),
          items: services.map((service) {
            return DropdownMenuItem(
              value: service['name'],
              child: Text(
                service['name'],
                style: GoogleFonts.elMessiri(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _controller.selectedService = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'يرجى تحديد نوع الخدمة';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildProvinceDropdown(bool isDark) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('provinces').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          );
        }
        if (snapshot.hasError) {
          return Text(
            'حدث خطأ: ${snapshot.error}',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'لا توجد محافظات متاحة',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          );
        }
        final provinces = snapshot.data!.docs;
        return DropdownButtonFormField<dynamic>(
          value: _controller.selectedProvince,
          dropdownColor:
              isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          style: GoogleFonts.elMessiri(
            fontSize: 16,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            labelText: 'اسم المحافظة',
            prefixIcon: Icon(
              Icons.location_city,
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
            labelStyle: GoogleFonts.elMessiri(
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
            filled: true,
            fillColor:
                isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                width: 2,
              ),
            ),
          ),
          items: provinces.map((province) {
            return DropdownMenuItem(
              value: province['name'],
              child: Text(
                province['name'],
                style: GoogleFonts.elMessiri(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _controller.selectedProvince = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'يرجى تحديد المحافظة';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildEventTypesSection(bool isDark) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('event_types').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          );
        }
        if (snapshot.hasError) {
          return Text(
            'حدث خطأ: ${snapshot.error}',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'لا توجد أنواع حفلات متاحة',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          );
        }
        final eventTypes = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر أنواع الحفلات:',
              style: GoogleFonts.elMessiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            ...eventTypes.map((eventType) {
              final eventTypeValue = eventType['eventType'];
              return CheckboxListTile(
                title: Text(
                  eventTypeValue,
                  style: GoogleFonts.elMessiri(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                value: _controller.selectedEventTypes.contains(eventTypeValue),
                activeColor:
                    isDark ? AppColors.primaryDark : AppColors.primaryLight,
                checkColor: Colors.white,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _controller.selectedEventTypes.add(eventTypeValue);
                    } else {
                      _controller.selectedEventTypes.remove(eventTypeValue);
                    }
                  });
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildCompanyLogoPicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        await _controller.pickCompanyLogo();
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        ),
        child: _controller.companyLogo != null
            ? Column(
                children: [
                  Image.file(_controller.companyLogo!, height: 100),
                  SizedBox(height: 8),
                  Text(
                    'شعار جديد',
                    style: GoogleFonts.elMessiri(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : _controller.originalCompanyLogoUrl != null
                ? Column(
                    children: [
                      Image.network(
                        _controller.originalCompanyLogoUrl!,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, color: Colors.red);
                        },
                      ),
                      SizedBox(height: 8),
                      Text(
                        'اضغط لتغيير الشعار',
                        style: GoogleFonts.elMessiri(
                          color: isDark
                              ? AppColors.hintTextDark
                              : AppColors.hintTextLight,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: isDark
                            ? AppColors.hintTextDark
                            : AppColors.hintTextLight,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'اختر شعار الشركة',
                        style: GoogleFonts.elMessiri(
                          color: isDark
                              ? AppColors.hintTextDark
                              : AppColors.hintTextLight,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildBusinessLicensePicker(bool isDark) {
  return GestureDetector(
    onTap: () async {
      await _controller.pickBusinessLicense();
      setState(() {});
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(10),
        color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller.businessLicense != null) ...[
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'تم اختيار سجل تجاري جديد',
                  style: GoogleFonts.elMessiri(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
          if (_controller.originalBusinessLicenseUrl != null &&
              _controller.businessLicense == null) ...[
            Row(
              children: [
                Icon(Icons.picture_as_pdf,
                    color: isDark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight),
                SizedBox(width: 8),
                Text(
                  'يوجد سجل تجاري حالي',
                  style: GoogleFonts.elMessiri(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color:
                    isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
              ),
              SizedBox(width: 10),
              Text(
                _controller.businessLicense == null &&
                        _controller.originalBusinessLicenseUrl == null
                    ? 'رفع السجل التجاري (PDF)'
                    : 'اضغط لتغيير السجل التجاري',
                style: GoogleFonts.elMessiri(
                  color: isDark
                      ? AppColors.hintTextDark
                      : AppColors.hintTextLight,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildServiceImagesPicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        await _controller.pickServiceImages();
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_controller.serviceImages.isNotEmpty) ...[
              Text(
                'صور جديدة:',
                style: GoogleFonts.elMessiri(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                children: _controller.serviceImages.map((image) {
                  return Padding(
                    padding: EdgeInsets.all(5),
                    child: Image.file(image, height: 50),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
            ],
            if (_controller.originalServiceImageUrls.isNotEmpty) ...[
              Text(
                'الصور الحالية:',
                style: GoogleFonts.elMessiri(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                children: _controller.originalServiceImageUrls.map((url) {
                  return Padding(
                    padding: EdgeInsets.all(5),
                    child: Image.network(
                      url,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, color: Colors.red);
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(
                  Icons.photo_library,
                  color:
                      isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                ),
                SizedBox(width: 10),
                Text(
                  _controller.serviceImages.isEmpty &&
                          _controller.originalServiceImageUrls.isEmpty
                      ? 'اختر صور الخدمة'
                      : 'اضغط لتغيير الصور',
                  style: GoogleFonts.elMessiri(
                    color: isDark
                        ? AppColors.hintTextDark
                        : AppColors.hintTextLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceVideoPicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        await _controller.pickServiceVideo();
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_controller.serviceVideo != null) ...[
              Row(
                children: [
                  Icon(Icons.videocam, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'تم اختيار فيديو جديد',
                    style: GoogleFonts.elMessiri(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            if (_controller.originalVideoUrl != null &&
                _controller.serviceVideo == null) ...[
              Row(
                children: [
                  Icon(Icons.videocam,
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight),
                  SizedBox(width: 8),
                  Text(
                    'يوجد فيديو حالي',
                    style: GoogleFonts.elMessiri(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(
                  Icons.video_library,
                  color:
                      isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                ),
                SizedBox(width: 10),
                Text(
                  _controller.serviceVideo == null &&
                          _controller.originalVideoUrl == null
                      ? 'اختر فيديو الخدمة (اختياري)'
                      : 'اضغط لتغيير الفيديو',
                  style: GoogleFonts.elMessiri(
                    color: isDark
                        ? AppColors.hintTextDark
                        : AppColors.hintTextLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        await _showLocationPicker();
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        ),
        child: _controller.selectedLocation == null
            ? Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: isDark
                        ? AppColors.hintTextDark
                        : AppColors.hintTextLight,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تحديد موقع الخدمة على الخريطة',
                      style: GoogleFonts.elMessiri(
                        color: isDark
                            ? AppColors.hintTextDark
                            : AppColors.hintTextLight,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark
                        ? AppColors.hintTextDark
                        : AppColors.hintTextLight,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تم تحديد الموقع',
                          style: GoogleFonts.elMessiri(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (_controller.locationAddress != null)
                    Text(
                      _controller.locationAddress!,
                      style: GoogleFonts.elMessiri(
                        color: isDark
                            ? AppColors.hintTextDark
                            : AppColors.hintTextLight,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _showLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _controller.selectedLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _controller.selectedLocation = result['location'];
        _controller.locationAddress = result['address'];
      });
    }
  }

  Widget _buildTextFields(bool isDark) {
    return Column(
      children: [
        // رقم الهاتف
        CustomTextField(
          controller: _controller.phoneController,
          hintText: 'رقم الهاتف',
          prefixIcon: Icon(
            Icons.phone,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال رقم الهاتف';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // اسم المنطقة
        CustomTextField(
          controller: _controller.regionController,
          hintText: 'اسم المنطقة',
          prefixIcon: Icon(
            Icons.location_on,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال اسم المنطقة';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // البريد الإلكتروني
        CustomTextField(
          controller: _controller.emailController,
          hintText: 'البريد الإلكتروني',
          prefixIcon: Icon(
            Icons.email,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // التفاصيل
        CustomTextField(
          controller: _controller.detailsController,
          hintText: 'تفاصيل الخدمة',
          prefixIcon: Icon(
            Icons.description,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال تفاصيل الخدمة';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // رابط الفيسبوك
        CustomTextField(
          controller: _controller.facebookController,
          hintText: 'رابط الفيسبوك (اختياري)',
          prefixIcon: Icon(
            Icons.facebook,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 16),

        // رابط الإنستجرام
        CustomTextField(
          controller: _controller.instagramController,
          hintText: 'رابط الإنستجرام (اختياري)',
          prefixIcon: Icon(
            Icons.camera_alt,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 16),

        // رابط اليوتيوب
        CustomTextField(
          controller: _controller.youtubeController,
          hintText: 'رابط اليوتيوب (اختياري)',
          prefixIcon: Icon(
            Icons.video_library,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 16),

        CustomTextField(
          controller: _controller.finalPriceController,
          hintText: 'السعر النهائي',
          prefixIcon: Icon(
            Icons.attach_money,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),

        // السعر من (اختياري)
        CustomTextField(
          controller: _controller.priceFromController,
          hintText: 'السعر من (اختياري)',
          prefixIcon: Icon(
            Icons.attach_money,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),

        // السعر إلى (اختياري)
        CustomTextField(
          controller: _controller.priceToController,
          hintText: 'السعر إلى (اختياري)',
          prefixIcon: Icon(
            Icons.attach_money,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
      ],
    );
  }

Widget _buildCalendar(bool isDark) {
  print("بناء التقويم - الأيام المحجوزة: ${_controller.bookedDays}");
  
  return Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    ),
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأيام المحجوزة (اضغط لتحديد/إلغاء الحجز):',
          style: GoogleFonts.elMessiri(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 16),
        TableCalendar<String>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _controller.focusedDay,
          calendarFormat: _controller.calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.saturday, // ✅ البدء بالسبت
          
          // ✅ التحقق من الأيام المحجوزة - مُصحح
          selectedDayPredicate: (day) {
            DateTime normalizedDay = DateTime(day.year, day.month, day.day);
            bool isSelected = _controller.bookedDays.contains(normalizedDay);
            print("selectedDayPredicate للتاريخ $normalizedDay: $isSelected");
            return isSelected;
          },
          
          // ✅ عند اختيار يوم - مُصحح
          onDaySelected: (selectedDay, focusedDay) {
            print("onDaySelected: $selectedDay");
            setState(() {
              _controller.onDaySelected(selectedDay, focusedDay);
            });
          },
          
          // ✅ تحديد الأحداث للأيام المحجوزة
          eventLoader: (day) {
            DateTime normalizedDay = DateTime(day.year, day.month, day.day);
            return _controller.bookedDays.contains(normalizedDay) ? ['محجوز'] : [];
          },
          
          // ✅ تنسيق التقويم - مُصحح
          calendarStyle: CalendarStyle(
            // ✅ الأيام المحجوزة (المحددة) باللون الأحمر
            selectedDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            
            // ✅ اليوم الحالي باللون الأزرق
            todayDecoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            
            // ✅ مؤشرات الأحداث (النقاط تحت التاريخ)
            markerDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            markerSize: 8.0,
            markersMaxCount: 1,
            
            // ✅ ألوان النصوص
            weekendTextStyle: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            defaultTextStyle: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            outsideTextStyle: TextStyle(
              color:
                  isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
          ),
          
          // ✅ تنسيق الهيدر
          headerStyle: HeaderStyle(
            titleTextStyle: GoogleFonts.elMessiri(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            formatButtonTextStyle: GoogleFonts.elMessiri(
              color: Colors.white,
            ),
            formatButtonDecoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
          ),
        ),
        SizedBox(height: 12),
        
        // ✅ مؤشر توضيحي مُحسن
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'الأيام المحجوزة',
              style: GoogleFonts.elMessiri(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 20),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'اليوم الحالي',
              style: GoogleFonts.elMessiri(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildOfferButton(bool isDark) {
    return CustomButton(
      text: _controller.hasOffer ? 'إخفاء العرض' : 'تعديل عرض الخدمة',
      onPressed: () {
        setState(() {
          _controller.hasOffer = !_controller.hasOffer;
        });
      },
      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      textColor: Colors.white,
    );
  }

  Widget _buildOfferFields(bool isDark) {
    return Column(
      children: [
        TextFormField(
          controller: _controller.discountController,
          style: GoogleFonts.elMessiri(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            labelStyle: GoogleFonts.elMessiri(
              fontSize: 14,
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
            labelText: 'نسبة الخصم (%)',
            prefixIcon: Icon(
              Icons.discount,
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
            filled: true,
            fillColor:
                isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _controller.calculatePriceAfterDiscount();
            setState(() {});
          },
        ),
        SizedBox(height: 16),

        // تفاصيل العرض
        CustomTextField(
          controller: _controller.offerDetailsController,
          hintText: 'تفاصيل العرض',
          prefixIcon: Icon(
            Icons.description,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
          maxLines: 3,
        ),
        SizedBox(height: 16),

        // تحديد تاريخ بداية العرض
        ListTile(
          tileColor:
              isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          title: Text(
            'بداية العرض: ${_controller.offerStartDate != null ? DateFormat('yyyy-MM-dd').format(_controller.offerStartDate!) : 'لم يتم التحديد'}',
            style: GoogleFonts.elMessiri(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          trailing: Icon(
            Icons.calendar_today,
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          ),
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              setState(() {
                _controller.offerStartDate = selectedDate;
              });
            }
          },
        ),
        SizedBox(height: 16),

        // تحديد تاريخ نهاية العرض
        ListTile(
          tileColor:
              isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          title: Text(
            'نهاية العرض: ${_controller.offerEndDate != null ? DateFormat('yyyy-MM-dd').format(_controller.offerEndDate!) : 'لم يتم التحديد'}',
            style: GoogleFonts.elMessiri(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          trailing: Icon(
            Icons.calendar_today,
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          ),
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              setState(() {
                _controller.offerEndDate = selectedDate;
              });
            }
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

Widget _buildSaveButton(bool isDark) {
  return CustomButton(
    text: 'حفظ التعديلات',
    isLoading: isLoading,
    onPressed: () async {  // ✅ إضافة async هنا
      if (_formKey.currentState!.validate() &&
          _controller.selectedService != null &&
          _controller.selectedProvince != null &&
          _controller.selectedLocation != null) {

        setState(() => isLoading = true);
        try {
          // ✅ انتظار انتهاء العملية
          await _controller.updateService(context, widget.service);
        } catch (e) {
          // ✅ التعامل مع الأخطاء
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'حدث خطأ: $e',
                style: GoogleFonts.elMessiri(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          // ✅ إيقاف التحميل في جميع الحالات
          if (mounted) {
            setState(() => isLoading = false);
          }
        }
      } else if (_controller.selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يرجى تحديد موقع الخدمة على الخريطة',
              style: GoogleFonts.elMessiri(),
            ),
          ),
        );
      }
    },
    backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
    textColor: Colors.white,
  );
}
}
