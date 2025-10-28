import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../services/notification_service .dart';
import '../utils/app_colors.dart';
import '../services/wallet_service.dart'; // إضافة الاستيراد

class BookingsPage extends StatefulWidget {
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedStatus = '';
  DateTime? selectedDate;
  bool isFilterVisible = false;
  final NotificationService _bookingRepository = NotificationService();

  // جلب الحجوزات من Firebase للمستخدم الحالي (مقدم الخدمة)
  Stream<List<BookingModel>> getBookings() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      print('لا يوجد مستخدم مسجل دخول');
      return Stream.value([]);
    }

    print('جاري جلب الحجوزات لمقدم الخدمة: $currentUserId');

    Query query = FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      print('تم جلب ${snapshot.docs.length} حجز لمقدم الخدمة');
      return snapshot.docs
          .map((doc) {
            try {
              return BookingModel.fromFirestore(doc);
            } catch (e) {
              print('خطأ في تحويل الحجز ${doc.id}: $e');
              return null;
            }
          })
          .where((booking) => booking != null)
          .cast<BookingModel>()
          .toList();
    }).handleError((error) {
      print('خطأ في جلب الحجوزات: $error');
      return <BookingModel>[];
    });
  }

  // فلترة الحجوزات
  List<BookingModel> filterBookings(List<BookingModel> bookings) {
    return bookings.where((booking) {
      bool matchesSearch = booking.serviceName
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          booking.serviceType
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      bool matchesStatus =
          selectedStatus.isEmpty || booking.status == selectedStatus;

      bool matchesDate =
          selectedDate == null || isSameDay(booking.eventDate, selectedDate!);

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // إحصائيات الحجوزات
  Widget _buildBookingStats(List<BookingModel> bookings) {
    final completedCount =
        bookings.where((b) => b.status == 'completed').length;
    final pendingCount = bookings.where((b) => b.status == 'pending').length;
    final rejectedCount = bookings.where((b) => b.status == 'rejected').length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('مكتملة', completedCount, Colors.green),
          _buildStatItem('في الانتظار', pendingCount, Colors.orange),
          _buildStatItem('مرفوضة', rejectedCount, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    final isDark =
        Theme.of(context as BuildContext).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.elMessiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.elMessiri(
            fontSize: 12,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.primaryDark.withOpacity(0.8),
                        AppColors.primaryDark.withOpacity(0.6)
                      ]
                    : [
                        AppColors.primaryLight,
                        AppColors.primaryLight.withOpacity(0.7)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            child: Column(
              children: [
                // Title and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'طلبات الحجز',
                      style: GoogleFonts.elMessiri(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isFilterVisible = !isFilterVisible;
                            });
                          },
                          icon: Icon(Icons.filter_list, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              selectedStatus = '';
                              selectedDate = null;
                              isFilterVisible = false;
                            });
                          },
                          icon: Icon(Icons.refresh, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Search Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.elMessiri(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'البحث في طلبات الحجز...',
                      hintStyle: GoogleFonts.elMessiri(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search,
                          color: Colors.white.withOpacity(0.7)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),

                // Filter Section
                if (isFilterVisible) ...[
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Status Filter
                        DropdownButtonFormField<String>(
                          value: selectedStatus.isEmpty ? null : selectedStatus,
                          onChanged: (value) =>
                              setState(() => selectedStatus = value ?? ''),
                          dropdownColor: isDark
                              ? AppColors.inputFillDark
                              : primaryColor.withOpacity(0.9),
                          style: GoogleFonts.elMessiri(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'فلترة حسب الحالة',
                            labelStyle:
                                GoogleFonts.elMessiri(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                                value: '', child: Text('جميع الحالات')),
                            DropdownMenuItem(
                                value: 'pending', child: Text('في الانتظار')),
                            DropdownMenuItem(
                                value: 'completed', child: Text('مكتمل')),
                            DropdownMenuItem(
                                value: 'rejected', child: Text('مرفوض')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bookings List
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: getBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل طلبات الحجز...',
                          style: GoogleFonts.elMessiri(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.hintTextDark
                                : AppColors.hintTextLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'حدث خطأ في تحميل طلبات الحجز',
                          style: GoogleFonts.elMessiri(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: GoogleFonts.elMessiri(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.hintTextDark
                                : AppColors.hintTextLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'إعادة المحاولة',
                            style: GoogleFonts.elMessiri(),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allBookings = snapshot.data ?? [];
                final filteredBookings = filterBookings(allBookings);

                if (allBookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: isDark
                              ? AppColors.hintTextDark
                              : AppColors.hintTextLight,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد طلبات حجز بعد',
                          style: GoogleFonts.elMessiri(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ستظهر هنا جميع طلبات الحجز لخدماتك',
                          style: GoogleFonts.elMessiri(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.hintTextDark
                                : AppColors.hintTextLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredBookings.isEmpty) {
                  return Column(
                    children: [
                      _buildBookingStats(allBookings),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: isDark
                                    ? AppColors.hintTextDark
                                    : AppColors.hintTextLight,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد نتائج',
                                style: GoogleFonts.elMessiri(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'لم يتم العثور على طلبات حجز تطابق معايير البحث',
                                style: GoogleFonts.elMessiri(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.hintTextDark
                                      : AppColors.hintTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildBookingStats(allBookings),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return BookingCard(booking: booking);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget لعرض كارت الحجز
class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceName,
                            style: GoogleFonts.elMessiri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking.serviceType,
                            style: GoogleFonts.elMessiri(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(booking.status),
                        style: GoogleFonts.elMessiri(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Details
                _buildDetailRow(
                    context,
                    Icons.event,
                    'موعد الحدث',
                    DateFormat('yyyy/MM/dd - HH:mm', 'ar')
                        .format(booking.eventDate)),
                SizedBox(height: 8),
                _buildDetailRow(
                    context,
                    Icons.monetization_on,
                    'المبلغ الإجمالي',
                    '${NumberFormat('#,###', 'ar').format(booking.finalPrice)} ريال'),
                SizedBox(height: 8),
                _buildDetailRow(context, Icons.payment, 'طريقة الدفع',
                    booking.paymentMethod),

                if (booking.notes.isNotEmpty) ...[
                  SizedBox(height: 8),
                  _buildDetailRow(
                      context, Icons.note, 'ملاحظات', booking.notes),
                ],

                SizedBox(height: 8),
                _buildDetailRow(
                    context,
                    Icons.access_time,
                    'تاريخ الطلب',
                    DateFormat('yyyy/MM/dd - HH:mm', 'ar')
                        .format(booking.bookingDate)),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark.withOpacity(0.5)
                  : AppColors.backgroundLight.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: _buildActionButtons(context, booking),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BookingModel booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    if (booking.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showConfirmDialog(context, booking, 'completed',
                    'الموافقة على الطلب وتحديد كمكتمل');
              },
              icon: Icon(Icons.check_circle, size: 18),
              label: Text(
                'موافقة',
                style: GoogleFonts.elMessiri(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showConfirmDialog(context, booking, 'rejected', 'رفض الطلب');
              },
              icon: Icon(Icons.cancel, size: 18),
              label: Text(
                'رفض',
                style: GoogleFonts.elMessiri(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showBookingDetails(context, booking);
              },
              icon: Icon(Icons.visibility, size: 18),
              label: Text(
                'عرض التفاصيل',
                style: GoogleFonts.elMessiri(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.elMessiri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.elMessiri(
              fontSize: 14,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'في الانتظار';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'تفاصيل طلب الحجز',
          style: GoogleFonts.elMessiri(
            fontWeight: FontWeight.bold,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogRow(context, 'الخدمة', booking.serviceName),
              _buildDialogRow(context, 'النوع', booking.serviceType),
              _buildDialogRow(
                  context,
                  'تاريخ الحدث',
                  DateFormat('yyyy/MM/dd - HH:mm', 'ar')
                      .format(booking.eventDate)),
              _buildDialogRow(context, 'المبلغ',
                  '${NumberFormat('#,###', 'ar').format(booking.finalPrice)} ريال'),
              _buildDialogRow(context, 'طريقة الدفع', booking.paymentMethod),
              _buildDialogRow(
                  context, 'الحالة', _getStatusText(booking.status)),
              if (booking.notes.isNotEmpty)
                _buildDialogRow(context, 'الملاحظات', booking.notes),
              _buildDialogRow(context, 'معرف العميل', booking.userId),
              _buildDialogRow(
                  context,
                  'تاريخ الطلب',
                  DateFormat('yyyy/MM/dd - HH:mm', 'ar')
                      .format(booking.bookingDate)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: GoogleFonts.elMessiri(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.elMessiri(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.elMessiri(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, BookingModel booking,
      String newStatus, String actionText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    String dialogTitle =
        newStatus == 'completed' ? 'تأكيد الموافقة' : 'تأكيد الرفض';
    String dialogContent = newStatus == 'completed'
        ? 'هل أنت متأكد من الموافقة على هذا الطلب وتحديده كمكتمل؟\n\nسيتم تحويل المبلغ ${booking.finalPrice.toStringAsFixed(0)} ريال إلى محفظتك.'
        : 'هل أنت متأكد من رفض هذا الطلب؟\n\nسيتم إرجاع المبلغ ${booking.finalPrice.toStringAsFixed(0)} ريال للعميل.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          dialogTitle,
          style: GoogleFonts.elMessiri(
            fontWeight: FontWeight.bold,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dialogContent,
              style: GoogleFonts.elMessiri(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark.withOpacity(0.5)
                    : AppColors.backgroundLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الطلب:',
                    style: GoogleFonts.elMessiri(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'الخدمة: ${booking.serviceName}',
                    style: GoogleFonts.elMessiri(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'النوع: ${booking.serviceType}',
                    style: GoogleFonts.elMessiri(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'المبلغ: ${NumberFormat('#,###', 'ar').format(booking.finalPrice)} ريال',
                    style: GoogleFonts.elMessiri(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.elMessiri(
                color:
                    isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _updateBookingStatus(booking.id, newStatus, context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'completed' ? Colors.green : Colors.red,
            ),
            child: Text(
              newStatus == 'completed' ? 'موافقة' : 'رفض',
              style: GoogleFonts.elMessiri(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _updateBookingStatus(
      String bookingId, String newStatus, BuildContext context) async {
    try {
      // 1. جلب بيانات الحجز أولاً
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) {
        throw Exception('الحجز غير موجود');
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final userId = bookingData['userId'];
      final reservedAmount = bookingData['reservedAmount'].toDouble();
      final paymentMethod = bookingData['paymentMethod'] ?? '';
      final serviceName = bookingData['serviceName'] ?? 'خدمة';
      final providerId = bookingData['providerId'];

      // 2. تحديث حالة الحجز في Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. التعامل مع المحفظة حسب نوع القرار
      final walletService = WalletService();

      if ( reservedAmount > 0) {
        if (newStatus == 'completed') {
          // الموافقة: تحويل المبلغ من المحجوز إلى مقدم الخدمة
          await walletService.confirmBookingPayment(
            userId: userId,
            providerId: providerId,
            amount: reservedAmount,
            bookingId: bookingId,
            description: 'دفعة خدمة $serviceName',
          );
        } else if (newStatus == 'rejected') {
          // الرفض: إرجاع المبلغ المحجوز للعميل
          await walletService.releaseReservedAmount(
            userId: userId,
            amount: reservedAmount,
            bookingId: bookingId,
            description: 'إرجاع مبلغ الحجز المرفوض',
          );
        }
      }

      // 4. إرسال الإشعار
      if (newStatus == 'completed') {
        await NotificationService().sendBookingCompletNotification(
          userId: userId,
          bookingId: bookingId,
          refundAmount: reservedAmount,
          context: context,
        );
      } else if (newStatus == 'rejected') {
        await NotificationService().sendBookingRejectionNotification(
          userId: userId,
          bookingId: bookingId,
          refundAmount: reservedAmount,
          context: context,
        );
      }

      // 5. إظهار رسالة نجاح
      String successMessage;
      if (newStatus == 'completed') {
        successMessage = paymentMethod == 'wallet'
            ? 'تم قبول الحجز وتحويل المبلغ ${reservedAmount.toStringAsFixed(0)} ريال إلى محفظتك'
            : 'تم قبول الحجز وإرسال الإشعار';
      } else {
        successMessage = paymentMethod == 'wallet'
            ? 'تم رفض الحجز وإرجاع المبلغ ${reservedAmount.toStringAsFixed(0)} ريال للعميل'
            : 'تم رفض الحجز وإرسال الإشعار';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: newStatus == 'completed' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('خطأ في تحديث حالة الحجز: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحديث حالة الحجز: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
