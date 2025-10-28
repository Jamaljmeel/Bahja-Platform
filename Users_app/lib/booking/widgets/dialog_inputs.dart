import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

// Widget إدخال رمز المحفظة
class WalletPinInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final int selectedPaymentMethod;
  final double currentWalletBalance;
  final bool isSmallScreen;

  const WalletPinInputWidget({
    Key? key,
    required this.controller,
    required this.selectedPaymentMethod,
    required this.currentWalletBalance,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedPaymentMethod < 0) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Row(
          children: [
            Text(
              'رمز المحفظة:',
              style: AppTextStyles.medium(context).copyWith(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text(
              'الرصيد: ${currentWalletBalance.toStringAsFixed(2)} ريال',
              style: AppTextStyles.small(context).copyWith(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 13 : 14,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '• • • •',
            hintStyle: AppTextStyles.medium(context).copyWith(
              color: AppColors.textColor(context).withOpacity(0.5),
              letterSpacing: 8,
            ),
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
              borderSide: BorderSide(color: AppColors.primary),
            ),
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
            counterText: '',
            fillColor: AppColors.inputFillColor(context),
            filled: true,
          ),
        ),
      ],
    );
  }
}

// Widget إدخال مبلغ العربون
class DepositAmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final int selectedPaymentMethod;
  final bool isSmallScreen;

  const DepositAmountInputWidget({
    Key? key,
    required this.controller,
    required this.selectedPaymentMethod,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedPaymentMethod != 1) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'مبلغ العربون:',
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 13 : 14,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل مبلغ القسط',
            hintStyle: AppTextStyles.medium(context).copyWith(
              color: AppColors.textColor(context).withOpacity(0.5),
            ),
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
              borderSide: BorderSide(color: AppColors.primary),
            ),
            prefixIcon: Icon(Icons.monetization_on, color: AppColors.primary),
            suffixText: 'ريال',
            suffixStyle: AppTextStyles.medium(context),
            fillColor: AppColors.inputFillColor(context),
            filled: true,
          ),
        ),
      ],
    );
  }
}

// Widget إدخال الملاحظات
class NotesInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isSmallScreen;

  const NotesInputWidget({
    Key? key,
    required this.controller,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات إضافية:',
          style: AppTextStyles.medium(context).copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor(context)),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'أضف ملاحظات خاصة بالخدمة...',
              hintStyle: AppTextStyles.medium(context).copyWith(
                color: AppColors.textColor(context).withOpacity(0.5),
                fontSize: isSmallScreen ? 13 : 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              fillColor: AppColors.inputFillColor(context),
              filled: true,
            ),
            style: AppTextStyles.medium(context).copyWith(
              fontSize: isSmallScreen ? 13 : 14,
            ),
            maxLines: isSmallScreen ? 2 : 3,
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}

// Widget أزرار العمليات
class ActionButtonsWidget extends StatelessWidget {
  final bool isLoading;
  final bool isSmallScreen;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ActionButtonsWidget({
    Key? key,
    required this.isLoading,
    required this.isSmallScreen,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
              side: BorderSide(color: AppColors.borderColor(context)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'إلغاء',
              style: AppTextStyles.medium(context).copyWith(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor(context).withOpacity(0.7),
              ),
            ),
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: isSmallScreen ? 14 : 16,
                        height: isSmallScreen ? 14 : 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'جاري الإرسال...',
                        style: AppTextStyles.medium(context).copyWith(
                          fontSize: isSmallScreen ? 13 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: isSmallScreen ? 16 : 18),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'إرسال طلب الحجز',
                          style: AppTextStyles.medium(context).copyWith(
                            fontSize: isSmallScreen ? 13 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}