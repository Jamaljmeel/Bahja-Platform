class ValidationService {
  // التحقق من صحة بيانات الحجز
  static Map<String, dynamic> validateBookingData({
    required DateTime? selectedDate,
    required Set<DateTime> bookedDates,
    required String notes,
  }) {
    if (selectedDate == null) {
      return {
        'isValid': false,
        'message': 'يرجى اختيار تاريخ للمناسبة',
        'color': 'orange'
      };
    }

    // التحقق من أن التاريخ ليس في الماضي
    if (selectedDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return {
        'isValid': false,
        'message': 'لا يمكن اختيار تاريخ في الماضي',
        'color': 'red'
      };
    }

    // التحقق من أن التاريخ غير محجوز
    final dateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    if (bookedDates.contains(dateOnly)) {
      return {
        'isValid': false,
        'message': 'هذا التاريخ محجوز مسبقاً',
        'color': 'red'
      };
    }

    // التحقق من طول الملاحظات
    if (notes.length > 500) {
      return {
        'isValid': false,
        'message': 'الملاحظات لا يجب أن تتجاوز 500 حرف',
        'color': 'orange'
      };
    }

    return {
      'isValid': true,
      'message': 'البيانات صحيحة',
      'color': 'green'
    };
  }

  // التحقق من التاريخ المحجوز
  static bool isDateBooked(DateTime date, Set<DateTime> bookedDates) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return bookedDates.contains(dateOnly);
  }

  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // التحقق من صحة رقم الهاتف
  static bool isValidPhone(String phone) {
    return RegExp(r'^[\+]?[0-9]{10,15}$').hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }
}