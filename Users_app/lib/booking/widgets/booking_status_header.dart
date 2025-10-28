import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

// Widget حالة التحميل
class LoadingStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل الحجوزات...',
            style: AppTextStyles.large(context).copyWith(
              color: AppColors.textColor(context).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget حالة الخطأ
class ErrorStateWidget extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    Key? key,
    required this.fadeAnimation,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(24),
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.inputFillColor(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderColor(context).withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'حدث خطأ في تحميل الحجوزات',
                style: AppTextStyles.extraLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: AppTextStyles.large(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget حالة فارغة
class EmptyStateWidget extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const EmptyStateWidget({
    Key? key,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: AppColors.textColor(context).withOpacity(0.4),
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد حجوزات حالية',
              style: AppTextStyles.extraLarge(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor(context).withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'ابدأ بحجز خدمة جديدة',
              style: AppTextStyles.medium(context).copyWith(
                color: AppColors.textColor(context).withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}