import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/add_service_controller.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_from_field.dart';
import '../utils/app_colors.dart';
import 'map_page.dart';

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  late AddServiceController _controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AddServiceController();
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
      appBar: CustomAppBar(title: 'إضافة خدمة'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // تحديد الخدمة
              _buildServiceDropdown(isDark),
              SizedBox(height: 16),

              // تحديد المحافظة
              _buildProvinceDropdown(isDark),
              SizedBox(height: 16),

              // تحديد أنواع الحفلات
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
                keyboardType: TextInputType.text,
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

              // تحديد موقع الخدمة
              _buildLocationPicker(isDark),
              SizedBox(height: 16),

              // بقية الحقول
              _buildTextFields(isDark),

              // التقويم
              _buildCalendar(isDark),

              // زر إضافة عرض
              _buildOfferButton(isDark),
              SizedBox(height: 16),

              // حقول العرض
              if (_controller.hasOffer) _buildOfferFields(isDark),

              SizedBox(height: 20),
              // زر الإضافة
              _buildAddButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDropdown(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
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
          decoration: InputDecoration(
            labelText: 'تحديد الخدمة',
            prefixIcon: Icon(
              Icons.work,
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
            labelStyle: GoogleFonts.elMessiri(
              fontSize: 14,
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
                  fontWeight: FontWeight.bold,
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
              return 'يرجى تحديد الخدمة';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildProvinceDropdown(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
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
          decoration: InputDecoration(
            labelStyle: GoogleFonts.elMessiri(
              fontSize: 14,
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
            labelText: 'تحديد المحافظة',
            prefixIcon: Icon(
              Icons.location_city,
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
                  fontWeight: FontWeight.bold,
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
        child: _controller.companyLogo == null
            ? Row(
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
              )
            : Image.file(_controller.companyLogo!, height: 100),
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
      child: _controller.businessLicense == null
          ? Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: isDark
                      ? AppColors.hintTextDark
                      : AppColors.hintTextLight,
                ),
                SizedBox(width: 10),
                Text(
                  'رفع السجل التجاري (PDF)',
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
                Icon(Icons.picture_as_pdf, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'تم اختيار السجل التجاري',
                  style: GoogleFonts.elMessiri(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
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
        child: _controller.serviceImages.isEmpty
            ? Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    color: isDark
                        ? AppColors.hintTextDark
                        : AppColors.hintTextLight,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'اختر صور الخدمة',
                    style: GoogleFonts.elMessiri(
                      color: isDark
                          ? AppColors.hintTextDark
                          : AppColors.hintTextLight,
                    ),
                  ),
                ],
              )
            : Wrap(
                children: _controller.serviceImages.map((image) {
                  return Padding(
                    padding: EdgeInsets.all(5),
                    child: Image.file(image, height: 50),
                  );
                }).toList(),
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
        child: _controller.serviceVideo == null
            ? Row(
                children: [
                  Icon(
                    Icons.video_library,
                    color: isDark
                        ? AppColors.hintTextDark
                        : AppColors.hintTextLight,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'اختر فيديو الخدمة (اختياري)',
                    style: GoogleFonts.elMessiri(
                      color: isDark
                          ? AppColors.hintTextDark
                          : AppColors.hintTextLight,
                    ),
                  ),
                ],
              )
            : Text(
                'تم اختيار فيديو',
                style: GoogleFonts.elMessiri(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
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
        // ],

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
          Center(
            child: Text(
              'حدد الايام المحجوزة',
              style: GoogleFonts.elMessiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          SizedBox(height: 16),

      TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _controller.focusedDay,
      calendarFormat: _controller.calendarFormat,
      selectedDayPredicate: (day) {
        return _controller.bookedDays.contains(day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _controller.onDaySelected(selectedDay, focusedDay);
        });
      },
      eventLoader: (day) {
        return _controller.bookedDays.contains(day) ? ['محجوز'] : [];
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: const Color.fromARGB(255, 214, 19, 152),
          shape: BoxShape.circle,
        ),
        markerSize: 8.0,
        markersMaxCount: 1,
        weekendTextStyle: TextStyle(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        defaultTextStyle: TextStyle(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        outsideTextStyle: TextStyle(
          color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
        ),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: GoogleFonts.elMessiri(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
        ],
      ),
    );
  }
  Widget _buildOfferButton(bool isDark) {
    return CustomButton(
      text: _controller.hasOffer ? 'إخفاء العرض' : 'إضافة عرض للخدمة',
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

  Widget _buildAddButton(bool isDark) {
    return CustomButton(
      text: 'إضافة الخدمة',
      isLoading: isLoading,
      onPressed: () async {
        if (_formKey.currentState!.validate() &&
            _controller.selectedService != null &&
            _controller.selectedLocation != null &&
            _controller.selectedProvince != null) {
          setState(() => isLoading = true);
          await _controller.addService(context); // تأكد أنها async
          setState(() => isLoading = false);
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
