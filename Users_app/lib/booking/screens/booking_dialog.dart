import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/wallet_service.dart';
import '../../utils/constants.dart';
import '../services/booking_dialog_repository.dart';
import '../widgets/dialog_components.dart';
import '../widgets/dialog_inputs.dart';

class BookingDialog extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  final String providerId;

  const BookingDialog({
    Key? key,
    required this.serviceData,
    required this.providerId,
  }) : super(key: key);

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog>
    with TickerProviderStateMixin {
  int _selectedPaymentMethod = 0;
  final List<String> _paymentMethods = [
    'دفع كامل من المحفظة',
    'دفع قسط من المبلغ'
  ];
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _partialAmountController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  Set<DateTime> _bookedDates = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final WalletService _walletService = WalletService();
  final TextEditingController _walletPinController = TextEditingController();
  double _currentWalletBalance = 0.0;
  double _availableBalance = 0.0;
  double _reservedBalance = 0.0;

  final BookingDialogRepository _repository = BookingDialogRepository();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
    _loadBookedDates();
    _loadWalletInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    _partialAmountController.dispose();
    _walletPinController.dispose();
    super.dispose();
  }

  Future<void> _loadBookedDates() async {
    try {
      final bookedDates = await _repository.getBookedDates(widget.providerId);
      setState(() {
        _bookedDates = bookedDates;
      });
    } catch (e) {
      _showSnackBar('خطأ في تحميل التواريخ المحجوزة', Colors.orange);
    }
  }

  Future<void> _loadWalletInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final balance = await _walletService.getBalance(user.uid);
        final available = await _walletService.getAvailableBalance(user.uid);
        final reserved = await _walletService.getReservedBalance(user.uid);
        
        setState(() {
          _currentWalletBalance = balance;
          _availableBalance = available;
          _reservedBalance = reserved;
        });
      } catch (e) {
        print('خطأ في تحميل معلومات المحفظة: $e');
      }
    }
  }

  Future<void> _confirmBooking() async {
    // 1. التحقق من صحة البيانات الأساسية
    final validationResult = _repository.validateBookingData(
      selectedDate: _selectedDate,
      bookedDates: _bookedDates,
      notes: _notesController.text,
    );

    if (!validationResult['isValid']) {
      final color = validationResult['color'] == 'red' ? Colors.red : Colors.orange;
      _showSnackBar(validationResult['message'], color);
      return;
    }

    // 2. التحقق من التوقيت المحدد
    if (_selectedTime == null) {
      _showSnackBar('يرجى اختيار وقت المناسبة', Colors.orange);
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final serviceInfo = _repository.getServiceDisplayInfo(widget.serviceData);
    final totalAmount = serviceInfo['finalPrice'];
    
    // 3. تحديد المبلغ المراد حجزه حسب طريقة الدفع
    double amountToReserve = totalAmount;
    if (_selectedPaymentMethod == 1) { // دفع قسط
      if (_partialAmountController.text.isEmpty) {
        _showSnackBar('يرجى إدخال مبلغ القسط', Colors.orange);
        return;
      }
      
      final partialAmount = double.tryParse(_partialAmountController.text);
      if (partialAmount == null || partialAmount <= 0) {
        _showSnackBar('يرجى إدخال مبلغ قسط صحيح', Colors.red);
        return;
      }
      
      if (partialAmount > totalAmount) {
        _showSnackBar('لا يمكن أن يكون مبلغ القسط أكبر من المبلغ الإجمالي', Colors.red);
        return;
      }
      
      amountToReserve = partialAmount;
    }

    // 4. التحقق من رمز المحفظة
    if (_walletPinController.text.length != 4) {
      _showSnackBar('يجب إدخال رمز المحفظة المكون من 4 أرقام', Colors.red);
      return;
    }

    // التحقق من صحة رمز المحفظة
    final isValidPin = await _walletService.verifyPin(user.uid, _walletPinController.text);
    if (!isValidPin) {
      _showSnackBar('رمز المحفظة غير صحيح', Colors.red);
      return;
    }

    // 5. التحقق من كفاية الرصيد
    final paymentValidation = await _repository.validatePaymentMethod(
      paymentMethod: 'wallet',
      userId: user.uid,
      amount: amountToReserve,
    );

    if (!paymentValidation['isValid']) {
      _showSnackBar(paymentValidation['message'], Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 6. إنشاء الحجز مع حجز المبلغ
      final result = await _repository.createBooking(
        providerId: widget.providerId,
        serviceData: widget.serviceData,
        selectedDate: _selectedDate!,
        selectedTime: _selectedTime!,
        paymentMethod: _selectedPaymentMethod == 0 ? 'wallet' : 'partial_wallet',
        notes: _notesController.text,
        reservedAmount: amountToReserve,
      );

      if (result['success']) {
        // تحديث معلومات المحفظة بعد الحجز
        await _loadWalletInfo();

        Navigator.pop(context, true);
        _showSnackBar(result['message'], Colors.green);
      } else {
        _showSnackBar(result['message'], Colors.red);
        
        // إذا كان المشكلة نقص رصيد، اعرض خيارات إضافية
        if (result['type'] == 'insufficient_balance') {
          _showChargeWalletDialog();
        }
      }
    } catch (e) {
      print('خطأ في تأكيد الحجز: $e');
      _showSnackBar('حدث خطأ أثناء تأكيد الحجز: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showChargeWalletDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'رصيد المحفظة غير كافي',
              style: AppTextStyles.large(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الرصيد المتاح: ${_availableBalance.toStringAsFixed(0)} ريال',
              style: AppTextStyles.medium(context),
            ),
            if (_reservedBalance > 0) ...[
              SizedBox(height: 4),
              Text(
                'الرصيد المحجوز: ${_reservedBalance.toStringAsFixed(0)} ريال',
                style: AppTextStyles.small(context).copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
            SizedBox(height: 16),
            Text(
              'يرجى شحن المحفظة والمحاولة مرة أخرى',
              style: AppTextStyles.medium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'موافق',
              style: AppTextStyles.medium(context).copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message, 
                style: AppTextStyles.medium(context).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final serviceInfo = _repository.getServiceDisplayInfo(widget.serviceData);

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 16, vertical: 24),
        child: Container(
          width: screenSize.width,
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.92,
            maxWidth: 500,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(context),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderColor(context).withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isSmallScreen),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContent(serviceInfo, isSmallScreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isSmallScreen ? 16 : 20),
          topRight: Radius.circular(isSmallScreen ? 16 : 20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event_available,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'حجز خدمة جديدة',
              style: AppTextStyles.large(context).copyWith(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> serviceInfo, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceInfoWidget(
            serviceInfo: serviceInfo,
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          DateSelectionWidget(
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            bookedDates: _bookedDates,
            calendarFormat: _calendarFormat,
            repository: _repository,
            isSmallScreen: isSmallScreen,
            onDateSelected: (date) => setState(() => _selectedDate = date),
            onTimeSelected: (time) => setState(() => _selectedTime = time),
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            showSnackBar: _showSnackBar,
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          _buildPaymentMethods(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildWalletInfo(isSmallScreen),
          if (_selectedPaymentMethod == 1) ...[
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildPartialAmountInput(isSmallScreen),
          ],
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildWalletPinInput(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 24),
          NotesInputWidget(
            controller: _notesController,
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 20 : 30),
          ActionButtonsWidget(
            isLoading: _isLoading,
            isSmallScreen: isSmallScreen,
            onCancel: () => Navigator.pop(context),
            onConfirm: _confirmBooking,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الدفع',
          style: AppTextStyles.large(context).copyWith(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        ...List.generate(_paymentMethods.length, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == index
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.inputFillColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedPaymentMethod == index
                    ? AppColors.primary
                    : AppColors.borderColor(context),
                width: _selectedPaymentMethod == index ? 2 : 1,
              ),
            ),
            child: RadioListTile<int>(
              value: index,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              title: Row(
                children: [
                  Icon(
                    index == 0 ? Icons.account_balance_wallet : Icons.payment,
                    color: _selectedPaymentMethod == index
                        ? AppColors.primary
                        : AppColors.textColor(context).withOpacity(0.6),
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _paymentMethods[index],
                      style: AppTextStyles.medium(context).copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: _selectedPaymentMethod == index
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _selectedPaymentMethod == index
                            ? AppColors.primary
                            : AppColors.textColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWalletInfo(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, 
                   color: AppColors.primary, 
                   size: isSmallScreen ? 16 : 18),
              SizedBox(width: 8),
              Text(
                'معلومات المحفظة',
                style: AppTextStyles.medium(context).copyWith(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الرصيد المتاح:',
                style: AppTextStyles.small(context).copyWith(
                  color: AppColors.textColor(context).withOpacity(0.7),
                ),
              ),
              Text(
                '${_availableBalance.toStringAsFixed(0)} ريال',
                style: AppTextStyles.medium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (_reservedBalance > 0) ...[
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الرصيد المحجوز:',
                  style: AppTextStyles.small(context).copyWith(
                    color: AppColors.textColor(context).withOpacity(0.7),
                  ),
                ),
                Text(
                  '${_reservedBalance.toStringAsFixed(0)} ريال',
                  style: AppTextStyles.small(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المبلغ المطلوب:',
                style: AppTextStyles.small(context).copyWith(
                  color: AppColors.textColor(context).withOpacity(0.7),
                ),
              ),
              Text(
                '${_repository.getServiceDisplayInfo(widget.serviceData)['finalPrice'].toStringAsFixed(0)} ريال',
                style: AppTextStyles.medium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartialAmountInput(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مبلغ القسط',
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: _partialAmountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 14 : 16,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل مبلغ القسط المراد دفعه',
            hintStyle: AppTextStyles.small(context).copyWith(
              color: AppColors.textColor(context).withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.payments_outlined,
              color: AppColors.textColor(context).withOpacity(0.6),
              size: isSmallScreen ? 20 : 24,
            ),
            suffixText: 'ريال',
            suffixStyle: AppTextStyles.small(context).copyWith(
              color: AppColors.textColor(context).withOpacity(0.6),
            ),
            filled: true,
            fillColor: AppColors.inputFillColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isSmallScreen ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletPinInput(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رمز المحفظة',
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: _walletPinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 14 : 16,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل رمز المحفظة (4 أرقام)',
            hintStyle: AppTextStyles.small(context).copyWith(
              color: AppColors.textColor(context).withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppColors.textColor(context).withOpacity(0.6),
              size: isSmallScreen ? 20 : 24,
            ),
            filled: true,
            fillColor: AppColors.inputFillColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            counterText: '',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isSmallScreen ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }
}