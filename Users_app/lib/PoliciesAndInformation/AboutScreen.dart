import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
    _logoController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: customColors.borderColor),
          ),
          child: Column(
            children: [
              // Header مع الشعار
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Stack(
                  children: [
                    // تأثير الخلفية
                    Positioned.fill(
                      child: CustomPaint(
                        painter: EventPatternPainter(),
                      ),
                    ),
                    // المحتوى
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // شعار التطبيق مع تأثير
                          ScaleTransition(
                            scale: _logoAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onPrimary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Bahja',
                                  style: AppTextStyles.title(context).copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'عن التطبيق',
                                  style: AppTextStyles.heading(context).copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'نسج ذكريات لا تُنسى',
                                  style: AppTextStyles.small(context).copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // زر الإغلاق
                    Positioned(
                      top: 15,
                      left: 15,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // المحتوى
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // وصف التطبيق
                        _buildFeatureCard(
                          icon: FontAwesomeIcons.star,
                          title: 'مرحباً بك في Bahja',
                          description: '''Bahja هو تطبيقك المثالي لحجز جميع خدمات الحفلات والمناسبات في اليمن. نحن نجمع بين التقاليد اليمنية العريقة والتكنولوجيا الحديثة لنقدم لك تجربة فريدة في تنظيم مناسباتك الخاصة.

سواء كان حفل زفاف، عقد قران، خطوبة، أو أي مناسبة اجتماعية، نحن هنا لنساعدك في خلق ذكريات جميلة تدوم مدى الحياة.''',
                          theme: theme,
                        ),

                        // الخدمات
                        _buildFeatureCard(
                          icon: FontAwesomeIcons.calendarDays,
                          title: 'خدماتنا المتميزة',
                          description: '''🎪 قاعات الأفراح والمناسبات
🎂 خدمات الطعام والحلويات
📸 التصوير والفيديو
🎵 الموسيقى والترفيه
💐 تنسيق الزهور والديكور
🚗 خدمات النقل والسيارات
👗 الأزياء وصالونات التجميل
🎁 بطاقات الدعوة الرقمية''',
                          theme: theme,
                        ),

                        // مميزات التطبيق
                        _buildFeatureCard(
                          icon: FontAwesomeIcons.medal,
                          title: 'لماذا Bahja؟',
                          description: '''✨ واجهة سهلة وأنيقة باللغة العربية
🔍 بحث متقدم حسب الموقع والسعر
💬 تواصل مباشر مع مقدمي الخدمات
⭐ تقييمات وآراء المستخدمين
📱 حجز فوري وآمن
🎉 عروض وخصومات حصرية
🛡️ ضمان الجودة والموثوقية
📞 دعم عملاء على مدار الساعة''',
                          theme: theme,
                        ),

                        // فريق العمل
                        _buildFeatureCard(
                          icon: FontAwesomeIcons.users,
                          title: 'فريقنا',
                          description: '''نحن فريق من المطورين والمصممين اليمنيين الشغوفين بالتكنولوجيا، نعمل بكل حب وإخلاص لتقديم أفضل الخدمات لمجتمعنا اليمني الكريم.

هدفنا هو تسهيل تنظيم المناسبات وجعلها تجربة ممتعة ولا تُنسى للجميع.''',
                          theme: theme,
                        ),

                        // معلومات التطبيق
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: customColors.borderColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow('الإصدار', '1.0.0', context),
                              Divider(color: customColors.borderColor),
                              _buildInfoRow('تاريخ الإطلاق', 'أغسطس 2025', context),
                              Divider(color: customColors.borderColor),
                              _buildInfoRow('المطور', 'Bahja Team', context),
                              Divider(color: customColors.borderColor),
                              _buildInfoRow('نظام التشغيل', 'Android', context),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // أزرار التواصل
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launchURL('https://wa.me/967774583030'),
                                icon: FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                                label: Text(
                                  'واتساب',
                                  style: AppTextStyles.small(context),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launchURL('mailto:jmal774583030@gmail.com'),
                                icon: FaIcon(FontAwesomeIcons.envelope, size: 18),
                                label: Text(
                                  'إيميل',
                                  style: AppTextStyles.small(context),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // شكر وتقدير
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: customColors.borderColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.heart,
                                color: Colors.red,
                                size: 30,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'شكراً لثقتكم',
                                style: AppTextStyles.medium(context).copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'نعتز بثقتكم ونسعى دائماً لتقديم الأفضل',
                                style: AppTextStyles.small(context).copyWith(
                                  color: theme.hintColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    final customColors = AppThemes.customColors(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: customColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.medium(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.small(context).copyWith(
              // color: theme.textTheme.bodyLarge?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.small(context).copyWith(
            color: Theme.of(context).hintColor,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.small(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('لم يتمكن من فتح الرابط. تأكد من وجود تطبيق مناسب لفتح هذا النوع من الروابط.');
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء محاولة فتح الرابط. يرجى المحاولة مرة أخرى.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تنبيه',
          style: AppTextStyles.medium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.small(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'موافق',
              style: AppTextStyles.small(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// رسام مخصص لنمط الأحداث
class EventPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // رسم بالونات
    for (int i = 0; i < 15; i++) {
      final x = (i * 47) % size.width;
      final y = (i * 31) % size.height;
      
      // البالون
      canvas.drawCircle(Offset(x, y), 3, paint);
      
      // خيط البالون
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(x, y + 3),
        Offset(x, y + 15),
        linePaint,
      );
    }

    // رسم نجوم
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final x = (i * 73) % size.width;
      final y = (i * 67) % size.height;
      
      _drawStar(canvas, Offset(x, y), 4, starPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final angle = (3.14159 * 2) / 5;

    for (int i = 0; i < 5; i++) {
      final x1 = center.dx + radius * 0.8 * cos(i * angle);
      final y1 = center.dy + radius * 0.8 * sin(i * angle);
      final x2 = center.dx + radius * 0.3 * cos((i + 0.5) * angle);
      final y2 = center.dy + radius * 0.3 * sin((i + 0.5) * angle);
      
      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}