import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../booking/services/booking_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import 'booking_status_header.dart';

// Widget الفلاتر
class FilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterChipsWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'value': 'all', 'label': 'جميع الحجوزات', 'icon': Icons.list_alt},
      {'value': 'pending', 'label': 'قيد الانتظار', 'icon': Icons.hourglass_empty},
      {'value': 'completed', 'label': 'تم الموافقة', 'icon': Icons.check_circle},
      {'value': 'rejected', 'label': 'مرفوض', 'icon': Icons.cancel},
      {'value': 'cancelled', 'label': 'ملغى', 'icon': Icons.delete},
    ];

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderColor(context).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            return Padding(
              padding: EdgeInsets.only(left: 8),
              child: _buildFilterChip(
                context,
                filter['value'] as String,
                filter['label'] as String,
                filter['icon'] as IconData,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label, IconData icon) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.inputFillColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textColor(context).withOpacity(0.6),
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.small(context).copyWith(
                color: isSelected ? Colors.white : AppColors.textColor(context).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget قائمة الحجوزات
class BookingListWidget extends StatelessWidget {
  final String userId;
  final String selectedFilter;
  final AnimationController animationController;
  final Animation<double> fadeAnimation;
  final bool isLoading;
  final Function(bool) onLoadingChanged;
  final BookingRepository bookingRepository;

  const BookingListWidget({
    Key? key,
    required this.userId,
    required this.selectedFilter,
    required this.animationController,
    required this.fadeAnimation,
    required this.isLoading,
    required this.onLoadingChanged,
    required this.bookingRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: bookingRepository.getUserBookings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !isLoading) {
          return LoadingStateWidget();
        }

        if (snapshot.hasError) {
          return ErrorStateWidget(
            fadeAnimation: fadeAnimation,
            onRetry: () => onLoadingChanged(true),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyStateWidget(fadeAnimation: fadeAnimation);
        }

        final allBookings = snapshot.data!.docs;
        final filteredBookings = bookingRepository.filterBookingsByStatus(
          allBookings,
          selectedFilter,
        );

        return RefreshIndicator(
          onRefresh: () async {
            onLoadingChanged(true);
            await Future.delayed(Duration(seconds: 1));
            onLoadingChanged(false);
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index].data() as Map<String, dynamic>;
              final bookingId = filteredBookings[index].id;
              return AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animationController,
                      curve: Interval(
                        (index * 0.1).clamp(0.0, 1.0),
                        ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    )),
                    child: BookingCardWidget(
                      booking: booking,
                      bookingId: bookingId,
                      bookingRepository: bookingRepository,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Widget كارت الحجز
class BookingCardWidget extends StatefulWidget {
  final Map<String, dynamic> booking;
  final String bookingId;
  final BookingRepository bookingRepository;

  const BookingCardWidget({
    Key? key,
    required this.booking,
    required this.bookingId,
    required this.bookingRepository,
  }) : super(key: key);

  @override
  _BookingCardWidgetState createState() => _BookingCardWidgetState();
}

class _BookingCardWidgetState extends State<BookingCardWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bookingDetails = widget.bookingRepository.getBookingDetails(widget.booking);
    final statusInfo = widget.bookingRepository.getStatusInfo(bookingDetails['status']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.inputFillColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderColor(context).withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildStatusHeader(statusInfo, bookingDetails['bookingDate']),
            _buildCardContent(bookingDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Map<String, dynamic> statusInfo, DateTime bookingDate) {
    final colors = statusInfo['colors'] as List<String>;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse('0xFF${colors[0].substring(1)}')),
            Color(int.parse('0xFF${colors[1].substring(1)}')),
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconData(statusInfo['icon']),
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            statusInfo['text'],
            style: AppTextStyles.medium(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('dd/MM/yyyy').format(bookingDate),
              style: AppTextStyles.small(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(Map<String, dynamic> bookingDetails) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceInfo(bookingDetails),
          SizedBox(height: 16),
          Divider(height: 1, color: AppColors.borderColor(context)),
          SizedBox(height: 16),
          _buildBookingDetails(bookingDetails),
          if (bookingDetails['status'] == 'pending') ...[
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceInfo(Map<String, dynamic> bookingDetails) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.business_center,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookingDetails['serviceName'],
                style: AppTextStyles.large(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                bookingDetails['serviceType'],
                style: AppTextStyles.medium(context).copyWith(
                  color: AppColors.textColor(context).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Text(
            '${bookingDetails['finalPrice'].toStringAsFixed(0)} ريال',
            style: AppTextStyles.medium(context).copyWith(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetails(Map<String, dynamic> bookingDetails) {
    return Column(
      children: [
        _buildDetailRow(Icons.payment, 'طريقة الدفع', bookingDetails['paymentMethod']),
        if (bookingDetails['eventDate'] != null) ...[
          SizedBox(height: 8),
          _buildDetailRow(
            Icons.event,
            'تاريخ المناسبة',
            DateFormat('yyyy/MM/dd - hh:mm a').format(bookingDetails['eventDate']),
          ),
        ],
        if (bookingDetails['notes'].isNotEmpty) ...[
          SizedBox(height: 8),
          _buildDetailRow(Icons.note_alt, 'ملاحظات', bookingDetails['notes']),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.borderColor(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.textColor(context).withOpacity(0.6)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.small(context).copyWith(
                  color: AppColors.textColor(context).withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.medium(context).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.cancel, size: 18),
            label: Text(
              'إلغاء الحجز',
              style: AppTextStyles.medium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            onPressed: () => _showCancelDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[200]!),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      case 'delete':
        return Icons.delete;
      default:
        return Icons.hourglass_empty;
    }
  }

  Future<void> _showCancelDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'إلغاء الحجز',
              style: AppTextStyles.large(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من إلغاء هذا الحجز؟ لن تتمكن من التراجع عن هذا الإجراء.',
          style: AppTextStyles.medium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'تراجع',
              style: AppTextStyles.medium(context).copyWith(
                color: AppColors.textColor(context).withOpacity(0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'تأكيد الإلغاء',
              style: AppTextStyles.medium(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking() async {
    try {
      setState(() => _isLoading = true);
      await widget.bookingRepository.cancelBooking(widget.bookingId);
      _showSuccessSnackBar('تم إلغاء الحجز بنجاح');
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء إلغاء الحجز');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message, style: AppTextStyles.medium(context).copyWith(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(message, style: AppTextStyles.medium(context).copyWith(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}