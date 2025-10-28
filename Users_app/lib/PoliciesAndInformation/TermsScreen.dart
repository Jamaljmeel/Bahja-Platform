import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/constants.dart';
import '../screens/ContactUsPage .dart';
import '../theme/app_theme.dart';

class TermsScreen extends StatefulWidget {
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar مخصص
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: LegalPatternPainter(),
                      ),
                    ),
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 40),
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.scaleBalanced,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'الشروط والأحكام',
                                style: AppTextStyles.heading(context).copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'الإطار القانوني لاستخدام Bahja',
                                style: AppTextStyles.medium(context).copyWith(
                                  color: Colors.white.withOpacity(0.9),
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // المحتوى
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -30),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border.all(color: customColors.borderColor),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // المقدمة
                      _buildTermCard(
                        icon: FontAwesomeIcons.handshake,
                        title: 'مرحباً بك في Bahja',
                        content:
                            '''باستخدامك لتطبيق Bahja، فإنك توافق على الالتزام بهذه الشروط والأحكام. نحن نوفر منصة لحجز خدمات الحفلات والمناسبات في اليمن، ونسعى لضمان تجربة آمنة وممتعة لجميع المستخدمين.

يرجى قراءة هذه الشروط بعناية قبل استخدام التطبيق.''',
                        theme: theme,
                        isHighlighted: true,
                      ),

                      // تعريف الخدمات
                      _buildTermCard(
                        icon: FontAwesomeIcons.star,
                        title: 'تعريف الخدمات',
                        content:
                            '''Bahja هو تطبيق يربط بين العملاء ومقدمي خدمات المناسبات والحفلات في اليمن، يشمل:

🎪 حجز قاعات الأفراح والمناسبات
🍰 خدمات الطعام والضيافة
📸 خدمات التصوير والتوثيق
🎵 خدمات الترفيه والموسيقى
💐 تنسيق الزهور والديكور
🚗 خدمات النقل والمواصلات
💅 خدمات التجميل والأزياء
📱 بطاقات الدعوة الرقمية

نحن نعمل كوسيط بين الطرفين ولا نقدم الخدمات مباشرة.''',
                        theme: theme,
                      ),

                      // شروط الاستخدام
                      _buildTermCard(
                        icon: FontAwesomeIcons.userCheck,
                        title: 'شروط الاستخدام',
                        content: '''للاستفادة من خدمات Bahja، يجب عليك:

✅ أن تكون بالغاً أو لديك موافقة ولي الأمر
✅ تقديم معلومات صحيحة ودقيقة
✅ الحفاظ على سرية بيانات الحساب
✅ عدم انتهاك حقوق الآخرين
✅ احترام الآداب العامة والأعراف اليمنية
✅ عدم استخدام التطبيق لأغراض غير قانونية
✅ الالتزام بسياسات الدفع والإلغاء
✅ احترام خصوصية المستخدمين الآخرين''',
                        theme: theme,
                      ),

                      // الحجز والدفع
                      _buildTermCard(
                        icon: FontAwesomeIcons.creditCard,
                        title: 'الحجز والدفع',
                        content: '''عند إجراء حجز عبر Bahja:

💳 يتم الدفع وفقاً لشروط مقدم الخدمة
📅 تواريخ الحجز ملزمة للطرفين
💰 الأسعار المعروضة قابلة للتغيير حسب الطلب
🔄 سياسة الإلغاء تختلف حسب نوع الخدمة
📋 العقود تُبرم بين العميل ومقدم الخدمة مباشرة
⏰ يجب تأكيد الحجز خلال 24 ساعة
💸 رسوم الخدمة غير قابلة للاسترداد
📞 يجب التواصل المباشر لتأكيد التفاصيل''',
                        theme: theme,
                      ),

                      // مسؤوليات مقدمي الخدمات
                      _buildTermCard(
                        icon: FontAwesomeIcons.userTie,
                        title: 'مسؤوليات مقدمي الخدمات',
                        content: '''مقدمو الخدمات ملزمون بـ:

🏆 تقديم خدمات عالية الجودة
📋 الالتزام بالمواصفات المتفق عليها
⏰ الالتزام بالمواعيد المحددة
💯 ضمان صحة المعلومات المقدمة
🛡️ الحصول على التراخيص اللازمة
📞 التواصل المهني مع العملاء
💼 تحمل المسؤولية القانونية عن خدماتهم
🔒 حماية خصوصية بيانات العملاء''',
                        theme: theme,
                      ),

                      // حدود المسؤولية
                      _buildTermCard(
                        icon: FontAwesomeIcons.shieldAlt,
                        title: 'حدود المسؤولية',
                        content: '''Bahja غير مسؤول عن:

❌ جودة الخدمات المقدمة من الموردين
❌ النزاعات بين العملاء ومقدمي الخدمات
❌ الأضرار الناتجة عن سوء استخدام التطبيق
❌ فقدان البيانات لأسباب تقنية خارجة عن سيطرتنا
❌ التأخير أو الإلغاء من قبل مقدمي الخدمات
❌ الأخطاء في المعلومات المقدمة من الموردين
❌ المشاكل المالية مع مقدمي الخدمات
❌ الخسائر غير المباشرة أو التبعية

مسؤوليتنا محدودة بقيمة رسوم الخدمة فقط.''',
                        theme: theme,
                      ),

                      // الملكية الفكرية
                      _buildTermCard(
                        icon: FontAwesomeIcons.copyright,
                        title: 'الملكية الفكرية',
                        content: '''جميع الحقوق محفوظة لـ Bahja:

📱 تصميم التطبيق وواجهته
💡 الأفكار والابتكارات التقنية
🎨 الشعارات والعلامات التجارية
📝 المحتوى والنصوص
🔧 التقنيات والخوارزميات المستخدمة

المستخدمون يحتفظون بحقوق المحتوى الذي يرفعونه، لكن يمنحون Bahja ترخيصاً لاستخدامه في تشغيل الخدمة.''',
                        theme: theme,
                      ),

                      // سياسة الإلغاء
                      _buildTermCard(
                        icon: FontAwesomeIcons.ban,
                        title: 'سياسة الحساب',
                        content: '''يمكن لـ Bahja تعليق أو إلغاء الحساب في حالة:

⚠️ انتهاك الشروط والأحكام
⚠️ تقديم معلومات مضللة أو خاطئة
⚠️ السلوك غير المهني مع الآخرين
⚠️ محاولة اختراق النظام
⚠️ استخدام التطبيق لأغراض غير قانونية
⚠️ التلاعب في التقييمات
⚠️ عدم الدفع للخدمات المحجوزة
⚠️ الإضرار بسمعة التطبيق

نحتفظ بحق اتخاذ الإجراءات القانونية عند الضرورة.''',
                        theme: theme,
                      ),

                      // التحديثات
                      _buildTermCard(
                        icon: FontAwesomeIcons.sync,
                        title: 'تحديث الشروط',
                        content:
                            '''نحتفظ بحق تحديث هذه الشروط والأحكام في أي وقت. سيتم إشعار المستخدمين بالتغييرات المهمة عبر:

📧 البريد الإلكتروني
📱 إشعارات التطبيق
🌐 نشر النسخة المحدثة في التطبيق

استمرار استخدام التطبيق بعد التحديث يعني موافقتك على الشروط الجديدة.

تاريخ آخر تحديث: ديسمبر 2024''',
                        theme: theme,
                      ),

                      // القانون المطبق
                      _buildTermCard(
                        icon: FontAwesomeIcons.landmark,
                        title: 'القانون المطبق',
                        content:
                            '''تخضع هذه الشروط والأحكام للقانون اليمني. أي نزاع ينشأ عن استخدام التطبيق سيتم حله وفقاً للقوانين واللوائح المعمول بها في الجمهورية اليمنية.

المحاكم اليمنية المختصة هي صاحبة الاختصاص في النظر في أي نزاعات قانونية.''',
                        theme: theme,
                        isHighlighted: true,
                      ),

                      // زر الموافقة
                      SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'شكراً لموافقتك على الشروط والأحكام',
                                  style: AppTextStyles.small(context),
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          icon: FaIcon(FontAwesomeIcons.check, size: 18),
                          label: Text(
                            'أوافق على الشروط والأحكام',
                            style: AppTextStyles.medium(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // معلومات التواصل
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: customColors.borderColor),
                        ),
                        child: Column(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.headset,
                              color: AppColors.primary,
                              size: 30,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'لديك استفسار قانوني؟',
                              style: AppTextStyles.medium(context).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'تواصل مع فريق الدعم القانوني لدينا',
                              style: AppTextStyles.small(context).copyWith(
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ContactUsPage()),
                                );
                              },
                              icon: FaIcon(FontAwesomeIcons.envelope, size: 16),
                              label: Text(
                                'تواصل معنا',
                                style: AppTextStyles.small(context),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermCard({
    required IconData icon,
    required String title,
    required String content,
    required ThemeData theme,
    bool isHighlighted = false,
  }) {
    final customColors = AppThemes.customColors(context);
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Card(
                elevation: isHighlighted ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: customColors.borderColor),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isHighlighted
                              ? [Colors.orange, Colors.amber]
                              : [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: FaIcon(
                              icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.medium(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isHighlighted)
                            FaIcon(
                              FontAwesomeIcons.star,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        content,
                        style: AppTextStyles.small(context).copyWith(
                          // color: theme.textTheme.bodyLarge?.color,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// رسام مخصص للنمط القانوني
class LegalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // رسم أشكال قانونية
    for (int i = 0; i < 12; i++) {
      final x = (i * 67) % size.width;
      final y = (i * 43) % size.height;

      // رسم مقاييس العدالة
      _drawScale(canvas, Offset(x, y), paint);
    }

    // رسم خطوط متوازية (تمثل القوانين)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final y = (i * 20.0);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }
  }

  void _drawScale(Canvas canvas, Offset center, Paint paint) {
    // رسم قاعدة الميزان
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 8, height: 2),
      paint,
    );

    // رسم عمود الميزان
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 6),
        width: 1,
        height: 12,
      ),
      paint,
    );

    // رسم كفتي الميزان
    canvas.drawCircle(Offset(center.dx - 4, center.dy - 8), 2, paint);
    canvas.drawCircle(Offset(center.dx + 4, center.dy - 8), 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}