import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../booking/services/booking_dialog_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

// Widget معلومات الخدمة
class ServiceInfoWidget extends StatelessWidget {
  final Map<String, dynamic> serviceInfo;
  final bool isSmallScreen;

  const ServiceInfoWidget({
    Key? key,
    required this.serviceInfo,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.inputFillColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, 'اسم الخدمة:', serviceInfo['serviceName']),
          _buildInfoRow(context, 'نوع الخدمة:', serviceInfo['serviceType']),
          _buildInfoRow(context, 'الموقع:', serviceInfo['location']),
          if (serviceInfo['discount'] > 0) ...[
            Divider(height: isSmallScreen ? 16 : 20, color: AppColors.borderColor(context)),
            _buildInfoRow(context, 'السعر الأصلي:', '${serviceInfo['originalPrice']} ريال', isPrice: true),
            _buildInfoRow(context, 'الخصم:', '${serviceInfo['discount']}%', isDiscount: true),
          ],
          Divider(height: isSmallScreen ? 16 : 20, color: AppColors.borderColor(context)),
          _buildInfoRow(
            context,
            'السعر النهائي:',
            '${NumberFormat().format(serviceInfo['finalPrice'])} ريال',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isPrice = false,
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 12 : 14,
                color: AppColors.textColor(context).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isDiscount
                    ? Colors.red[600]
                    : isTotal
                        ? AppColors.primary
                        : AppColors.textColor(context),
                decoration: isPrice ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget اختيار التاريخ
class DateSelectionWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Set<DateTime> bookedDates;
  final CalendarFormat calendarFormat;
  final BookingDialogRepository repository;
  final bool isSmallScreen;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(String, Color) showSnackBar;

  const DateSelectionWidget({
    Key? key,
    required this.selectedDate,
    required this.selectedTime,
    required this.bookedDates,
    required this.calendarFormat,
    required this.repository,
    required this.isSmallScreen,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onFormatChanged,
    required this.showSnackBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختيار تاريخ ووقت المناسبة:',
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TableCalendar<DateTime>(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(Duration(days: 365)),
            focusedDay: selectedDate ?? DateTime.now(),
            calendarFormat: calendarFormat,
            daysOfWeekHeight: isSmallScreen ? 35 : 40,
            rowHeight: isSmallScreen ? 40 : 45,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            enabledDayPredicate: (day) {
              return !repository.isDateBooked(day, bookedDates) &&
                  day.isAfter(DateTime.now().subtract(Duration(days: 1)));
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!repository.isDateBooked(selectedDay, bookedDates)) {
                onDateSelected(selectedDay);
                _selectTime(context);
              } else {
                showSnackBar('هذا التاريخ محجوز مسبقاً', Colors.red);
              }
            },
            onFormatChanged: onFormatChanged,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: EdgeInsets.all(isSmallScreen ? 2 : 4),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              disabledDecoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              disabledTextStyle: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              defaultTextStyle: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 12 : 14,
              ),
              weekendTextStyle: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 12 : 14,
              ),
              selectedTextStyle: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: !isSmallScreen,
              titleCentered: true,
              headerPadding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
              titleTextStyle: AppTextStyles.medium(context).copyWith(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
              formatButtonTextStyle: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 12 : 14,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, size: isSmallScreen ? 20 : 24),
              rightChevronIcon: Icon(Icons.chevron_right, size: isSmallScreen ? 20 : 24),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 11 : 13,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 11 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              disabledBuilder: (context, day, focusedDay) {
                if (repository.isDateBooked(day, bookedDates)) {
                  return Container(
                    margin: EdgeInsets.all(isSmallScreen ? 2 : 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red[300]!, width: 1),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 11 : 13,
                            ),
                          ),
                          Icon(
                            Icons.block,
                            color: Colors.red[400],
                            size: isSmallScreen ? 10 : 12,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
        if (selectedDate != null && selectedTime != null) ...[
          SizedBox(height: 12),
          _buildSelectedDateTimeDisplay(context),
        ],
        SizedBox(height: 8),
        _buildDateSelectionNote(context),
      ],
    );
  }

  Widget _buildSelectedDateTimeDisplay(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: AppColors.primary,
            size: isSmallScreen ? 16 : 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'تاريخ الحجز: ${DateFormat.yMd().format(selectedDate!)} - ${selectedTime!.format(context)}',
              style: AppTextStyles.small(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionNote(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info,
            color: Colors.red[600],
            size: isSmallScreen ? 14 : 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'التواريخ المحجوزة غير قابلة للاختيار',
              style: AppTextStyles.extraSmall(context).copyWith(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }
}

// Widget طرق الدفع
class PaymentMethodsWidget extends StatelessWidget {
  final List<String> paymentMethods;
  final int selectedPaymentMethod;
  final bool isSmallScreen;
  final Function(int) onPaymentMethodChanged;

  const PaymentMethodsWidget({
    Key? key,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
    required this.isSmallScreen,
    required this.onPaymentMethodChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الدفع:',
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: paymentMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final isSelected = selectedPaymentMethod == index;

              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                  borderRadius: index == 0
                      ? BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        )
                      : index == paymentMethods.length - 1
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            )
                          : null,
                ),
                child: RadioListTile<int>(
                  dense: isSmallScreen,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 16,
                    vertical: isSmallScreen ? 0 : 4,
                  ),
                  title: Text(
                    method,
                    style: AppTextStyles.medium(context).copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textColor(context).withOpacity(0.7),
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                  value: index,
                  groupValue: selectedPaymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (value) => onPaymentMethodChanged(value!),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}